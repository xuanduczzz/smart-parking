part of 'map_bloc.dart';

/// Lớp cơ sở cho các trạng thái của MapBloc
@immutable
abstract class MapState {}

/// Trạng thái khởi tạo ban đầu của MapBloc
class MapInitial extends MapState {}

/// Trạng thái đang tải dữ liệu bãi đỗ xe
class MapLoading extends MapState {}

/// Trạng thái đã tải xong dữ liệu bãi đỗ xe
/// Chứa danh sách các bãi đỗ xe để hiển thị trên bản đồ
class MapLoaded extends MapState {
  /// Danh sách các bãi đỗ xe
  final List<ParkingLot> parkingLots;

  MapLoaded({required this.parkingLots});
}

/// Trạng thái lỗi khi tải dữ liệu bãi đỗ xe
/// Chứa thông báo lỗi để hiển thị cho người dùng
class MapError extends MapState {
  /// Thông báo lỗi
  final String message;

  MapError({required this.message});
}
