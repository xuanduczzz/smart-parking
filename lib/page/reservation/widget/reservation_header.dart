import 'package:flutter/material.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/data/model/slots.dart';

class ReservationHeader extends StatelessWidget {
  final ParkingLot parkingLot;
  final ParkingSlot slot;

  const ReservationHeader({required this.parkingLot, required this.slot, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vị trí: ${slot.id}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        SizedBox(height: 8),
        Text('Bãi đậu: ${parkingLot.name}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Text('Địa chỉ: ${parkingLot.address}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
