import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/slots.dart';

part 'booking_event.dart';
part 'booking_state.dart';

/// Bloc quản lý trạng thái và logic đặt chỗ đỗ xe
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final FirebaseFirestore firestore;
  StreamSubscription? _reservationSubscription;
  String? _currentLotId;
  DateTime? _currentStartTime;
  DateTime? _currentEndTime;
  String? _currentVehicleType;
  bool _isFirstLoad = true;
  Set<String> _lastProcessedDocIds = {};

  BookingBloc(this.firestore) : super(BookingInitial()) {
    on<LoadSlots>(_onLoadSlots);
    on<BookSlot>(_onBookSlot);
    on<AddPendingReservation>(_onAddPendingReservation);
  }

  @override
  Future<void> close() {
    _reservationSubscription?.cancel();
    return super.close();
  }

  /// Xử lý sự kiện tải danh sách các vị trí đỗ xe
  /// Kiểm tra và cập nhật trạng thái đặt chỗ dựa trên thời gian được chọn
  void _onLoadSlots(LoadSlots event, Emitter<BookingState> emit) async {
    // Chỉ emit BookingLoading khi load lần đầu hoặc khi thay đổi lotId
    if (_isFirstLoad || _currentLotId != event.lotId) {
      emit(BookingLoading());
      _isFirstLoad = false;
    }

    try {
      print('--- [BookingBloc] LoadSlots ---');
      print('LotId: ' + event.lotId);
      print('VehicleType: ' + event.vehicleType);
      print('Start: ' + event.selectedStartTime.toString());
      print('End: ' + event.selectedEndTime.toString());

      // Lưu thông tin hiện tại
      _currentLotId = event.lotId;
      _currentStartTime = event.selectedStartTime;
      _currentEndTime = event.selectedEndTime;
      _currentVehicleType = event.vehicleType;

      // Lấy tất cả các slot từ Firestore và lọc theo vehicleType
      final snapshot = await firestore
          .collection('parking_lots')
          .doc(event.lotId)
          .collection('slots')
          .get();
      print('Tổng số slot lấy được: ${snapshot.docs.length}');
      print('LotId đang lấy slot: ${event.lotId}');
      print('--- Danh sách slot lấy được từ Firestore ---');
      for (var doc in snapshot.docs) {
        print('Slot ${doc.id}: vehicle=${doc.data()['vehicle']}');
      }

      // Lọc slot theo vehicleType
      final filteredSlots = snapshot.docs.where((doc) {
        final slotData = doc.data();
        final slotVehicleType = slotData['vehicle'] as String? ?? '';
        print('Checking slot ${doc.id}: vehicleType=$slotVehicleType, requiredType=${event.vehicleType}');
        return slotVehicleType == event.vehicleType;
      }).toList();
      print('Số slot sau khi lọc theo vehicleType: ${filteredSlots.length}');

      // Chỉ tạo listener mới nếu chưa có hoặc khi thay đổi lotId
      if (_reservationSubscription == null || _currentLotId != event.lotId) {
        await _reservationSubscription?.cancel();
        _lastProcessedDocIds.clear();
        
        _reservationSubscription = firestore
            .collection('reservations')
            .where('lotId', isEqualTo: event.lotId)
            .snapshots()
            .listen((snapshot) {
          // Kiểm tra xem có thay đổi mới nào không
          final newDocIds = snapshot.docs.map((doc) => doc.id).toSet();
          if (newDocIds != _lastProcessedDocIds) {
            print('Có thay đổi trong reservations, reloading slots...');
            if (_currentLotId != null && _currentStartTime != null && 
                _currentEndTime != null && _currentVehicleType != null) {
              add(LoadSlots(_currentLotId!, _currentStartTime!, _currentEndTime!, _currentVehicleType!));
            }
            _lastProcessedDocIds = newDocIds;
          }
        });
      }

      // Lấy tất cả các đặt chỗ trong collection reservations
      final reservationSnapshot = await firestore
          .collection('reservations')
          .where('lotId', isEqualTo: event.lotId)
          .get();
      print('Tổng số reservation lấy được: ${reservationSnapshot.docs.length}');

      // In log để kiểm tra thời gian từ Firestore và thời gian người dùng nhập vào
      print("User selected start time: ${event.selectedStartTime}");
      print("User selected end time: ${event.selectedEndTime}");
      print("Selected vehicle type: ${event.vehicleType}");

      final now = DateTime.now();
      final slots = filteredSlots.map((doc) {
        final slotData = doc.data();
        final slot = ParkingSlot.fromMap(slotData);
        
        // Kiểm tra pending reservation còn hiệu lực
        final validPending = slot.pendingReservations.where((pending) {
          print('Slot ${slot.id} pending: start=${pending.startTime}, end=${pending.endTime}, createdAt=${pending.createdAt}');
          // Kiểm tra xem pending có bị cancel/completed/checkout không
          final isInvalid = reservationSnapshot.docs.any((reservationDoc) {
            final reservationData = reservationDoc.data();
            final startTime = (reservationData['startTime'] as Timestamp).toDate();
            final endTime = (reservationData['endTime'] as Timestamp).toDate();
            final status = reservationData['status'] as String? ?? 'pending';
            return startTime == pending.startTime && 
                   endTime == pending.endTime && 
                   (status == 'cancelled' || status == 'completed' || status == 'checkout');
          });
          
          return !isInvalid && 
                 now.difference(pending.createdAt).inMinutes < 3 &&
                 event.selectedStartTime.isBefore(pending.endTime) && 
                 event.selectedEndTime.isAfter(pending.startTime);
        }).toList();
        final isPending = validPending.isNotEmpty;

        // Kiểm tra các reservation cho slot này
        final slotReservations = reservationSnapshot.docs.where((reservationDoc) {
          final reservationData = reservationDoc.data();
          final slotId = reservationData['slotId'] as String;
          return slotId == slot.id;
        }).toList();

        // Kiểm tra xem có reservation hợp lệ nào không
        bool hasValidReservation = false;
        for (var reservationDoc in slotReservations) {
          final reservationData = reservationDoc.data();
          final startTime = (reservationData['startTime'] as Timestamp).toDate();
          final endTime = (reservationData['endTime'] as Timestamp).toDate();
          final status = reservationData['status'] as String? ?? 'pending';
          
          print('Checking reservation for slot ${slot.id}: start=$startTime, end=$endTime, status=$status');
          
          // Kiểm tra thời gian và status
          if (event.selectedStartTime.isBefore(endTime) && 
              event.selectedEndTime.isAfter(startTime) &&
              status != 'cancelled' &&
              status != 'completed' &&
              status != 'checkout') {
            hasValidReservation = true;
            break;
          }
        }

        final isBooked = hasValidReservation || isPending;
        print('Slot ${slot.id}: isBooked=$isBooked, isPending=$isPending, vehicleType=${slot.vehicleType}');
        
        return ParkingSlot(
          id: slot.id, 
          isBooked: isBooked, 
          pendingReservations: slot.pendingReservations,
          vehicleType: slotData['vehicle'] ?? '',
        );
      }).toList();
      print('Số slot còn lại sau lọc: ${slots.where((s) => !s.isBooked).length}');

      emit(BookingLoaded(slots, event.vehicleType));
    } catch (e) {
      print('Lỗi khi load slots: $e');
      emit(BookingError("Lỗi khi tải slot: $e"));
    }
  }

  /// Xử lý sự kiện đặt chỗ một vị trí đỗ xe
  /// Cập nhật trạng thái đặt chỗ trong Firestore và state
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
            return ParkingSlot(
              id: slot.id, 
              isBooked: true,
              vehicleType: slot.vehicleType,
            );
          }
          return slot;
        }).toList();

        emit(BookingLoaded(updatedSlots, currentState.vehicleType));
      } catch (e) {
        emit(BookingError("Lỗi khi cập nhật trạng thái đặt chỗ: $e"));
      }
    }
  }

  /// Xử lý sự kiện thêm một đơn đặt chỗ đang chờ xử lý
  /// Thêm thông tin đặt chỗ vào mảng pendingReservations của slot
  Future<void> _onAddPendingReservation(AddPendingReservation event, Emitter<BookingState> emit) async {
    try {
      final pending = {
        'userId': event.userId,
        'startTime': event.startTime.toIso8601String(),
        'endTime': event.endTime.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };
      final slotRef = firestore
          .collection('parking_lots')
          .doc(event.lotId)
          .collection('slots')
          .doc(event.slotId);
      await slotRef.update({
        'pendingReservations': FieldValue.arrayUnion([pending])
      });
      // Sau khi thêm, reload lại slot
      if (state is BookingLoaded) {
        final currentState = state as BookingLoaded;
        add(LoadSlots(event.lotId, event.startTime, event.endTime, currentState.vehicleType));
      }
    } catch (e) {
      emit(BookingError("Lỗi khi thêm pending reservation: $e"));
    }
  }
}