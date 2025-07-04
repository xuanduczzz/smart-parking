part of 'payment_bloc.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final String reservationId;
  final String paymentImageUrl;

  PaymentSuccess({
    required this.reservationId,
    required this.paymentImageUrl,
  });
}

class PaymentError extends PaymentState {
  final String message;

  PaymentError(this.message);
} 