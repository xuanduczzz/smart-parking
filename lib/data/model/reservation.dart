import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String lotId;
  final String lotName;
  final String slotId;
  final DateTime startTime;
  final DateTime endTime;
  final double pricePerHour;
  final double totalPrice; // ✅ Thêm totalPrice
  final String userId;
  final String vehicleId;
  final String phoneNumber;

  Reservation({
    required this.lotId,
    required this.lotName, // thêm
    required this.slotId,
    required this.startTime,
    required this.endTime,
    required this.pricePerHour,
    required this.totalPrice,
    required this.userId,
    required this.vehicleId,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    final duration = endTime.difference(startTime).inHours;
    final computedTotal = duration * pricePerHour;

    return {
      'lotId': lotId,
      'lotName': lotName, // thêm vào map
      'slotId': slotId,
      'startTime': startTime,
      'endTime': endTime,
      'pricePerHour': pricePerHour,
      'totalPrice': computedTotal,
      'paymentStatus': 'pending',
      'qrCode': '',
      'status': 'reserved',
      'userId': userId,
      'vehicleId': vehicleId,
      'phoneNumber': phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      lotId: map['lotId'] ?? '',
      lotName: map['lotName'] ?? '', // thêm
      slotId: map['slotId'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      pricePerHour: (map['pricePerHour'] ?? 0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      userId: map['userId'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }

}
