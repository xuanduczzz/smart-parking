import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park/data/model/vehicle.dart'; // Đảm bảo bạn đã import Vehicle model

class VehiclesPage extends StatelessWidget {
  const VehiclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userId = currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin xe của bạn"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // List of vehicles
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('vehicles')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Có lỗi xảy ra"));
                }

                final vehicles = snapshot.data?.docs.map((doc) {
                  return Vehicle.fromMap(doc.data() as Map<String, dynamic>);
                }).toList();

                if (vehicles == null || vehicles.isEmpty) {
                  return const Center(child: Text("Bạn chưa có xe nào"));
                }

                return ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return Card(
                      margin: const EdgeInsets.all(12),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(vehicle.licensePlate),
                        subtitle: Text("Loại xe: ${vehicle.vehicleType}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            // Xác nhận xóa phương tiện
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Xác nhận xóa'),
                                content: const Text('Bạn có chắc chắn muốn xóa phương tiện này không?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              // Xóa xe khỏi Firestore
                              await FirebaseFirestore.instance
                                  .collection('vehicles')
                                  .doc(vehicle.vehicleId) // Sử dụng vehicleId làm ID của tài liệu
                                  .delete();
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Add vehicle button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _showAddVehicleDialog(context, userId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Thêm xe mới", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  // Show dialog to add new vehicle
  void _showAddVehicleDialog(BuildContext context, String userId) {
    final _licensePlateController = TextEditingController();
    final _vehicleTypeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm xe mới'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _licensePlateController,
              decoration: const InputDecoration(labelText: 'Biển số xe'),
            ),
            TextField(
              controller: _vehicleTypeController,
              decoration: const InputDecoration(labelText: 'Loại xe'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final licensePlate = _licensePlateController.text.trim();

              // Kiểm tra xem biển số xe đã tồn tại chưa
              final existingVehicle = await FirebaseFirestore.instance
                  .collection('vehicles')
                  .where('licensePlate', isEqualTo: licensePlate)
                  .get();

              if (existingVehicle.docs.isNotEmpty) {
                // Nếu biển số xe đã tồn tại, thông báo lỗi
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Lỗi'),
                    content: const Text('Biển số xe này đã tồn tại.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              } else {
                // Tạo vehicleId trùng với biển số xe và sử dụng biển số làm document ID
                final vehicleId = licensePlate;

                final vehicle = Vehicle(
                  vehicleId: vehicleId, // Sử dụng biển số xe làm vehicleId và document ID
                  createdAt: DateTime.now(),
                  licensePlate: licensePlate,
                  userId: userId,
                  vehicleType: _vehicleTypeController.text,
                );

                // Lưu xe vào Firestore với document ID là biển số xe
                await FirebaseFirestore.instance
                    .collection('vehicles')
                    .doc(vehicleId) // Sử dụng biển số xe làm document ID
                    .set(vehicle.toMap());

                Navigator.of(context).pop();
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
