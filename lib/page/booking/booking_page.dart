import 'package:flutter/material.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/widgets/custom_date_picker.dart';
import 'package:park/page/booking/booking_slot_page.dart';

class BookingPage extends StatefulWidget {
  final ParkingLot parkingLot;

  const BookingPage({super.key, required this.parkingLot});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt chỗ - ${widget.parkingLot.name}'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16), // Thêm padding cho toàn bộ body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Giúp các phần tử chiếm hết chiều ngang
          children: [
            // Widget chọn thời gian
            BookingTimePickerWidget(
              selectedDate: _selectedDate,
              startTime: _startTime,
              endTime: _endTime,
              onDateChanged: (date) => setState(() => _selectedDate = date),
              onStartTimeChanged: (time) => setState(() => _startTime = time),
              onEndTimeChanged: (time) => setState(() => _endTime = time),
            ),

            const SizedBox(height: 20), // Thêm khoảng cách giữa các phần tử

            // Dùng Spacer để đẩy nút xuống dưới cùng
            Spacer(),

            // Nút "Chọn Slot Đặt Chỗ" đẹp hơn
            ElevatedButton(
              onPressed: () {
                // Chuyển sang trang booking slot với thông tin thời gian đã chọn
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingSlotPage(
                      parkingLot: widget.parkingLot,
                      selectedDate: _selectedDate,
                      startTime: _startTime,
                      endTime: _endTime,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // Màu chữ trên nút
                backgroundColor: Colors.blue, // Màu nền của nút
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 35), // Điều chỉnh padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Bo tròn góc
                ),
                elevation: 10, // Đổ bóng cho nút
                shadowColor: Colors.blueAccent, // Màu bóng của nút
              ),
              child: Text(
                'Coutinue',
                style: TextStyle(
                  fontSize: 20, // Kích thước chữ lớn hơn
                  fontWeight: FontWeight.bold, // Đậm chữ
                ),
              ),
            ),

            const SizedBox(height: 20), // Khoảng cách phía dưới
          ],
        ),
      ),
    );
  }
}