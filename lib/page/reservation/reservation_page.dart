// 🎯 Cập nhật ReservationPage: tự bọc BlocProvider cho VoucherBloc
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:park/data/model/slots.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/data/model/reservation.dart';
import 'package:park/data/model/vehicle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/bloc/voucher_bloc/voucher_bloc.dart';
import 'widget/reservation_header.dart';
import 'widget/reservation_confirmation_dialog.dart';

class ReservationPage extends StatefulWidget {
  final ParkingLot parkingLot;
  final ParkingSlot slot;
  final DateTime startTime;
  final DateTime endTime;

  const ReservationPage({super.key, required this.parkingLot, required this.slot, required this.startTime, required this.endTime});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  String? selectedVehicleId;
  List<Vehicle> vehicles = [];
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _voucherController = TextEditingController();
  int discountPercent = 0;

  @override
  void initState() {
    super.initState();
    _getVehicles();
  }

  Future<void> _getVehicles() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userId = currentUser.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('vehicles')
        .where('userId', isEqualTo: userId)
        .get();

    setState(() {
      vehicles = snapshot.docs.map((doc) {
        return Vehicle.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (outerContext) {
        return _buildReservationUI(outerContext);
      },
    );
  }

  Widget _buildReservationUI(BuildContext context) {
    final totalPrice = _calculateTotalPrice(widget.startTime, widget.endTime, widget.parkingLot.pricePerHour);
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    bool _validateInputs() {
      return _nameController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          selectedVehicleId != null &&
          !widget.startTime.isAfter(widget.endTime);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt chỗ - ${widget.slot.id}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: BlocListener<VoucherBloc, VoucherState>(
        listener: (context, state) {
          if (state is VoucherValid) {
            setState(() {
              discountPercent = state.discountPercent;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Áp dụng mã thành công! Giảm ${state.discountPercent}%")),
            );
          } else if (state is VoucherInvalid || state is VoucherError) {
            final message = state is VoucherInvalid ? state.message : (state as VoucherError).message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
            );
          }
        },

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReservationHeader(parkingLot: widget.parkingLot, slot: widget.slot),
              const SizedBox(height: 20),
              _buildTimeCard(dateFormatter),
              const SizedBox(height: 20),
              _buildVehicleDropdown(),
              const SizedBox(height: 20),
              buildTextField(_nameController, 'Tên người đặt'),
              const SizedBox(height: 20),
              buildTextField(_phoneController, 'Số điện thoại', TextInputType.phone),
              const SizedBox(height: 20),
              buildTextField(_voucherController, 'Mã khuyến mãi'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  context.read<VoucherBloc>().add(
                    CheckVoucher(code: _voucherController.text.trim(), parkingLotId: widget.parkingLot.id),
                  );
                },
                child: const Text("Áp dụng mã"),
              ),
              const SizedBox(height: 20),
              buildTotalPrice(_calculateTotalPrice(widget.startTime, widget.endTime, widget.parkingLot.pricePerHour) * (1 - discountPercent / 100.0)),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (_validateInputs()) {
                      final currentUser = FirebaseAuth.instance.currentUser!;
                      final uid = currentUser.uid;
                      final userDoc = await FirebaseFirestore.instance.collection('user_customer').doc(uid).get();
                      final nameFromFirestore = userDoc.data()?['name'] ?? _nameController.text;

                      // TÍNH GIÁ GIẢM SAU CÙNG Ở ĐÂY
                      final discountedPrice = _calculateTotalPrice(
                        widget.startTime,
                        widget.endTime,
                        widget.parkingLot.pricePerHour,
                      ) * (1 - discountPercent / 100.0);

                      final reservation = Reservation(
                        lotId: widget.parkingLot.id,
                        lotName: widget.parkingLot.name,
                        slotId: widget.slot.id,
                        startTime: widget.startTime,
                        endTime: widget.endTime,
                        pricePerHour: widget.parkingLot.pricePerHour,
                        totalPrice: discountedPrice, // GIÁ ĐÃ CẬP NHẬT
                        userId: uid,
                        name: nameFromFirestore,
                        qrCode: '',
                        vehicleId: selectedVehicleId!,
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
      ),
    );
  }

  Widget _buildTimeCard(DateFormat dateFormatter) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.access_time, color: Colors.blueAccent), const SizedBox(width: 8), const Text('Thời gian bắt đầu:', style: TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 4),
            Text(dateFormatter.format(widget.startTime), style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Row(children: [const Icon(Icons.timer_off, color: Colors.redAccent), const SizedBox(width: 8), const Text('Thời gian kết thúc:', style: TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 4),
            Text(dateFormatter.format(widget.endTime), style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    return vehicles.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Chọn xe", style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: selectedVehicleId,
          hint: const Text("Chọn xe của bạn"),
          isExpanded: true,
          onChanged: (value) => setState(() => selectedVehicleId = value),
          items: vehicles.map((vehicle) => DropdownMenuItem<String>(value: vehicle.vehicleId, child: Text(vehicle.licensePlate))).toList(),
        ),
      ],
    );
  }

  double _calculateTotalPrice(DateTime start, DateTime end, double pricePerHour) {
    int hours = end.difference(start).inHours;
    int minutes = end.difference(start).inMinutes % 60;
    if (minutes > 0 && minutes <= 30) hours += 1;
    return hours * pricePerHour.toDouble();
  }

  Widget buildTextField(TextEditingController controller, String label, [TextInputType inputType = TextInputType.text]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      keyboardType: inputType,
    );
  }

  Widget buildTotalPrice(double totalPrice) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.money, color: Colors.green),
            const SizedBox(width: 8),
            Text('Tổng giá: ${totalPrice.toStringAsFixed(2)} VND', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
