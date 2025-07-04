import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/reservation.dart';
import 'package:park/data/service/cloudinary_helper.dart';
import 'dart:developer' as developer;

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final FirebaseFirestore firestore;

  PaymentBloc(this.firestore) : super(PaymentInitial()) {
    on<ProcessPayment>((event, emit) async {
      emit(PaymentLoading());

      try {
        // Upload ảnh lên Cloudinary
        final imageUrl = await CloudinaryHelper.uploadImage(event.paymentImage);
        
        if (imageUrl == null) {
          throw Exception('Không thể tải lên ảnh thanh toán');
        }

        developer.log('Image uploaded successfully to Cloudinary. URL: $imageUrl', name: 'PaymentBloc');

        // Thêm reservation vào Firestore và lấy ID
        final docRef = await firestore.collection('reservations').add(event.reservation.toMap());
        final reservationId = docRef.id;

        // Thực hiện các thao tác cập nhật song song
        await Future.wait([
          // Cập nhật QR code và trạng thái thanh toán
          docRef.update({
            'qrCode': reservationId,
            'payStatus': true,
            'paymentImageUrl': imageUrl,
            'paymentTime': FieldValue.serverTimestamp(),
          }),

          // Lưu thông tin thanh toán
          firestore.collection('payment').add({
            'reservationId': reservationId,
            'amount': event.amount,
            'ownerId': event.ownerId,
            'paymentImageUrl': imageUrl,
            'paymentTime': FieldValue.serverTimestamp(),
            'status': 'completed',
          }),

          // Gửi thông báo
          firestore.collection('notifications').add({
            'userId': event.reservation.userId,
            'title': 'Đặt chỗ thành công',
            'body': 'Bạn đã đặt chỗ tại ${event.reservation.lotName} từ ${event.reservation.startTime}',
            'isRead': false,
            'timestamp': FieldValue.serverTimestamp(),
          }),
        ]);

        emit(PaymentSuccess(
          reservationId: reservationId,
          paymentImageUrl: imageUrl,
        ));

      } catch (e) {
        developer.log('Error processing payment: $e', name: 'PaymentBloc');
        emit(PaymentError('Lỗi khi xử lý thanh toán: $e'));
      }
    });
  }
} 