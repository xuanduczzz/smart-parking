// reservation_form.dart
import 'package:flutter/material.dart';

class ReservationForm extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final Function onStartDateSelected;
  final Function onStartTimeSelected;
  final Function onEndDateSelected;
  final Function onEndTimeSelected;

  const ReservationForm({
    Key? key,
    required this.startTime,
    required this.endTime,
    required this.nameController,
    required this.phoneController,
    required this.onStartDateSelected,
    required this.onStartTimeSelected,
    required this.onEndDateSelected,
    required this.onEndTimeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chọn ngày bắt đầu
        _buildDatePicker('Ngày bắt đầu', startTime, onStartDateSelected),

        // Chọn giờ bắt đầu
        _buildTimePicker('Giờ bắt đầu', startTime, onStartTimeSelected),

        SizedBox(height: 20),

        // Chọn ngày kết thúc
        _buildDatePicker('Ngày kết thúc', endTime, onEndDateSelected),

        // Chọn giờ kết thúc
        _buildTimePicker('Giờ kết thúc', endTime, onEndTimeSelected),

        SizedBox(height: 20),

        // Nhập tên người đặt
        _buildTextField(nameController, 'Tên người đặt'),

        SizedBox(height: 20),

        // Nhập số điện thoại
        _buildTextField(phoneController, 'Số điện thoại', TextInputType.phone),
      ],
    );
  }

  // Chọn ngày (DatePicker)
  Widget _buildDatePicker(String label, DateTime selectedDate, Function onTap) {
    return ListTile(
      title: Text(label),
      subtitle: Text('${selectedDate.toLocal()}'.split(' ')[0]),
      trailing: Icon(Icons.calendar_today),
      onTap: () => onTap(),
    );
  }

  // Chọn giờ (TimePicker)
  Widget _buildTimePicker(String label, DateTime selectedTime, Function onTap) {
    return ListTile(
      title: Text(label),
      subtitle: Text('${selectedTime.hour}:${selectedTime.minute}'),
      trailing: Icon(Icons.access_time),
      onTap: () => onTap(),
    );
  }

  // TextField chung cho tên và số điện thoại
  Widget _buildTextField(TextEditingController controller, String label, [TextInputType? keyboardType]) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
