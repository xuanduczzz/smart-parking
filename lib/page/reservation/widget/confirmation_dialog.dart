// confirmation_dialog.dart
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final Function onConfirm;

  const ConfirmationDialog({
    Key? key,
    required this.nameController,
    required this.phoneController,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        'Xác nhận thông tin',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogInfo('Tên người đặt', nameController.text),
          _buildDialogInfo('Số điện thoại', phoneController.text),
          _buildDialogInfo('Ngày bắt đầu', '${startTime.toLocal()}'.split(' ')[0]),
          _buildDialogInfo('Giờ bắt đầu', '${startTime.hour}:${startTime.minute}'),
          _buildDialogInfo('Ngày kết thúc', '${endTime.toLocal()}'.split(' ')[0]),
          _buildDialogInfo('Giờ kết thúc', '${endTime.hour}:${endTime.minute}'),
          _buildDialogInfo('Tổng giá', '${totalPrice.toStringAsFixed(2)} VND'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Đóng hộp thoại nếu không xác nhận
          },
          child: Text('Hủy', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () {
            onConfirm(); // Xác nhận
            Navigator.of(context).pop(); // Đóng hộp thoại sau khi xác nhận
          },
          child: Text('Xác nhận', style: TextStyle(color: Colors.blueAccent)),
        ),
      ],
    );
  }

  // Helper widget để hiển thị thông tin trong hộp thoại
  Widget _buildDialogInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
