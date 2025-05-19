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
import 'widgets/time_card.dart';
import 'widgets/vehicle_dropdown.dart';
import 'widgets/custom_input_field.dart';
import 'widgets/total_price_card.dart';
import 'widget/reservation_header.dart';
import 'widget/reservation_confirmation_dialog.dart';
import 'utils/reservation_utils.dart';
import 'dart:async';

class ReservationPage extends StatefulWidget {
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
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  String? selectedVehicleId;
  List<Vehicle> vehicles = [];
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _voucherController = TextEditingController();
  int discountPercent = 0;
  Timer? _timer;
  int _remainingSeconds = 180; // 3 phút = 180 giây

  @override
  void initState() {
    super.initState();
    _getVehicles();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _showTimeoutDialog();
        }
      });
    });
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hết thời gian giữ chỗ'),
        content: const Text('Thời gian giữ chỗ của bạn đã hết. Vui lòng thử lại.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/map',
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
    final totalPrice = calculateTotalPrice(
      widget.startTime,
      widget.endTime,
      widget.parkingLot.pricePerHour,
    ) * (1 - discountPercent / 100.0);

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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: _remainingSeconds <= 30 ? Colors.red : Colors.orange,
              child: Center(
                child: Text(
                  'Thời gian giữ chỗ: ${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReservationHeader(parkingLot: widget.parkingLot, slot: widget.slot),
                    const SizedBox(height: 24),
                    TimeCard(startTime: widget.startTime, endTime: widget.endTime),
                    const SizedBox(height: 24),
                    VehicleDropdown(
                      vehicles: vehicles,
                      selectedVehicleId: selectedVehicleId,
                      onChanged: (value) => setState(() => selectedVehicleId = value),
                    ),
                    const SizedBox(height: 24),
                    CustomInputField(
                      controller: _nameController,
                      label: 'Tên người đặt',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      controller: _phoneController,
                      label: 'Số điện thoại',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInputField(
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
                    TotalPriceCard(totalPrice: totalPrice),
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
                          if (validateReservationInputs(
                            name: _nameController.text,
                            phone: _phoneController.text,
                            vehicleId: selectedVehicleId,
                            startTime: widget.startTime,
                            endTime: widget.endTime,
                          )) {
                            final currentUser = FirebaseAuth.instance.currentUser!;
                            final uid = currentUser.uid;
                            final userDoc = await FirebaseFirestore.instance.collection('user_customer').doc(uid).get();
                            final nameFromFirestore = userDoc.data()?['name'] ?? _nameController.text;

                            final reservationRef = FirebaseFirestore.instance.collection('reservations').doc();
                            
                            final reservation = Reservation(
                              id: reservationRef.id,
                              lotId: widget.parkingLot.id,
                              lotName: widget.parkingLot.name,
                              slotId: widget.slot.id,
                              startTime: widget.startTime,
                              endTime: widget.endTime,
                              pricePerHour: widget.parkingLot.pricePerHour,
                              totalPrice: totalPrice,
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
          ],
        ),
      ),
    );
  }
}
