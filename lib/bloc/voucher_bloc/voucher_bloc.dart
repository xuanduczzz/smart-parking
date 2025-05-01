import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'voucher_event.dart';
part 'voucher_state.dart';

class VoucherBloc extends Bloc<VoucherEvent, VoucherState> {
  final FirebaseFirestore firestore;

  VoucherBloc(this.firestore) : super(VoucherInitial()) {
    on<CheckVoucher>((event, emit) async {
      emit(VoucherLoading());

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          emit(VoucherError("Người dùng chưa đăng nhập."));
          return;
        }

        final querySnapshot = await firestore
            .collection('vouchers')
            .where('code', isEqualTo: event.code)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          emit(VoucherInvalid("Mã không tồn tại."));
          return;
        }

        final docRef = querySnapshot.docs.first.reference;
        final data = querySnapshot.docs.first.data();

        if (data['parkingLotId'] != event.parkingLotId) {
          emit(VoucherInvalid("Mã không áp dụng cho bãi xe này."));
          return;
        }

        if (!(data['isActive'] ?? false)) {
          emit(VoucherInvalid("Mã đã bị vô hiệu."));
          return;
        }

        final expiresAt = (data['expiresAt'] as Timestamp).toDate();
        if (DateTime.now().isAfter(expiresAt)) {
          emit(VoucherInvalid("Mã đã hết hạn."));
          return;
        }

        final usedBy = List<String>.from(data['usedBy'] ?? []);
        if (usedBy.contains(currentUser.uid)) {
          emit(VoucherInvalid("Bạn đã sử dụng mã này rồi."));
          return;
        }

        final usedCount = usedBy.length + 1;
        final usageLimit = data['usageLimit'] ?? 0;

        // Cập nhật usedBy, usedCount và isActive nếu cần
        await docRef.update({
          'usedBy': FieldValue.arrayUnion([currentUser.uid]),
          'usedCount': usedCount,
          if (usedCount >= usageLimit) 'isActive': false,
        });

        emit(VoucherValid(data['discountPercent']));
      } catch (e) {
        emit(VoucherError("Lỗi: $e"));
      }
    });
  }
}
