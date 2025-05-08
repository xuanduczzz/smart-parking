import 'package:cloud_firestore/cloud_firestore.dart';
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final bool isRead;
  final DateTime timestamp;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.timestamp,
  });

  factory AppNotification.fromMap(Map<String, dynamic> data, String docId) {
    return AppNotification(
      id: docId,
      userId: data['userId'],
      title: data['title'],
      body: data['body'],
      isRead: data['isRead'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'isRead': isRead,
      'timestamp': timestamp,
    };
  }
}
