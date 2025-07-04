part of 'map_bloc.dart';

/// Lớp cơ sở cho các sự kiện của MapBloc
abstract class MapEvent {}

/// Sự kiện được phát ra khi cần tải lại các marker bãi đỗ xe trên bản đồ
/// Sự kiện này thường được gọi khi:
/// - Khởi tạo bản đồ
/// - Người dùng yêu cầu làm mới dữ liệu
class LoadParkingMarkersEvent extends MapEvent {}

