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

import 'bloc/auth_bloc/auth_bloc.dart';
import 'bloc/reservation_bloc/reservation_bloc.dart';
import 'bloc/booking_bloc/booking_bloc.dart';
import 'bloc/voucher_bloc/voucher_bloc.dart';
import 'bloc/notification_bloc/notification_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ThemeController.loadTheme(); // 💡 Tải theme đã lưu

  runApp(
    MultiProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(firebaseAuth: FirebaseAuth.instance)),
        BlocProvider(create: (_) => ReservationBloc(FirebaseFirestore.instance)),
        BlocProvider(create: (_) => BookingBloc(FirebaseFirestore.instance)),
        BlocProvider(create: (_) => VoucherBloc(FirebaseFirestore.instance)),
        BlocProvider(create: (_) => NotificationBloc(FirebaseFirestore.instance)),
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
          routes: AppRoutes.getRoutes(),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return snapshot.hasData ? const MapPage() : LoginScreen();
            },
          ),
        );
      },
    );
  }
}
