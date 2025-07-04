import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/reservation.dart';
import 'dart:developer' as developer;


part 'reservation_event.dart';
part 'reservation_state.dart';


class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final FirebaseFirestore firestore;

  ReservationBloc(this.firestore) : super(ReservationInitial()) {
    // Đăng ký sự kiện SaveReservation
    on<SaveReservation>((event, emit) async {
      emit(ReservationLoading());

      try {
        // Lấy thông tin owner từ parking lot
        final parkingLotDoc = await firestore
            .collection('parking_lots')
            .doc(event.reservation.lotId)
            .get();

        final ownerId = parkingLotDoc.data()?['oid'];
        developer.log('Owner ID from parking lot: $ownerId', name: 'ReservationBloc');

        // Lấy thông tin owner từ user_owner
        final ownerDoc = await firestore
            .collection('user_owner')
            .doc(ownerId)
            .get();

        final qrcode = ownerDoc.data()?['qrcode'];
        developer.log('QR Code from owner: $qrcode', name: 'ReservationBloc');

        if (qrcode == null) {
          throw Exception('Không tìm thấy mã QR của chủ bãi xe');
        }

        // Tạo reservation mới với thông tin owner
        final updatedReservation = Reservation(
          id: event.reservation.id,
          lotId: event.reservation.lotId,
          lotName: event.reservation.lotName,
          slotId: event.reservation.slotId,
          startTime: event.reservation.startTime,
          endTime: event.reservation.endTime,
          pricePerHour: event.reservation.pricePerHour,
          totalPrice: event.reservation.totalPrice,
          userId: event.reservation.userId,
          name: event.reservation.name,
          qrCode: event.reservation.qrCode,
          vehicleId: event.reservation.vehicleId,
          phoneNumber: event.reservation.phoneNumber,
          ownerId: ownerId ?? '',
          ownerQRUrl: qrcode,
          status: event.reservation.status,
        );

        developer.log('Updated reservation with QR: ${updatedReservation.ownerQRUrl}', name: 'ReservationBloc');

        // Tạo một ID tạm thời cho reservation
        final tempReservationId = DateTime.now().millisecondsSinceEpoch.toString();

        // Emit state thành công với thông tin cần thiết cho trang payment
        emit(ReservationSuccess(
          totalAmount: updatedReservation.totalPrice,
          ownerId: updatedReservation.ownerId,
          qrImageUrl: updatedReservation.ownerQRUrl,
          reservationId: tempReservationId,
          reservation: updatedReservation, // Thêm toàn bộ thông tin reservation
        ));

      } catch (e) {
        developer.log('Error in SaveReservation: $e', name: 'ReservationBloc', error: e);
        emit(ReservationError("Lỗi khi lấy thông tin thanh toán: $e"));
      }
    });


  }
}

