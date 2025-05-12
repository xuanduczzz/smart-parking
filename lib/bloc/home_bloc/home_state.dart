part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String address;
  final int totalSlots;
  final double pricePerHour;
  final String ownerPhone;

  const HomeLoaded({
    required this.address,
    required this.totalSlots,
    required this.pricePerHour,
    required this.ownerPhone,
  });

  @override
  List<Object> get props => [address, totalSlots, pricePerHour, ownerPhone];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
} 