import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park/bloc/user_bloc/user_event.dart';
import 'package:park/bloc/user_bloc/user_state.dart';
// Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  bool _isClosed = false;

  UserBloc({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(UserInitial()) {
    on<LoadUserInfo>(_onLoadUserInfo);
  }

  Future<void> _onLoadUserInfo(LoadUserInfo event, Emitter<UserState> emit) async {
    if (_isClosed) return; // Kiểm tra nếu bloc đã bị đóng thì không xử lý event

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        emit(UserError('Không tìm thấy thông tin người dùng'));
        return;
      }

      // Hủy subscription cũ nếu có
      await _userSubscription?.cancel();

      // Lấy dữ liệu ban đầu
      final doc = await _firestore.collection('user_customer').doc(userId).get();
      if (!doc.exists) {
        emit(UserError('Không tìm thấy thông tin người dùng'));
        return;
      }

      final data = doc.data()!;
      emit(UserLoaded(
        name: data['name'] ?? 'Người dùng',
        email: data['email'] ?? 'user@example.com',
        avatarUrl: data['avatar'],
      ));

      // Lắng nghe các thay đổi
      _userSubscription = _firestore
          .collection('user_customer')
          .doc(userId)
          .snapshots()
          .listen(
            (doc) {
              if (_isClosed) return; // Kiểm tra nếu bloc đã bị đóng thì không xử lý
              
              if (!doc.exists) {
                add(LoadUserInfo()); // Gửi lại event để xử lý lỗi
                return;
              }

              final data = doc.data()!;
              add(LoadUserInfo()); // Gửi lại event để cập nhật state
            },
            onError: (error) {
              if (!_isClosed) { // Kiểm tra nếu bloc chưa bị đóng thì mới emit error
                emit(UserError('Lỗi khi lắng nghe thông tin người dùng: $error'));
              }
            },
          );
    } catch (e) {
      if (!_isClosed) { // Kiểm tra nếu bloc chưa bị đóng thì mới emit error
        emit(UserError('Lỗi khi tải thông tin người dùng: $e'));
      }
    }
  }

  @override
  Future<void> close() {
    _isClosed = true; // Đánh dấu bloc đã bị đóng
    _userSubscription?.cancel();
    return super.close();
  }
} 