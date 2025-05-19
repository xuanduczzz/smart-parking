import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc({required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth,
        super(AuthInitial()) {
    // Đăng ký sự kiện SignUpRequested
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // Đăng ký người dùng mới với Firebase Auth
        UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        User? user = userCredential.user;

        // Lưu thông tin người dùng vào Firestore
        if (user != null) {
          await FirebaseFirestore.instance.collection('user_customer').doc(user.uid).set({
            'email': event.email,
            'name': event.name,
            'phone': event.phone,
            'uid': user.uid,
          });
        }

        emit(AuthSuccess(user: user));
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });

    // Đăng ký sự kiện LoginRequested
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // Kiểm tra email có tồn tại trong collection user_customer không
        final userQuery = await FirebaseFirestore.instance
            .collection('user_customer')
            .where('email', isEqualTo: event.email)
            .get();

        if (userQuery.docs.isEmpty) {
          emit(AuthFailure(error: 'Tài khoản không có quyền truy cập'));
          return;
        }

        // Nếu email tồn tại, tiến hành đăng nhập
        UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess(user: userCredential.user));
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });

    // Đăng ký sự kiện LogoutRequested
    on<LogoutRequested>((event, emit) async {
      await _firebaseAuth.signOut();
      emit(AuthInitial());
    });

    // Đăng ký sự kiện ResetPasswordRequested
    on<ResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // Kiểm tra email có tồn tại trong collection user_customer không
        final userQuery = await FirebaseFirestore.instance
            .collection('user_customer')
            .where('email', isEqualTo: event.email)
            .get();

        if (userQuery.docs.isEmpty) {
          emit(AuthFailure(error: 'Email không tồn tại trong hệ thống'));
          return;
        }

        // Gửi email đặt lại mật khẩu
        await _firebaseAuth.sendPasswordResetEmail(email: event.email);
        emit(AuthSuccess(user: null));
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });
  }
}