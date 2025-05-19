part of 'reservation_history_bloc.dart';

abstract class ReservationHistoryEvent {}

class LoadReservations extends ReservationHistoryEvent {}

class UpdateReservations extends ReservationHistoryEvent {
  final QuerySnapshot snapshot;

  UpdateReservations(this.snapshot);
}
