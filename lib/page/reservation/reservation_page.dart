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
import 'package:park/config/colors.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Đặt chỗ - ${widget.slot.id}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: blueColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReservationHeader(parkingLot: widget.parkingLot, slot: widget.slot),
              const SizedBox(height: 24),
              _buildTimeCard(dateFormatter),
              const SizedBox(height: 24),
              _buildVehicleDropdown(),
              const SizedBox(height: 24),
              _buildInputField(
                controller: _nameController,
                label: 'Tên người đặt',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                controller: _phoneController,
                label: 'Số điện thoại',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _voucherController,
                      label: 'Mã giảm giá (nếu có)',
                      icon: Icons.local_offer_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  BlocListener<VoucherBloc, VoucherState>(
                    listener: (context, state) {
                      if (state is VoucherValid) {
                        setState(() {
                          discountPercent = state.discountPercent;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Áp dụng mã thành công! Giảm ${state.discountPercent}%"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else if (state is VoucherInvalid || state is VoucherError) {
                        final message = state is VoucherInvalid ? state.message : (state as VoucherError).message;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<VoucherBloc>().add(
                          CheckVoucher(code: _voucherController.text.trim(), parkingLotId: widget.parkingLot.id),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Áp dụng",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (discountPercent > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.discount, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Đã áp dụng giảm giá $discountPercent%',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildTotalPrice(),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  onPressed: () async {
                    if (_validateInputs()) {
                      final currentUser = FirebaseAuth.instance.currentUser!;
                      final uid = currentUser.uid;
                      final userDoc = await FirebaseFirestore.instance.collection('user_customer').doc(uid).get();
                      final nameFromFirestore = userDoc.data()?['name'] ?? _nameController.text;

                      final discountedPrice = _calculateTotalPrice(
                        widget.startTime,
                        widget.endTime,
                        widget.parkingLot.pricePerHour,
                      ) * (1 - discountPercent / 100.0);

                      // Tạo document reference mới để lấy ID
                      final reservationRef = FirebaseFirestore.instance.collection('reservations').doc();
                      
                      final reservation = Reservation(
                        id: reservationRef.id,
                        lotId: widget.parkingLot.id,
                        lotName: widget.parkingLot.name,
                        slotId: widget.slot.id,
                        startTime: widget.startTime,
                        endTime: widget.endTime,
                        pricePerHour: widget.parkingLot.pricePerHour,
                        totalPrice: discountedPrice,
                        userId: uid,
                        name: nameFromFirestore,
                        qrCode: '',
                        vehicleId: selectedVehicleId!,
                        phoneNumber: _phoneController.text,
                      );

                      // Sử dụng reservationRef để lưu dữ liệu
                      await reservationRef.set(reservation.toMap());

                      showConfirmationDialog(context: context, reservation: reservation);
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          title: const Text('Lỗi'),
                          content: const Text('Vui lòng nhập đầy đủ thông tin và đảm bảo ngày giờ hợp lệ.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('OK', style: TextStyle(color: blueColor)),
                            )
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'ĐẶT CHỖ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Thời gian bắt đầu:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dateFormatter.format(widget.startTime),
                style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.timer_off, color: Colors.red[400]),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Thời gian kết thúc:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dateFormatter.format(widget.endTime),
                style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    return vehicles.isEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chọn xe",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "Bạn chưa có xe nào. Vui lòng thêm xe trước khi đặt chỗ.",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chọn xe",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: selectedVehicleId,
                  hint: Text("Chọn xe của bạn", style: TextStyle(color: Theme.of(context).hintColor)),
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: Theme.of(context).cardColor,
                  onChanged: (value) => setState(() => selectedVehicleId = value),
                  items: vehicles.map((vehicle) => DropdownMenuItem<String>(
                    value: vehicle.vehicleId,
                    child: Text(vehicle.licensePlate, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  )).toList(),
                ),
              ),
            ],
          );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: blueColor),
          labelStyle: TextStyle(color: Theme.of(context).hintColor),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: blueColor),
          ),
        ),
      ),
    );
  }

  double _calculateTotalPrice(DateTime start, DateTime end, double pricePerHour) {
    int hours = end.difference(start).inHours;
    int minutes = end.difference(start).inMinutes % 60;
    if (minutes > 0 && minutes <= 30) hours += 1;
    return hours * pricePerHour.toDouble();
  }

  Widget _buildTotalPrice() {
    final discountedPrice = _calculateTotalPrice(widget.startTime, widget.endTime, widget.parkingLot.pricePerHour) * (1 - discountPercent / 100.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tổng tiền:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            '${discountedPrice.toStringAsFixed(0)} VND',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: blueColor,
            ),
          ),
        ],
      ),
    );
  }
}
