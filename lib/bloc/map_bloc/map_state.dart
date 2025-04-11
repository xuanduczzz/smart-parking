part of 'map_bloc.dart';

@immutable
abstract class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<ParkingLot> parkingLots;

  MapLoaded({required this.parkingLots});
}

class MapError extends MapState {
  final String message;

  MapError({required this.message});
}
