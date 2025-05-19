import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/model/app_notification.dart';
part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirebaseFirestore firestore;
  StreamSubscription<QuerySnapshot>? _subscription;

  NotificationBloc(this.firestore) : super(NotificationInitial()) {
    on<LoadNotifications>((event, emit) async {
      emit(NotificationLoading());

      try {
        // Hủy subscription cũ nếu có
        await _subscription?.cancel();

        // Sử dụng emit.forEach để xử lý stream
        await emit.forEach<QuerySnapshot>(
          firestore
              .collection('notifications')
              .where('userId', isEqualTo: event.userId)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          onData: (snapshot) {
            final notifications = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return AppNotification.fromMap(data, doc.id);
            }).toList();
            return NotificationLoaded(notifications);
          },
          onError: (error, stackTrace) {
            return NotificationError("Lỗi khi lắng nghe thông báo: $error");
          },
        );
      } catch (e) {
        emit(NotificationError("Lỗi tải thông báo: $e"));
      }
    });

    on<MarkAsRead>((event, emit) async {
      try {
        await firestore.collection('notifications').doc(event.notificationId).update({
          'isRead': true,
        });
      } catch (_) {}
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
