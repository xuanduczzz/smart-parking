import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/vehicle.dart';

class VehicleRepository {
  final FirebaseFirestore _firestore;

  VehicleRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Vehicle>> getVehicles(String userId) {
    return _firestore
        .collection('vehicles')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Vehicle.fromMap(doc.data()))
          .toList();
    });
  }

  Future<bool> isLicensePlateExists(String licensePlate) async {
    final querySnapshot = await _firestore
        .collection('vehicles')
        .where('licensePlate', isEqualTo: licensePlate)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await _firestore
        .collection('vehicles')
        .doc(vehicle.vehicleId)
        .set(vehicle.toMap());
  }

  Future<void> deleteVehicle(String vehicleId) async {
    await _firestore.collection('vehicles').doc(vehicleId).delete();
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _firestore
        .collection('vehicles')
        .doc(vehicle.vehicleId)
        .update(vehicle.toMap());
  }
} 