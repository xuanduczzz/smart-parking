import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/slots.dart';

part 'booking_event.dart';
part 'booking_state.dart';



class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final FirebaseFirestore firestore;

  BookingBloc(this.firestore) : super(BookingInitial()) {
    on<LoadSlots>(_onLoadSlots);
    on<BookSlot>(_onBookSlot);
  }

  void _onLoadSlots(LoadSlots event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final snapshot = await firestore
          .collection('parking_lots')
          .doc(event.lotId)
          .collection('slots')
          .get();

      final slots = snapshot.docs.map((doc) {
        return ParkingSlot.fromMap(doc.data());
      }).toList();

      emit(BookingLoaded(slots));
    } catch (e) {
      emit(BookingError("Lỗi khi tải slot: $e"));
    }
  }

  void _onBookSlot(BookSlot event, Emitter<BookingState> emit) async {
    if (state is BookingLoaded) {
      final currentState = state as BookingLoaded;

      try {
        await firestore
            .collection('parking_lots')
            .doc(event.lotId)
            .collection('slots')
            .doc(event.slotId)
            .update({'isBooked': true});

        final updatedSlots = currentState.slots.map((slot) {
          if (slot.id == event.slotId) {
            return ParkingSlot(id: slot.id, isBooked: true);
          }
          return slot;
        }).toList();

        emit(BookingLoaded(updatedSlots));
      } catch (e) {
        emit(BookingError("Lỗi đặt chỗ: $e"));
      }
    }
  }
}