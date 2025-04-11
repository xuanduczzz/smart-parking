part of 'booking_bloc.dart';

abstract class BookingEvent {}

class LoadSlots extends BookingEvent {
  final String lotId;
  LoadSlots(this.lotId);
}

class BookSlot extends BookingEvent {
  final String lotId;
  final String slotId;
  BookSlot(this.lotId, this.slotId);
}