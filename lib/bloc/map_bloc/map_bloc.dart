import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:park/data/service/parking_service.dart';
import 'package:park/data/model/parking_lot.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final ParkingService parkingService;

  MapBloc(this.parkingService) : super(MapInitial()) {
    on<LoadParkingMarkersEvent>(_onLoadParkingMarkers);
  }

  Future<void> _onLoadParkingMarkers(
      LoadParkingMarkersEvent event,
      Emitter<MapState> emit,
      ) async {
    try {
      emit(MapLoading());
      final parkingLots = await parkingService.getParkingLots(); // Trả về ParkingLot
      emit(MapLoaded(parkingLots: parkingLots));
    } catch (e) {
      emit(MapError(message: "Failed to load parking lots"));
    }
  }
}
