import 'package:equatable/equatable.dart';
import 'package:park/data/model/vehicle.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class LoadVehicles extends VehicleEvent {
  final String userId;

  const LoadVehicles(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddVehicle extends VehicleEvent {
  final String licensePlate;
  final String vehicleType;
  final String userId;

  const AddVehicle({
    required this.licensePlate,
    required this.vehicleType,
    required this.userId,
  });

  @override
  List<Object?> get props => [licensePlate, vehicleType, userId];
}

class DeleteVehicle extends VehicleEvent {
  final String vehicleId;

  const DeleteVehicle(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

class UpdateVehicle extends VehicleEvent {
  final Vehicle vehicle;

  const UpdateVehicle(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
} 