import 'package:flutter/cupertino.dart';
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
    on<LoadAllParkingLots>(_onLoadAllParkingLots);
  }

  Future<void> _onLoadAllParkingLots(
    LoadAllParkingLots event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(HomeLoading());

      // Lấy tất cả bãi xe
      final parkingLotsSnapshot = await _firestore
          .collection('parking_lots')
          .get();

      final Map<String, Map<String, dynamic>> parkingLotsInfo = {};

      // Lấy thông tin chi tiết cho từng bãi xe
      for (var lotDoc in parkingLotsSnapshot.docs) {
        final lotId = lotDoc.id;
        final lotData = lotDoc.data();
        final parkingLot = ParkingLot.fromFirestore(lotId, lotData);

        // Lấy thông tin chủ bãi
        String ownerPhone = 'Chưa có số điện thoại';
        if (parkingLot.oid != null && parkingLot.oid!.isNotEmpty) {
          try {
            final ownerDoc = await _firestore
                .collection('user_owner')
                .doc(parkingLot.oid)
                .get();

            if (ownerDoc.exists) {
              ownerPhone = (ownerDoc.data()?['phone'] as String?) ?? 'Chưa có số điện thoại';
            }
          } catch (e) {
            print('Lỗi khi lấy thông tin chủ bãi xe ${lotId}: $e');
          }
        }

        // Lấy đánh giá trung bình
        double averageRating = 0;
        try {
          final reviewsSnapshot = await _firestore
              .collection('reviews')
              .where('lotId', isEqualTo: lotId)
              .get();

          if (reviewsSnapshot.docs.isNotEmpty) {
            final totalStars = reviewsSnapshot.docs.fold<int>(
              0,
              (sum, doc) => sum + (doc.data()['star'] as int? ?? 0),
            );
            averageRating = totalStars / reviewsSnapshot.docs.length;
          }
        } catch (e) {
          print('Lỗi khi lấy đánh giá bãi xe ${lotId}: $e');
        }

        // Lưu thông tin vào map
        parkingLotsInfo[lotId] = {
          'address': parkingLot.address,
          'totalSlots': parkingLot.totalSlots,
          'pricePerHour': parkingLot.pricePerHour,
          'ownerPhone': ownerPhone,
          'averageRating': averageRating,
        };
      }

      emit(AllParkingLotsLoaded(parkingLotsInfo));
    } catch (e) {
      print('Lỗi khi tải thông tin tất cả bãi xe: $e');
      emit(HomeError(message: 'Không thể tải thông tin bãi xe: $e'));
    }
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

      // Tính toán số sao trung bình
      print('Đang lấy reviews cho bãi xe: ${event.parkingLotId}');
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('lotId', isEqualTo: event.parkingLotId)
          .get();

      print('Số lượng reviews: ${reviewsSnapshot.docs.length}');
      double averageRating = 0;
      if (reviewsSnapshot.docs.isNotEmpty) {
        final totalStars = reviewsSnapshot.docs.fold<int>(
          0,
          (sum, doc) {
            final star = doc.data()['star'] as int? ?? 0;
            print('Review ${doc.id}: ${star} sao');
            return sum + star;
          },
        );
        averageRating = totalStars / reviewsSnapshot.docs.length;
        print('Tổng số sao: $totalStars');
        print('Rating trung bình: $averageRating');
      }

      emit(HomeLoaded(
        address: parkingLot.address,
        totalSlots: parkingLot.totalSlots,
        pricePerHour: parkingLot.pricePerHour,
        ownerPhone: ownerPhone,
        averageRating: averageRating,
      ));
    } catch (e) {
      print('Lỗi khi tải thông tin bãi đỗ xe: $e');
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

      // Tính toán số sao trung bình
      print('Đang làm mới reviews cho bãi xe: ${event.parkingLotId}');
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('lotId', isEqualTo: event.parkingLotId)
          .get();

      print('Số lượng reviews: ${reviewsSnapshot.docs.length}');
      double averageRating = 0;
      if (reviewsSnapshot.docs.isNotEmpty) {
        final totalStars = reviewsSnapshot.docs.fold<int>(
          0,
          (sum, doc) {
            final star = doc.data()['star'] as int? ?? 0;
            print('Review ${doc.id}: ${star} sao');
            return sum + star;
          },
        );
        averageRating = totalStars / reviewsSnapshot.docs.length;
        print('Tổng số sao: $totalStars');
        print('Rating trung bình: $averageRating');
      }

      emit(HomeLoaded(
        address: parkingLot.address,
        totalSlots: parkingLot.totalSlots,
        pricePerHour: parkingLot.pricePerHour,
        ownerPhone: ownerPhone,
        averageRating: averageRating,
      ));
    } catch (e) {
      print('Lỗi khi làm mới thông tin bãi đỗ xe: $e');
      emit(HomeError(message: 'Không thể làm mới thông tin bãi đỗ xe: $e'));
    }
  }
} 