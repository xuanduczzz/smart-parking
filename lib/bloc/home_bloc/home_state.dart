part of 'home_bloc.dart';

@immutable
abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final String address;
  final int totalSlots;
  final double pricePerHour;
  final String ownerPhone;
  final double averageRating;

  const HomeLoaded({
    required this.address,
    required this.totalSlots,
    required this.pricePerHour,
    required this.ownerPhone,
    required this.averageRating,
  });
}

class AllParkingLotsLoaded extends HomeState {
  final Map<String, Map<String, dynamic>> parkingLotsInfo;

  const AllParkingLotsLoaded(this.parkingLotsInfo);
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});
} 