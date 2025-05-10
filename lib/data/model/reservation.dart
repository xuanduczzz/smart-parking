import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String lotId;
  final String lotName;
  final String slotId;
  final DateTime startTime;
  final DateTime endTime;
  final double pricePerHour;
  final double totalPrice; // ✅ Thêm totalPrice
  final String userId;
  final String name;
  final String qrCode;
  final String vehicleId;
  final String phoneNumber;
  String status; // Changed from 'reserved' to dynamic status values

  Reservation({
    required this.id,
    required this.lotId,
    required this.lotName,
    required this.slotId,
    required this.startTime,
    required this.endTime,
    required this.pricePerHour,
    required this.totalPrice,
    required this.userId,
    required this.name,
    required this.vehicleId,
    required this.qrCode,
    required this.phoneNumber,
    this.status = 'pending', // Default status is 'pending'
  });

  Map<String, dynamic> toMap() {
    return {
      'lotId': lotId,
      'lotName': lotName,
      'slotId': slotId,
      'startTime': startTime,
      'endTime': endTime,
      'pricePerHour': pricePerHour,
      'totalPrice': totalPrice,
      'status': status,
      'qrCode': qrCode,
      'userId': userId,
      'name': name,
      'vehicleId': vehicleId,
      'phoneNumber': phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Reservation.fromMap(String id, Map<String, dynamic> map) {
    return Reservation(
      id: id,
      lotId: map['lotId'] ?? '',
      lotName: map['lotName'] ?? '',
      slotId: map['slotId'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      pricePerHour: (map['pricePerHour'] ?? 0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      qrCode: map['qrCode'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}

