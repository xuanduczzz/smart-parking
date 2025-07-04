part of 'auth_bloc.dart';

/// Lớp cơ sở cho tất cả các sự kiện xác thực
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Sự kiện đăng ký tài khoản mới
/// Chứa thông tin email, mật khẩu, tên và số điện thoại của người dùng
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;

  SignUpRequested({required this.email, required this.password, required this.name, required this.phone});
}

/// Sự kiện đăng nhập
/// Chứa thông tin email và mật khẩu để đăng nhập
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

/// Sự kiện đăng xuất
/// Không yêu cầu thông tin bổ sung
class LogoutRequested extends AuthEvent {}

/// Sự kiện đặt lại mật khẩu
/// Chứa email của người dùng cần đặt lại mật khẩu
class ResetPasswordRequested extends AuthEvent {
  final String email;

  ResetPasswordRequested({required this.email});
}
