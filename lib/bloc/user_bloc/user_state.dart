abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final String name;
  final String email;
  final String? avatarUrl;

  UserLoaded({
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
} 