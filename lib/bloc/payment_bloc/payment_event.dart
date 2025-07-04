part of 'payment_bloc.dart';

abstract class PaymentEvent {}

class ProcessPayment extends PaymentEvent {
  final String reservationId;
  final double amount;
  final String ownerId;
  final File paymentImage;
  final Reservation reservation;

  ProcessPayment({
    required this.reservationId,
    required this.amount,
    required this.ownerId,
    required this.paymentImage,
    required this.reservation,
  });
} 