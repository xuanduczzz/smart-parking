import 'package:flutter/material.dart';
import 'package:park/page/map/map_page.dart';
import 'package:park/page/login/login_screen.dart';
import 'package:park/page/login/signup_screen.dart';
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
import 'package:park/presentation/screens/review_screen.dart';
import 'package:park/data/model/parking_lot.dart';

class AppRoutes {
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

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      map: (context) => const MapPage(),
      login: (context) => LoginScreen(),
      signup: (context) => SignUpScreen(),
      home: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return HomePage(parkingLot: args['parkingLot'] as ParkingLot);
      },
      profile: (context) => ProfileScreen(),
      reservationHistory: (context) => const ReservationHistoryPage(),
      vehicles: (context) => const VehiclesPage(),
      settings: (context) => const SettingsPage(),
      search: (context) => SearchPage(),
      notifications: (context) => const NotificationPage(),
      myReviews: (context) => const MyReviewsScreen(),
      booking: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return BookingPage(parkingLot: args['parkingLot'] as ParkingLot);
      },
      bookingSlot: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return BookingSlotPage(
          parkingLot: args['parkingLot'] as ParkingLot,
          selectedDate: args['selectedDate'] as DateTime,
          startTime: args['startTime'] as TimeOfDay,
          endTime: args['endTime'] as TimeOfDay,
        );
      },
      review: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ReviewScreen(reservationId: args['reservationId'] as String);
      },
    };
  }
}
