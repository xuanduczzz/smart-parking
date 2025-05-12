import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/slots.dart';

class ParkingLot {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int totalSlots;
  final int availableSlots;
  final double pricePerHour;
  final List<String> imageUrls;
  final List<ParkingSlot> slots;
  final List<String> parkingLotMap;
  final String oid;

  ParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.totalSlots,
    required this.availableSlots,
    required this.pricePerHour,
    required this.imageUrls,
    required this.slots,
    required this.parkingLotMap,
    required this.oid,
  });

  factory ParkingLot.fromFirestore(String id, Map<String, dynamic> data) {
    GeoPoint point = data['location'];
    List<dynamic> imagesRaw = data['imageUrl'] ?? [];

    return ParkingLot(
      id: id,
      name: data['name'] ?? 'Unnamed',
      address: data['address'] ?? 'Chưa có địa chỉ',
      latitude: point.latitude,
      longitude: point.longitude,
      totalSlots: data['totalSlots'] ?? 0,
      availableSlots: data['availableSlots'] ?? 0,
      pricePerHour: double.tryParse(
        data['pricePerHour'].toString().replaceAll('đ', '').replaceAll(',', ''),
      ) ??
          0,
      imageUrls: imagesRaw.map((e) => e.toString()).toList(),
      slots: [], // Sẽ được gán sau từ Firestore
      parkingLotMap: (data['parkingLotMap'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      oid: data['oid'] ?? '',
    );
  }

  ParkingLot copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? totalSlots,
    int? availableSlots,
    double? pricePerHour,
    List<String>? imageUrls,
    List<ParkingSlot>? slots,
    List<String>? parkingLotMap,
    String? oid,
  }) {
    return ParkingLot(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalSlots: totalSlots ?? this.totalSlots,
      availableSlots: availableSlots ?? this.availableSlots,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      imageUrls: imageUrls ?? this.imageUrls,
      slots: slots ?? this.slots,
      parkingLotMap: parkingLotMap ?? this.parkingLotMap,
      oid: oid ?? this.oid,
    );
  }
}
