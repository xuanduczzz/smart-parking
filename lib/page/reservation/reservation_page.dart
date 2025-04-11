import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park/data/model/slots.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:park/page/map/map_page.dart';

import '../../data/model/reservation.dart';


class ReservationPage extends StatefulWidget {
  final ParkingLot parkingLot;
  final ParkingSlot slot;

  const ReservationPage({
    super.key,
    required this.parkingLot,
    required this.slot,
  });

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(Duration(hours: 1)); // Mặc định thời gian kết thúc là 1 giờ sau
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  // Tính tổng giá
  double get totalPrice {
    final duration = _endTime.difference(_startTime).inHours;
    return duration * widget.parkingLot.pricePerHour;
  }

  // Kiểm tra các điều kiện trước khi gửi thông tin
  bool _validateInputs() {
    // Kiểm tra nếu các trường tên và số điện thoại trống
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      return false;
    }
    // Kiểm tra nếu ngày giờ bắt đầu sau ngày giờ kết thúc
    if (_startTime.isAfter(_endTime)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt chỗ - ${widget.slot.id}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(  // Bọc toàn bộ trang trong SingleChildScrollView để cuộn
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề với thông tin vị trí
              _buildHeader(),

              SizedBox(height: 20),

              // Chọn ngày bắt đầu
              _buildDatePicker('Ngày bắt đầu', _startTime, _selectStartDate),

              // Chọn giờ bắt đầu
              _buildTimePicker('Giờ bắt đầu', _startTime, _selectStartTime),

              SizedBox(height: 20),

              // Chọn ngày kết thúc
              _buildDatePicker('Ngày kết thúc', _endTime, _selectEndDate),

              // Chọn giờ kết thúc
              _buildTimePicker('Giờ kết thúc', _endTime, _selectEndTime),

              SizedBox(height: 20),

              // Nhập tên người đặt
              _buildTextField(_nameController, 'Tên người đặt'),

              SizedBox(height: 20),

              // Nhập số điện thoại
              _buildTextField(_phoneController, 'Số điện thoại', TextInputType.phone),

              SizedBox(height: 20),

              // Hiển thị tổng giá
              _buildTotalPrice(),

              SizedBox(height: 20),

              // Nút Đặt chỗ
              _buildReserveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Tiêu đề thông tin vị trí
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vị trí: ${widget.slot.id}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        SizedBox(height: 8),
        Text(
          'Bãi đậu: ${widget.parkingLot.name}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          'Địa chỉ: ${widget.parkingLot.address}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
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

  // Hiển thị tổng giá
  Widget _buildTotalPrice() {
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

  // Nút Đặt chỗ
  Widget _buildReserveButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          if (_validateReservationInfo()) {
            _showConfirmationDialog(context);  // Hiển thị hộp thoại xác nhận
          } else {
            // Hiển thị thông báo lỗi nếu thông tin không đầy đủ hoặc ngày giờ không hợp lệ
            _showErrorDialog();
          }
        },
        child: Text('ĐẶT CHỖ', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  // Kiểm tra thông tin nhập vào
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lỗi'),
          content: Text('Vui lòng nhập đầy đủ thông tin và đảm bảo ngày bắt đầu phải trước ngày kết thúc.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Hiển thị hộp thoại xác nhận
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              _buildDialogInfo('Tên người đặt', _nameController.text),
              _buildDialogInfo('Số điện thoại', _phoneController.text),
              _buildDialogInfo('Ngày bắt đầu', '${_startTime.toLocal()}'.split(' ')[0]),
              _buildDialogInfo('Giờ bắt đầu', '${_startTime.hour}:${_startTime.minute}'),
              _buildDialogInfo('Ngày kết thúc', '${_endTime.toLocal()}'.split(' ')[0]),
              _buildDialogInfo('Giờ kết thúc', '${_endTime.hour}:${_endTime.minute}'),
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
                // Gửi sự kiện đặt chỗ khi xác nhận
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




                context.read<ReservationBloc>().add(SaveReservation(reservation: reservation));

                Navigator.of(context).pop(); // Đóng hộp thoại sau khi xác nhận

                // Chuyển tới MapPage và loại bỏ tất cả các trang trước đó trong stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MapPage()),
                      (route) => false,  // Loại bỏ tất cả các trang trong stack
                );
              },
              child: Text('Xác nhận', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
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

  // Kiểm tra các điều kiện trước khi gửi thông tin
  bool _validateReservationInfo() {
    // Kiểm tra nếu các trường tên và số điện thoại trống
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      return false;
    }
    // Kiểm tra nếu ngày giờ bắt đầu sau ngày giờ kết thúc
    if (_startTime.isAfter(_endTime)) {
      return false;
    }
    return true;
  }

  // Chọn ngày bắt đầu
  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = DateTime(picked.year, picked.month, picked.day, _startTime.hour, _startTime.minute);
      });
    }
  }

  // Chọn giờ bắt đầu
  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _startTime.hour, minute: _startTime.minute),
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(_startTime.year, _startTime.month, _startTime.day, picked.hour, picked.minute);
      });
    }
  }

  // Chọn ngày kết thúc
  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = DateTime(picked.year, picked.month, picked.day, _endTime.hour, _endTime.minute);
      });
    }
  }

  // Chọn giờ kết thúc
  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _endTime.hour, minute: _endTime.minute),
    );
    if (picked != null) {
      setState(() {
        _endTime = DateTime(_endTime.year, _endTime.month, _endTime.day, picked.hour, picked.minute);
      });
    }
  }
}
