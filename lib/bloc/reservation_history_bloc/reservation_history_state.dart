part of 'reservation_history_bloc.dart';

abstract class ReservationHistoryState {}

class ReservationHistoryInitial extends ReservationHistoryState {}

class ReservationHistoryLoading extends ReservationHistoryState {}

class ReservationHistoryLoaded extends ReservationHistoryState {
  final List<Reservation> reservations;

  ReservationHistoryLoaded(this.reservations);
}

class ReservationHistoryError extends ReservationHistoryState {
  final String message;

  ReservationHistoryError(this.message);
}
