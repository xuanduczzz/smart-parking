import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:park/controller/theme_controller.dart'; // 💡 Controller quản lý theme
import 'package:park/page/map/map_page.dart';
import 'package:park/page/login/login_screen.dart';
import 'package:park/page/settings/settings_page.dart';
import 'package:park/config/routes.dart';
import 'package:park/config/page_transitions.dart';
import 'dart:io' show Platform;

import 'bloc/auth_bloc/auth_bloc.dart';
import 'bloc/reservation_bloc/reservation_bloc.dart';
import 'bloc/booking_bloc/booking_bloc.dart';
import 'bloc/voucher_bloc/voucher_bloc.dart';
import 'bloc/notification_bloc/notification_bloc.dart';
import 'bloc/home_bloc/home_bloc.dart';
import 'package:park/bloc/vehicle/vehicle_bloc.dart';
import 'package:park/repository/vehicle_repository.dart';
import 'package:park/page/splash//splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isIOS) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDbrvIjuK53U6_FJqpwHgkqCoAM_NvWNOA',
        appId: '1:523803108804:ios:5cd45c5878b810ca5d3091',
        messagingSenderId: '523803108804',
        projectId: 'smartparkingapp-b59d5',
        storageBucket: 'smartparkingapp-b59d5.firebasestorage.app',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  
  await ThemeController.loadTheme(); // 💡 Tải theme đã lưu

  runApp(
    MultiProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(firebaseAuth: FirebaseAuth.instance)),
        BlocProvider(create: (_) => ReservationBloc(FirebaseFirestore.instance)),
        BlocProvider(create: (_) => BookingBloc(FirebaseFirestore.instance)),
        BlocProvider(create: (_) => VoucherBloc(FirebaseFirestore.instance)),
        BlocProvider(create: (_) => NotificationBloc(FirebaseFirestore.instance)),
        BlocProvider(
          create: (context) {
            final bloc = HomeBloc(firestore: FirebaseFirestore.instance);
            bloc.add(LoadAllParkingLots()); // Load tất cả thông tin bãi xe ngay khi khởi tạo
            return bloc;
          },
        ),
        BlocProvider(
          create: (context) => VehicleBloc(
            vehicleRepository: VehicleRepository(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Car Parking',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          onGenerateRoute: AppRoutes.generateRoute,
          home: const SplashScreen(),
        );
      },
    );
  }
}
