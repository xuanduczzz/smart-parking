part of 'voucher_bloc.dart';

abstract class VoucherEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckVoucher extends VoucherEvent {
  final String code;
  final String parkingLotId;

  CheckVoucher({required this.code, required this.parkingLotId});

  @override
  List<Object> get props => [code, parkingLotId];
}

