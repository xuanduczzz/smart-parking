class ParkingSlot {
  final String id;
  final bool isBooked;

  ParkingSlot({required this.id, required this.isBooked});

  factory ParkingSlot.fromMap(Map<String, dynamic> data) {
    return ParkingSlot(
      id: data['id'] ?? '',
      isBooked: data['isBooked'] ?? false,
    );
  }
}
