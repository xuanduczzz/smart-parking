import 'package:flutter/material.dart';
import 'package:park/data/model/reservation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:park/page/map/map_page.dart';
import 'package:park/bloc/booking_bloc/booking_bloc.dart';

void showConfirmationDialog({
  required BuildContext context,
  required Reservation reservation,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Xác nhận thông tin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogInfo('Tên người đặt', reservation.userId),
            _buildDialogInfo('Số điện thoại', reservation.phoneNumber),
            _buildDialogInfo('Ngày bắt đầu', '${reservation.startTime.toLocal()}'.split(' ')[0]),
            _buildDialogInfo('Giờ bắt đầu', '${reservation.startTime.hour}:${reservation.startTime.minute}'),
            _buildDialogInfo('Ngày kết thúc', '${reservation.endTime.toLocal()}'.split(' ')[0]),
            _buildDialogInfo('Giờ kết thúc', '${reservation.endTime.hour}:${reservation.endTime.minute}'),
            _buildDialogInfo('Tổng giá', '${reservation.totalPrice.toStringAsFixed(2)} VND'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Hủy', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              context.read<ReservationBloc>().add(SaveReservation(reservation: reservation));
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MapPage()), (_) => false);
            },
            child: Text('Xác nhận', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      );
    },
  );
}

Widget _buildDialogInfo(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Text('$label: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: 16)),
      ],
    ),
  );
}
