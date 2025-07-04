part of 'auth_bloc.dart';

/// Lớp cơ sở cho tất cả các trạng thái xác thực
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Trạng thái khởi tạo của quá trình xác thực
class AuthInitial extends AuthState {}

/// Trạng thái đang xử lý xác thực (loading)
class AuthLoading extends AuthState {}

/// Trạng thái xác thực thành công
/// Chứa thông tin người dùng đã xác thực
class AuthSuccess extends AuthState {
  final User? user;

  AuthSuccess({required this.user});
}

/// Trạng thái xác thực thất bại
/// Chứa thông báo lỗi
class AuthFailure extends AuthState {
  final String error;

  AuthFailure({required this.error});
}
