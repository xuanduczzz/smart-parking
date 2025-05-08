import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/model/app_notification.dart';
part 'notification_event.dart';
part 'notification_state.dart';


class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirebaseFirestore firestore;

  NotificationBloc(this.firestore) : super(NotificationInitial()) {
    on<LoadNotifications>((event, emit) async {
      emit(NotificationLoading());

      try {
        final snapshot = await firestore
            .collection('notifications')
            .where('userId', isEqualTo: event.userId)
            .orderBy('timestamp', descending: true)
            .get();

        final notifications = snapshot.docs
            .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
            .toList();

        emit(NotificationLoaded(notifications));
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
}
