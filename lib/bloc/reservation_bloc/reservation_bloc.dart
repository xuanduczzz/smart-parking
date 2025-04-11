import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/reservation.dart';


part 'reservation_event.dart';
part 'reservation_state.dart';


class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final FirebaseFirestore firestore;

  ReservationBloc(this.firestore) : super(ReservationInitial()) {
    // Đăng ký sự kiện SaveReservation
    on<SaveReservation>((event, emit) async {
      emit(ReservationLoading());

      try {
        await firestore.collection('reservations').add(event.reservation.toMap());
        emit(ReservationSuccess());
      } catch (e) {
        emit(ReservationError("Lỗi khi lưu đặt chỗ: $e"));
      }
    });

  }
}

