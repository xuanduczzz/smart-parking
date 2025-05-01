
import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String vehicleId; // Thêm trường vehicleId
  final DateTime createdAt;
  final String licensePlate;
  final String userId;
  final String vehicleType;

  Vehicle({
    required this.vehicleId, // Thêm trường này vào constructor
    required this.createdAt,
    required this.licensePlate,
    required this.userId,
    required this.vehicleType,
  });

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId, // Bao gồm vehicleId trong map
      'createdAt': createdAt,
      'licensePlate': licensePlate,
      'userId': userId,
      'vehicleType': vehicleType,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      vehicleId: map['vehicleId'] ?? '', // Lấy vehicleId từ map
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      licensePlate: map['licensePlate'] ?? '',
      userId: map['userId'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
    );
  }
}
