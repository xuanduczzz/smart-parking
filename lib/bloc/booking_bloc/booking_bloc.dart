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
      // Lấy tất cả các slot từ Firestore
      final snapshot = await firestore
          .collection('parking_lots')
          .doc(event.lotId)
          .collection('slots')
          .get();

      // Lấy tất cả các đặt chỗ trong collection reservations
      final reservationSnapshot = await firestore
          .collection('reservations')
          .where('lotId', isEqualTo: event.lotId)
          .get();

      // In log để kiểm tra thời gian từ Firestore và thời gian người dùng nhập vào
      print("User selected start time: ${event.selectedStartTime}");
      print("User selected end time: ${event.selectedEndTime}");

      // Danh sách các slot đã bị đặt
      final bookedSlotIds = reservationSnapshot.docs.where((reservationDoc) {
        final reservationData = reservationDoc.data();
        final startTime = (reservationData['startTime'] as Timestamp).toDate();
        final endTime = (reservationData['endTime'] as Timestamp).toDate();

        // In log thời gian trong Firestore
        print("Reservation start time: $startTime");
        print("Reservation end time: $endTime");

        // Kiểm tra nếu thời gian đặt chỗ trùng với khoảng thời gian người dùng nhập
        return (event.selectedStartTime.isBefore(endTime) && event.selectedEndTime.isAfter(startTime));
      }).map((reservationDoc) => reservationDoc['slotId'] as String).toList();

      // Cập nhật danh sách các slot với trạng thái isBooked
      final slots = snapshot.docs.map((doc) {
        final slot = ParkingSlot.fromMap(doc.data());
        // Nếu slot bị đặt trong khoảng thời gian người dùng chọn, đánh dấu là đã đặt
        if (bookedSlotIds.contains(slot.id)) {
          return ParkingSlot(id: slot.id, isBooked: true);
        }
        return slot;
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
        // Cập nhật trạng thái 'isBooked' của slot trong Firestore
        await firestore
            .collection('parking_lots')
            .doc(event.lotId)
            .collection('slots')
            .doc(event.slotId)
            .update({'isBooked': true});

        // Cập nhật danh sách slot trong state để phản ánh thay đổi
        final updatedSlots = currentState.slots.map((slot) {
          if (slot.id == event.slotId) {
            return ParkingSlot(id: slot.id, isBooked: true);
          }
          return slot;
        }).toList();

        emit(BookingLoaded(updatedSlots));
      } catch (e) {
        emit(BookingError("Lỗi khi cập nhật trạng thái đặt chỗ: $e"));
      }
    }
  }


}