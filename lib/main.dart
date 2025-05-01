import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import flutter_bloc here
import 'package:firebase_core/firebase_core.dart';
import 'package:park/page/map/map_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/auth_repository.dart';
import 'bloc/auth_bloc/auth_bloc.dart';
import 'bloc/reservation_bloc/reservation_bloc.dart'; // Import the reservation bloc
import 'package:park/page/login/login_screen.dart';
import 'package:park/bloc/booking_bloc/booking_bloc.dart';
import 'package:park/page/settings/settings_page.dart'; // Import SettingsPage
import 'package:park/bloc/voucher_bloc/voucher_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Bắt buộc khi dùng async trong main()
  await Firebase.initializeApp(); // Khởi tạo Firebase

  // Đọc cài đặt từ SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  bool isVietnamese = prefs.getBool('isVietnamese') ?? false;

  runApp(
    MultiProvider(
      providers: [
        // Cung cấp AuthBloc
        BlocProvider(
          create: (context) => AuthBloc(firebaseAuth: FirebaseAuth.instance),
        ),
        // Cung cấp ReservationBloc
        BlocProvider(
          create: (context) => ReservationBloc(FirebaseFirestore.instance),
        ),
        BlocProvider(
          create: (context) => BookingBloc(FirebaseFirestore.instance),
        ),
        BlocProvider(
          create: (_) => VoucherBloc(FirebaseFirestore.instance),
        ),

      ],
      child: MyApp(isDarkMode: isDarkMode, isVietnamese: isVietnamese),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;
  final bool isVietnamese;

  MyApp({required this.isDarkMode, required this.isVietnamese});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Parking',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(), // Thay đổi theme theo cài đặt
      locale: isVietnamese ? Locale('vi', 'VN') : Locale('en', 'US'), // Thay đổi ngôn ngữ
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            return MapPage(); // Nếu người dùng đã đăng nhập, chuyển tới MapPage
          } else {
            return LoginScreen(); // Nếu người dùng chưa đăng nhập, chuyển tới LoginScreen
          }
        },
      ),
    );
  }
}
