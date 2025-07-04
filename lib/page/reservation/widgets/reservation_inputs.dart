import 'package:flutter/material.dart';

Widget buildDatePicker(String label, DateTime selectedDate, VoidCallback onTap) {
  return ListTile(
    title: Text(label),
    subtitle: Text('${selectedDate.toLocal()}'.split(' ')[0]),
    trailing: Icon(Icons.calendar_today),
    onTap: onTap,
  );
}

Widget buildTimePicker(String label, DateTime selectedTime, VoidCallback onTap) {
  return ListTile(
    title: Text(label),
    subtitle: Text('${selectedTime.hour}:${selectedTime.minute}'),
    trailing: Icon(Icons.access_time),
    onTap: onTap,
  );
}

Widget buildTextField(TextEditingController controller, String label, [TextInputType? keyboardType]) {
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
