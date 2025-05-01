part of 'voucher_bloc.dart';

abstract class VoucherState extends Equatable {
  @override
  List<Object> get props => [];
}

class VoucherInitial extends VoucherState {}

class VoucherLoading extends VoucherState {}

class VoucherValid extends VoucherState {
  final int discountPercent;

  VoucherValid(this.discountPercent);

  @override
  List<Object> get props => [discountPercent];
}

class VoucherInvalid extends VoucherState {
  final String message;

  VoucherInvalid(this.message);

  @override
  List<Object> get props => [message];
}

class VoucherError extends VoucherState {
  final String message;

  VoucherError(this.message);

  @override
  List<Object> get props => [message];
}
