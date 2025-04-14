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
  DateTime? _selectedDate;  // Khởi tạo là nullable
  TimeOfDay? _startTime;    // Khởi tạo là nullable
  TimeOfDay? _endTime;      // Khởi tạo là nullable

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
              selectedDate: _selectedDate ?? DateTime.now(),  // Nếu _selectedDate là null, sử dụng ngày hiện tại
              startTime: _startTime ,      // Nếu _startTime là null, sử dụng giờ hiện tại
              endTime: _endTime ,          // Nếu _endTime là null, sử dụng giờ hiện tại
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
                // Kiểm tra nếu ngày và giờ chưa được chọn
                if (_selectedDate == null || _startTime == null || _endTime == null) {
                  // Hiển thị thông báo nếu chưa chọn đầy đủ
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Thông báo'),
                      content: const Text('Vui lòng chọn đầy đủ ngày và giờ!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                } else {
                  // Nếu đã chọn đầy đủ, chuyển sang trang tiếp theo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingSlotPage(
                        parkingLot: widget.parkingLot,
                        selectedDate: _selectedDate!,
                        startTime: _startTime!,
                        endTime: _endTime!,
                      ),
                    ),
                  );
                }
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
                'Continue',
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
