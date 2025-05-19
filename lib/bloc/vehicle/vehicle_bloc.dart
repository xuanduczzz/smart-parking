import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park/bloc/vehicle/vehicle_event.dart';
import 'package:park/bloc/vehicle/vehicle_state.dart';
import 'package:park/data/model/vehicle.dart';
import 'package:park/repository/vehicle_repository.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository _vehicleRepository;
  String? _currentUserId;

  VehicleBloc({required VehicleRepository vehicleRepository})
      : _vehicleRepository = vehicleRepository,
        super(VehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<AddVehicle>(_onAddVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
  }

  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      _currentUserId = event.userId;
      emit(VehicleLoading());
      await emit.forEach<List<Vehicle>>(
        _vehicleRepository.getVehicles(event.userId),
        onData: (vehicles) => VehicleLoaded(vehicles),
        onError: (_, __) => const VehicleError('Không thể tải danh sách xe'),
      );
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onAddVehicle(
    AddVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      emit(VehicleLoading());

      // Kiểm tra biển số xe đã tồn tại chưa
      final exists = await _vehicleRepository.isLicensePlateExists(event.licensePlate);
      if (exists) {
        emit(const VehicleError('Biển số xe này đã tồn tại'));
        return;
      }

      final vehicleId = FirebaseFirestore.instance.collection('vehicles').doc().id;
      final vehicle = Vehicle(
        vehicleId: vehicleId,
        createdAt: DateTime.now(),
        licensePlate: event.licensePlate,
        userId: event.userId,
        vehicleType: event.vehicleType,
      );

      await _vehicleRepository.addVehicle(vehicle);
      
      // Load lại danh sách xe sau khi thêm thành công
      if (_currentUserId != null) {
        add(LoadVehicles(_currentUserId!));
      }
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      emit(VehicleLoading());
      await _vehicleRepository.deleteVehicle(event.vehicleId);
      
      // Load lại danh sách xe sau khi xóa thành công
      if (_currentUserId != null) {
        add(LoadVehicles(_currentUserId!));
      }
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      emit(VehicleLoading());
      await _vehicleRepository.updateVehicle(event.vehicle);
      
      // Load lại danh sách xe sau khi cập nhật thành công
      if (_currentUserId != null) {
        add(LoadVehicles(_currentUserId!));
      }
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }
} 