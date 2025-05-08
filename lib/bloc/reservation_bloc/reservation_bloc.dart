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
        final docRef = await firestore.collection('reservations').add(event.reservation.toMap());

        final reservationId = docRef.id;

        // Tạo chuỗi QR, ví dụ chứa reservationId
        final qrData = reservationId; // hoặc encode thông tin đầy đủ nếu cần

        await docRef.update({'qrCode': qrData});

        emit(ReservationSuccess());
        await firestore.collection('notifications').add({
          'userId': event.reservation.userId,
          'title': 'Đặt chỗ thành công',
          'body': 'Bạn đã đặt chỗ tại ${event.reservation.lotName} từ ${event.reservation.startTime}',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });

      } catch (e) {
        emit(ReservationError("Lỗi khi lưu đặt chỗ: $e"));
      }
    });


  }
}

