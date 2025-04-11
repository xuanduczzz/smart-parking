import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/reservation.dart';

part 'reservation_history_event.dart';
part 'reservation_history_state.dart';

class ReservationHistoryBloc extends Bloc<ReservationHistoryEvent, ReservationHistoryState> {
  final FirebaseFirestore firestore;

  ReservationHistoryBloc(this.firestore) : super(ReservationHistoryInitial()) {
    on<LoadReservations>((event, emit) async {
      emit(ReservationHistoryLoading());

      try {
        final snapshot = await firestore
            .collection('reservations')
            .orderBy('createdAt', descending: true)
            .get();

        final reservations = snapshot.docs.map((doc) {
          final data = doc.data();
          return Reservation.fromMap(data);
        }).toList();

        emit(ReservationHistoryLoaded(reservations));
      } catch (e) {
        emit(ReservationHistoryError("Lỗi khi tải dữ liệu: $e"));
      }
    });
  }
}
