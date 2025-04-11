import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';  // Import flutter_bloc here
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'data/auth_repository.dart';
import 'bloc/auth_bloc/auth_bloc.dart';
import 'bloc/reservation_bloc/reservation_bloc.dart'; // Import the reservation bloc
import 'package:park/page/login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Bắt buộc khi dùng async trong main()
  await Firebase.initializeApp(); // Khởi tạo Firebase

  runApp(
    MultiProvider(
      providers: [
        // Cung cấp AuthBloc
        BlocProvider(
          create: (context) => AuthBloc(authRepository: AuthRepository()),
        ),
        // Cung cấp ReservationBloc
        BlocProvider(
          create: (context) => ReservationBloc(FirebaseFirestore.instance),
        ),
      ],
      child: MaterialApp(
        home: LoginScreen(),
      ),
    ),
  );
}
