import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/data/model/slots.dart';

class ParkingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ParkingLot>> getParkingLots() async {
    List<ParkingLot> lots = [];

    try {
      QuerySnapshot snapshot = await _firestore.collection('parking_lots').get();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String lotId = doc.id;

        // Lấy danh sách slots từ subcollection
        List<ParkingSlot> slots = await _getSlotsForLot(lotId);

        final lot = ParkingLot.fromFirestore(lotId, data).copyWith(slots: slots);
        lots.add(lot);
      }
    } catch (e) {
      print("Error fetching parking lots: $e");
    }

    return lots;
  }

  Future<List<ParkingSlot>> _getSlotsForLot(String lotId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('parking_lots')
          .doc(lotId)
          .collection('slots')
          .get();

      return snapshot.docs.map((doc) => ParkingSlot.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error fetching slots for lot $lotId: $e");
      return [];
    }
  }
}
