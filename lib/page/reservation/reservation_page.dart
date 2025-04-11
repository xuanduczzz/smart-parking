// main page - reservation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park/data/model/slots.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/data/model/reservation.dart';
import 'package:park/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:park/page/map/map_page.dart';
import 'widget/reservation_header.dart';
import 'widget/reservation_inputs.dart';
import 'widget/reservation_summary.dart';
import 'widget/reservation_confirmation_dialog.dart';

class ReservationPage extends StatefulWidget {
  final ParkingLot parkingLot;
  final ParkingSlot slot;

  const ReservationPage({super.key, required this.parkingLot, required this.slot});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(Duration(hours: 1));
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  double get totalPrice => _endTime.difference(_startTime).inHours * widget.parkingLot.pricePerHour;

  bool _validateInputs() {
    return _nameController.text.isNotEmpty && _phoneController.text.isNotEmpty && !_startTime.isAfter(_endTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt chỗ - \${widget.slot.id}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReservationHeader(parkingLot: widget.parkingLot, slot: widget.slot),
            const SizedBox(height: 20),
            buildDatePicker('Ngày bắt đầu', _startTime, _selectStartDate),
            buildTimePicker('Giờ bắt đầu', _startTime, _selectStartTime),
            const SizedBox(height: 20),
            buildDatePicker('Ngày kết thúc', _endTime, _selectEndDate),
            buildTimePicker('Giờ kết thúc', _endTime, _selectEndTime),
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
                      lotId: widget.parkingLot.id,
                      lotName: widget.parkingLot.name, // ✅ thêm dòng này
                      slotId: widget.slot.id,
                      startTime: _startTime,
                      endTime: _endTime,
                      pricePerHour: widget.parkingLot.pricePerHour,
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
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
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

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _startTime = DateTime(picked.year, picked.month, picked.day, _startTime.hour, _startTime.minute));
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _startTime.hour, minute: _startTime.minute),
    );
    if (picked != null) {
      setState(() => _startTime = DateTime(_startTime.year, _startTime.month, _startTime.day, picked.hour, picked.minute));
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _endTime = DateTime(picked.year, picked.month, picked.day, _endTime.hour, _endTime.minute));
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _endTime.hour, minute: _endTime.minute),
    );
    if (picked != null) {
      setState(() => _endTime = DateTime(_endTime.year, _endTime.month, _endTime.day, picked.hour, picked.minute));
    }
  }
}
