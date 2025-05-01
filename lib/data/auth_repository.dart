import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Đăng ký tài khoản
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // Đăng ký người dùng với Firebase Auth
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      // Nếu đăng ký thành công, lưu thông tin người dùng vào Firestore
      if (user != null) {
        await FirebaseFirestore.instance.collection('user_customer').doc(user.uid).set({
          'email': email,
          'name': name,
          'phone': phone,
          'uid': user.uid,
        });
      }
      return user;
    } catch (e) {
      throw Exception('Đăng ký không thành công: ${e.toString()}');
    }
  }

  // Đăng nhập
  Future<User?> logIn({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Đăng nhập không thành công: ${e.toString()}');
    }
  }

  // Đăng xuất
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }
}
