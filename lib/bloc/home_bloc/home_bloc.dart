import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/parking_lot.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseFirestore _firestore;

  HomeBloc({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(HomeInitial()) {
    on<LoadParkingLotInfo>(_onLoadParkingLotInfo);
    on<RefreshParkingLotInfo>(_onRefreshParkingLotInfo);
  }

  Future<void> _onLoadParkingLotInfo(
    LoadParkingLotInfo event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(HomeLoading());

      // Lấy thông tin bãi đỗ xe
      final parkingLotDoc = await _firestore
          .collection('parking_lots')
          .doc(event.parkingLotId)
          .get();

      final bool exists = parkingLotDoc.exists;
      if (exists == false) {
        emit(const HomeError(message: 'Không tìm thấy thông tin bãi đỗ xe'));
        return;
      }

      final parkingLotData = parkingLotDoc.data() as Map<String, dynamic>;
      final parkingLot = ParkingLot.fromFirestore(event.parkingLotId, parkingLotData);

      // Lấy thông tin chủ bãi
      final ownerDoc = await _firestore
          .collection('user_owner')
          .doc(parkingLot.oid)
          .get();

      final bool ownerExists = ownerDoc.exists;
      final String ownerPhone = ownerExists 
          ? (ownerDoc.data()?['phone'] as String?) ?? 'Chưa có số điện thoại'
          : 'Chưa có số điện thoại';

      emit(HomeLoaded(
        address: parkingLot.address,
        totalSlots: parkingLot.totalSlots,
        pricePerHour: parkingLot.pricePerHour,
        ownerPhone: ownerPhone,
      ));
    } catch (e) {
      emit(HomeError(message: 'Không thể tải thông tin bãi đỗ xe: $e'));
    }
  }

  Future<void> _onRefreshParkingLotInfo(
    RefreshParkingLotInfo event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Lấy thông tin bãi đỗ xe
      final parkingLotDoc = await _firestore
          .collection('parking_lots')
          .doc(event.parkingLotId)
          .get();

      final bool exists = parkingLotDoc.exists;
      if (exists == false) {
        emit(const HomeError(message: 'Không tìm thấy thông tin bãi đỗ xe'));
        return;
      }

      final parkingLotData = parkingLotDoc.data() as Map<String, dynamic>;
      final parkingLot = ParkingLot.fromFirestore(event.parkingLotId, parkingLotData);

      // Lấy thông tin chủ bãi
      final ownerDoc = await _firestore
          .collection('user_owner')
          .doc(parkingLot.oid)
          .get();

      final bool ownerExists = ownerDoc.exists;
      final String ownerPhone = ownerExists 
          ? (ownerDoc.data()?['phone'] as String?) ?? 'Chưa có số điện thoại'
          : 'Chưa có số điện thoại';

      emit(HomeLoaded(
        address: parkingLot.address,
        totalSlots: parkingLot.totalSlots,
        pricePerHour: parkingLot.pricePerHour,
        ownerPhone: ownerPhone,
      ));
    } catch (e) {
      emit(HomeError(message: 'Không thể làm mới thông tin bãi đỗ xe: $e'));
    }
  }
} 