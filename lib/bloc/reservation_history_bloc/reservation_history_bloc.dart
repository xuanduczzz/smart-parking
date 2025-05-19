import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park/data/model/reservation.dart';

part 'reservation_history_event.dart';
part 'reservation_history_state.dart';

class ReservationHistoryBloc extends Bloc<ReservationHistoryEvent, ReservationHistoryState> {
  final FirebaseFirestore firestore;
  StreamSubscription<QuerySnapshot>? _subscription;

  ReservationHistoryBloc(this.firestore) : super(ReservationHistoryInitial()) {
    on<LoadReservations>(_onLoadReservations);
    on<UpdateReservations>(_onUpdateReservations);
  }

  Future<void> _onLoadReservations(
    LoadReservations event,
    Emitter<ReservationHistoryState> emit,
  ) async {
    emit(ReservationHistoryLoading());

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(ReservationHistoryError("Chưa đăng nhập."));
        return;
      }

      // Hủy subscription cũ nếu có
      await _subscription?.cancel();

      // Tạo subscription mới để lắng nghe thay đổi realtime
      _subscription = firestore
          .collection('reservations')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              add(UpdateReservations(snapshot));
            },
            onError: (error) {
              emit(ReservationHistoryError("Lỗi khi lắng nghe dữ liệu: $error"));
            },
          );

    } catch (e) {
      emit(ReservationHistoryError("Lỗi khi tải dữ liệu: $e"));
    }
  }

  void _onUpdateReservations(
    UpdateReservations event,
    Emitter<ReservationHistoryState> emit,
  ) {
    try {
      final reservations = event.snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Reservation.fromMap(doc.id, data);
      }).toList();

      emit(ReservationHistoryLoaded(reservations));
    } catch (e) {
      emit(ReservationHistoryError("Lỗi khi cập nhật dữ liệu: $e"));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
