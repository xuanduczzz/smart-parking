import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:park/data/model/slots.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/data/model/reservation.dart';
import 'widget/reservation_header.dart';
import 'widget/reservation_inputs.dart';
import 'widget/reservation_summary.dart';
import 'widget/reservation_confirmation_dialog.dart';
import 'package:park/bloc/booking_bloc/booking_bloc.dart';

class ReservationPage extends StatelessWidget {
  final ParkingLot parkingLot;
  final ParkingSlot slot;
  final DateTime startTime;
  final DateTime endTime;

  const ReservationPage({
    super.key,
    required this.parkingLot,
    required this.slot,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    final _nameController = TextEditingController();
    final _phoneController = TextEditingController();

    // Tính tổng giá với cả phần 30 phút nếu có
    final totalPrice = _calculateTotalPrice(startTime, endTime, parkingLot.pricePerHour);

    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    bool _validateInputs() {
      return _nameController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          !startTime.isAfter(endTime);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt chỗ - ${slot.id}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReservationHeader(parkingLot: parkingLot, slot: slot),
            const SizedBox(height: 20),

            // 🔹 Card hiển thị thời gian
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        const Text('Thời gian bắt đầu:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(dateFormatter.format(startTime), style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.timer_off, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        const Text('Thời gian kết thúc:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(dateFormatter.format(endTime), style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            buildTextField(_nameController, 'Tên người đặt'),
            const SizedBox(height: 20),
            buildTextField(_phoneController, 'Số điện thoại', TextInputType.phone),
            const SizedBox(height: 20),
            buildTotalPrice(totalPrice),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_validateInputs()) {
                    final reservation = Reservation(
                      lotId: parkingLot.id,
                      lotName: parkingLot.name,
                      slotId: slot.id,
                      startTime: startTime,
                      endTime: endTime,
                      pricePerHour: parkingLot.pricePerHour,
                      totalPrice: totalPrice,
                      userId: _nameController.text,
                      vehicleId: "vehicleId_example",
                      phoneNumber: _phoneController.text,
                    );
                    showConfirmationDialog(context: context, reservation: reservation);
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Lỗi'),
                        content: const Text('Vui lòng nhập đầy đủ thông tin và đảm bảo ngày giờ hợp lệ.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          )
                        ],
                      ),
                    );
                  }
                },
                child: const Text('ĐẶT CHỖ', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tính tổng giá, bao gồm cả phần 30 phút
  double _calculateTotalPrice(DateTime start, DateTime end, double pricePerHour) {
    // Tính tổng số giờ
    int hours = end.difference(start).inHours;
    int minutes = end.difference(start).inMinutes % 60;

    // Nếu có 30 phút thì cộng thêm 1 giờ
    if (minutes > 0 && minutes <= 30) {
      hours += 1;
    }

    return hours * pricePerHour.toDouble();
  }
}
