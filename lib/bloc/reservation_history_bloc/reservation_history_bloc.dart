import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park/data/model/reservation.dart';

part 'reservation_history_event.dart';
part 'reservation_history_state.dart';

class ReservationHistoryBloc extends Bloc<ReservationHistoryEvent, ReservationHistoryState> {
  final FirebaseFirestore firestore;

  ReservationHistoryBloc(this.firestore) : super(ReservationHistoryInitial()) {
    on<LoadReservations>((event, emit) async {
      emit(ReservationHistoryLoading());

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          emit(ReservationHistoryError("Chưa đăng nhập."));
          return;
        }

        final snapshot = await firestore
            .collection('reservations')
            .where('userId', isEqualTo: currentUser.uid) // ✅ chỉ lấy của người dùng hiện tại
            .orderBy('createdAt', descending: true)
            .get();

        final reservations = snapshot.docs.map((doc) {
          final data = doc.data();
          return Reservation.fromMap(doc.id, data);
        }).toList();

        emit(ReservationHistoryLoaded(reservations));
      } catch (e) {
        emit(ReservationHistoryError("Lỗi khi tải dữ liệu: $e"));
      }
    });
  }
}
