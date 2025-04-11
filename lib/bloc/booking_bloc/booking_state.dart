part of 'booking_bloc.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<ParkingSlot> slots;
  BookingLoaded(this.slots);
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}