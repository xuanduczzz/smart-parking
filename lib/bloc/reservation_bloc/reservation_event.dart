part of 'reservation_bloc.dart';

abstract class ReservationEvent {}

class SaveReservation extends ReservationEvent {
  final Reservation reservation;

  SaveReservation({required this.reservation});
}