import 'package:flutter/material.dart';
import 'package:park/config/page_transitions.dart';
import 'package:park/page/map/map_page.dart';
import 'package:park/page/login/login_screen.dart';
import 'package:park/page/login/signup_screen.dart';
import 'package:park/page/splash/splash_screen.dart';
import 'package:park/page/home/home_page.dart';
import 'package:park/page/profile/profile_page.dart';
import 'package:park/page/reservation_history/reservation_history_page.dart';
import 'package:park/page/vehicle/vehicle_page.dart';
import 'package:park/page/settings/settings_page.dart';
import 'package:park/page/search/search_page.dart';
import 'package:park/page/notifications/notificationpage.dart';
import 'package:park/page/reviews/my_reviews_screen.dart';
import 'package:park/page/booking/booking_page.dart';
import 'package:park/page/booking/booking_slot_page.dart';
import 'package:park/page/reviews/review_screen.dart';
import 'package:park/data/model/parking_lot.dart';

class AppRoutes {
  static const String splash = '/';
  static const String map = '/map';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String reservationHistory = '/reservation-history';
  static const String vehicles = '/vehicles';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String myReviews = '/my-reviews';
  static const String booking = '/booking';
  static const String bookingSlot = '/booking-slot';
  static const String review = '/review';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String? routeName = settings.name;
    
    if (routeName == null) {
      return _buildErrorRoute('Route name is null');
    }

    if (routeName == AppRoutes.splash) {
      return PageTransitions.fadeTransition(const SplashScreen());
    } else if (routeName == AppRoutes.map) {
      return PageTransitions.fadeTransition(MapPage());
    } else if (routeName == AppRoutes.login) {
      return PageTransitions.scaleTransition(LoginScreen());
    } else if (routeName == AppRoutes.signup) {
      return PageTransitions.scaleTransition(SignUpScreen());
    } else if (routeName == AppRoutes.home) {
      final args = settings.arguments as Map<String, dynamic>?;
      if (args == null || !args.containsKey('parkingLot')) {
        return _buildErrorRoute('Invalid arguments for home route');
      }
      return PageTransitions.slideTransition(
        HomePage(parkingLot: args['parkingLot'] as ParkingLot),
      );
    } else if (routeName == AppRoutes.profile) {
      return PageTransitions.customTransition(ProfileScreen());
    } else if (routeName == AppRoutes.reservationHistory) {
      return PageTransitions.customTransition(ReservationHistoryPage());
    } else if (routeName == AppRoutes.vehicles) {
      return PageTransitions.slideTransition(VehiclesPage());
    } else if (routeName == AppRoutes.settings) {
      return PageTransitions.slideTransition(const SettingsPage());
    } else if (routeName == AppRoutes.search) {
      return PageTransitions.slideTransition(SearchPage());
    } else if (routeName == AppRoutes.notifications) {
      return PageTransitions.customTransition(NotificationPage());
    } else if (routeName == AppRoutes.myReviews) {
      return PageTransitions.slideTransition(MyReviewsScreen());
    } else if (routeName == AppRoutes.booking) {
      final args = settings.arguments as Map<String, dynamic>?;
      if (args == null || !args.containsKey('parkingLot')) {
        return _buildErrorRoute('Invalid arguments for booking route');
      }
      return PageTransitions.slideTransition(
        BookingPage(parkingLot: args['parkingLot'] as ParkingLot),
      );
    } else if (routeName == AppRoutes.bookingSlot) {
      final args = settings.arguments as Map<String, dynamic>?;
      if (args == null || 
          !args.containsKey('parkingLot') ||
          !args.containsKey('selectedDate') ||
          !args.containsKey('startTime') ||
          !args.containsKey('endTime')) {
        return _buildErrorRoute('Invalid arguments for booking slot route');
      }
      return PageTransitions.slideTransition(
        BookingSlotPage(
          parkingLot: args['parkingLot'] as ParkingLot,
          selectedDate: args['selectedDate'] as DateTime,
          startTime: args['startTime'] as TimeOfDay,
          endTime: args['endTime'] as TimeOfDay,
        ),
      );
    } else if (routeName == AppRoutes.review) {
      final args = settings.arguments as Map<String, dynamic>?;
      if (args == null || !args.containsKey('reservationId')) {
        return _buildErrorRoute('Invalid arguments for review route');
      }
      return PageTransitions.slideTransition(
        ReviewScreen(reservationId: args['reservationId'] as String),
      );
    } else {
      return _buildErrorRoute('Route not found: $routeName');
    }
  }

  static Route<dynamic> _buildErrorRoute(String message) {
    return PageTransitions.fadeTransition(
      Scaffold(
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}
