class PendingReservation {
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;

  PendingReservation({
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });

  factory PendingReservation.fromMap(Map<String, dynamic> data) {
    return PendingReservation(
      userId: data['userId'],
      startTime: DateTime.parse(data['startTime']),
      endTime: DateTime.parse(data['endTime']),
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ParkingSlot {
  final String id;
  final bool isBooked;
  final List<PendingReservation> pendingReservations;

  ParkingSlot({required this.id, required this.isBooked, this.pendingReservations = const []});

  factory ParkingSlot.fromMap(Map<String, dynamic> data) {
    return ParkingSlot(
      id: data['id'] ?? '',
      isBooked: data['isBooked'] ?? false,
      pendingReservations: (data['pendingReservations'] as List<dynamic>?)?.map((e) => PendingReservation.fromMap(Map<String, dynamic>.from(e))).toList() ?? [],
    );
  }
}
