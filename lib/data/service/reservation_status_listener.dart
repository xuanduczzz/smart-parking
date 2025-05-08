import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservationStatusListener {
  static final ReservationStatusListener _instance = ReservationStatusListener._internal();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Map<String, String> _statusCache = {};
  bool _isListening = false;

  factory ReservationStatusListener() {
    return _instance;
  }

  ReservationStatusListener._internal();

  void listenToStatusChanges() {
    if (_isListening) return; // Tránh gọi lại nhiều lần
    _isListening = true;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    firestore
        .collection('reservations')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final id = doc.id;
        final newStatus = data['status'] ?? '';

        if (_statusCache.containsKey(id) && _statusCache[id] != newStatus) {
          _createStatusChangeNotification(uid, newStatus);
        }

        _statusCache[id] = newStatus;
      }
    });
  }

  Future<void> _createStatusChangeNotification(String userId, String newStatus) async {
    await firestore.collection('notifications').add({
      'userId': userId,
      'title': 'Cập nhật trạng thái đặt chỗ',
      'body': 'Trạng thái đặt chỗ của bạn đã chuyển sang: $newStatus',
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
