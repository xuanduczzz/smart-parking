part of 'booking_bloc.dart';

/// Base class cho tất cả các sự kiện liên quan đến đặt chỗ
abstract class BookingEvent {}

/// Sự kiện tải danh sách các vị trí đỗ xe
/// Kèm theo thông tin về bãi đỗ xe và khoảng thời gian đặt chỗ
class LoadSlots extends BookingEvent {
  /// ID của bãi đỗ xe
  final String lotId;
  /// Thời gian bắt đầu đặt chỗ
  final DateTime selectedStartTime;
  /// Thời gian kết thúc đặt chỗ
  final DateTime selectedEndTime;
  /// Loại phương tiện
  final String vehicleType;

  LoadSlots(this.lotId, this.selectedStartTime, this.selectedEndTime, this.vehicleType);
}

/// Sự kiện đặt chỗ một vị trí đỗ xe
class BookSlot extends BookingEvent {
  /// ID của bãi đỗ xe
  final String lotId;
  /// ID của vị trí đỗ xe
  final String slotId;
  BookSlot(this.lotId, this.slotId);
}

/// Sự kiện thêm một đơn đặt chỗ đang chờ xử lý
class AddPendingReservation extends BookingEvent {
  /// ID của bãi đỗ xe
  final String lotId;
  /// ID của vị trí đỗ xe
  final String slotId;
  /// ID của người dùng đặt chỗ
  final String userId;
  /// Thời gian bắt đầu đặt chỗ
  final DateTime startTime;
  /// Thời gian kết thúc đặt chỗ
  final DateTime endTime;
  AddPendingReservation(this.lotId, this.slotId, this.userId, this.startTime, this.endTime);
}