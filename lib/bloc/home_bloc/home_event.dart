part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadParkingLotInfo extends HomeEvent {
  final String parkingLotId;

  const LoadParkingLotInfo({required this.parkingLotId});

  @override
  List<Object> get props => [parkingLotId];
}

class RefreshParkingLotInfo extends HomeEvent {
  final String parkingLotId;

  const RefreshParkingLotInfo({required this.parkingLotId});

  @override
  List<Object> get props => [parkingLotId];
}

class LoadParkingLotDetail extends HomeEvent {
  final String parkingLotId;

  const LoadParkingLotDetail({required this.parkingLotId});

  @override
  List<Object> get props => [parkingLotId];
} 