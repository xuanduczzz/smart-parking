/// MapBloc quản lý trạng thái và logic của bản đồ
/// Sử dụng BLoC pattern để xử lý các sự kiện liên quan đến bản đồ và bãi đỗ xe
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:park/data/service/parking_service.dart';
import 'package:park/data/model/parking_lot.dart';

part 'map_event.dart';
part 'map_state.dart';

/// MapBloc class xử lý các sự kiện và trạng thái của bản đồ
class MapBloc extends Bloc<MapEvent, MapState> {
  /// Service để tương tác với dữ liệu bãi đỗ xe
  final ParkingService parkingService;

  MapBloc(this.parkingService) : super(MapInitial()) {
    on<LoadParkingMarkersEvent>(_onLoadParkingMarkers);
  }

  /// Xử lý sự kiện tải các marker bãi đỗ xe
  /// Khi có sự kiện LoadParkingMarkersEvent, hàm này sẽ:
  /// 1. Emit trạng thái loading
  /// 2. Gọi service để lấy danh sách bãi đỗ xe
  /// 3. Emit trạng thái loaded với danh sách bãi đỗ xe
  /// 4. Nếu có lỗi, emit trạng thái error với thông báo lỗi
  Future<void> _onLoadParkingMarkers(
      LoadParkingMarkersEvent event,
      Emitter<MapState> emit,
      ) async {
    try {
      emit(MapLoading());
      final parkingLots = await parkingService.getParkingLots();
      emit(MapLoaded(parkingLots: parkingLots));
    } catch (e) {
      emit(MapError(message: "Failed to load parking lots"));
    }
  }
}
