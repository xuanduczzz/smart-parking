part of 'reservation_bloc.dart';

abstract class ReservationState {}

class ReservationInitial extends ReservationState {}

class ReservationLoading extends ReservationState {}

class ReservationSuccess extends ReservationState {
  final double totalAmount;
  final String ownerId;
  final String qrImageUrl;
  final String reservationId;
  final Reservation reservation;

  ReservationSuccess({
    required this.totalAmount,
    required this.ownerId,
    required this.qrImageUrl,
    required this.reservationId,
    required this.reservation,
  });
}

class ReservationError extends ReservationState {
  final String message;

  ReservationError(this.message);
}
