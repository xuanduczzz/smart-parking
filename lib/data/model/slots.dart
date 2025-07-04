/// Class đại diện cho một đơn đặt chỗ đang chờ xử lý
class PendingReservation {
  /// ID của người dùng đặt chỗ
  final String userId;
  /// Thời gian bắt đầu đặt chỗ
  final DateTime startTime;
  /// Thời gian kết thúc đặt chỗ
  final DateTime endTime;
  /// Thời gian tạo đơn đặt chỗ
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

/// Class đại diện cho một vị trí đỗ xe
class ParkingSlot {
  /// ID của vị trí đỗ xe
  final String id;
  /// Trạng thái đã được đặt hay chưa
  final bool isBooked;
  /// Danh sách các đơn đặt chỗ đang chờ xử lý
  final List<PendingReservation> pendingReservations;
  /// Loại xe được phép đỗ
  final String vehicleType;

  ParkingSlot({
    required this.id, 
    required this.isBooked, 
    this.pendingReservations = const [],
    required this.vehicleType,
  });

  factory ParkingSlot.fromMap(Map<String, dynamic> data) {
    return ParkingSlot(
      id: data['id'] ?? '',
      isBooked: data['isBooked'] ?? false,
      pendingReservations: (data['pendingReservations'] as List<dynamic>?)?.map((e) => PendingReservation.fromMap(Map<String, dynamic>.from(e))).toList() ?? [],
      vehicleType: data['vehicleType'] ?? 'Xe con 4-5 chỗ', // Mặc định là xe con 4-5 chỗ
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isBooked': isBooked,
      'pendingReservations': pendingReservations.map((e) => e.toMap()).toList(),
      'vehicleType': vehicleType,
    };
  }
}
