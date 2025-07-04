part of 'booking_bloc.dart';

/// Base class cho tất cả các trạng thái liên quan đến đặt chỗ
abstract class BookingState {}

/// Trạng thái khởi tạo của booking bloc
class BookingInitial extends BookingState {}

/// Trạng thái đang tải dữ liệu
class BookingLoading extends BookingState {}

/// Trạng thái đã tải xong dữ liệu
/// Chứa danh sách các vị trí đỗ xe
class BookingLoaded extends BookingState {
  /// Danh sách các vị trí đỗ xe
  final List<ParkingSlot> slots;
  final String vehicleType;

  BookingLoaded(this.slots, this.vehicleType);
}

/// Trạng thái lỗi khi thực hiện các thao tác
class BookingError extends BookingState {
  /// Thông báo lỗi
  final String message;
  BookingError(this.message);
}