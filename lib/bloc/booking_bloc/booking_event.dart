part of 'booking_bloc.dart';

abstract class BookingEvent {}

class LoadSlots extends BookingEvent {
  final String lotId;
  final DateTime selectedStartTime;
  final DateTime selectedEndTime;

  LoadSlots(this.lotId, this.selectedStartTime, this.selectedEndTime);
}


class BookSlot extends BookingEvent {
  final String lotId;
  final String slotId;
  BookSlot(this.lotId, this.slotId);
}