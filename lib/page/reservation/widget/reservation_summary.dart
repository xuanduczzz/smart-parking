import 'package:flutter/material.dart';

Widget buildTotalPrice(double totalPrice) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Tổng giá:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('${totalPrice.toStringAsFixed(2)} VND', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
        ],
      ),
    ),
  );
}
