import 'package:flutter/material.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/widgets/custom_date_picker.dart';
import 'package:park/page/booking/booking_slot_page.dart';
import 'package:park/config/colors.dart';
import 'package:park/config/routes.dart';
import 'package:park/page/booking//utils/booking_validator.dart';

class BookingPage extends StatefulWidget {
  final ParkingLot parkingLot;

  const BookingPage({super.key, required this.parkingLot});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = BookingValidator.getDefaultStartTime();
  TimeOfDay _endTime = BookingValidator.getDefaultEndTime();
  String? _errorMessage;

  bool _isValidDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    return selected.isAfter(today) || selected.isAtSameMomentAs(today);
  }

  bool _isValidTimeForToday(TimeOfDay time) {
    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    
    // Chuyển đổi thời gian thành phút để so sánh
    final timeInMinutes = time.hour * 60 + time.minute;
    final currentTimeInMinutes = currentTime.hour * 60 + currentTime.minute;
    
    return timeInMinutes >= currentTimeInMinutes;
  }

  bool _isValidTimeRange(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final duration = endMinutes - startMinutes;
    
    if (duration <= 0) return false;
    if (duration > 24 * 60) return false; // Không cho phép đặt quá 24 giờ
    
    // Kiểm tra nếu là ngày hiện tại
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    
    if (selected.isAtSameMomentAs(today)) {
      if (!_isValidTimeForToday(start)) return false;
    }
    
    return true;
  }

  void _validateAndUpdateTime(TimeOfDay newStartTime, TimeOfDay newEndTime) {
    setState(() {
      _errorMessage = BookingValidator.validateBookingTime(_selectedDate, newStartTime, newEndTime);
      if (_errorMessage == null) {
        _startTime = newStartTime;
        _endTime = newEndTime;
      }
    });
  }

  void _validateAndUpdateDate(DateTime newDate) {
    setState(() {
      _errorMessage = BookingValidator.validateBookingTime(newDate, _startTime, _endTime);
      if (_errorMessage == null) {
        _selectedDate = newDate;
      } else {
        // Nếu là ngày hiện tại, cập nhật thời gian mặc định
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final selected = DateTime(newDate.year, newDate.month, newDate.day);
        
        if (selected.isAtSameMomentAs(today)) {
          _startTime = BookingValidator.getDefaultStartTime();
          _endTime = BookingValidator.getDefaultEndTime();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Đặt chỗ - ${widget.parkingLot.name}',
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
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Thông tin bãi đỗ xe
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: blueColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.local_parking, color: blueColor, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.parkingLot.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.parkingLot.address,
                                        style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoItem(
                                  context,
                                  Icons.attach_money,
                                  "Giá",
                                  "${widget.parkingLot.pricePerHour} VND/giờ",
                                ),
                                _buildInfoItem(
                                  context,
                                  Icons.local_parking,
                                  "Chỗ trống",
                                  "${widget.parkingLot.totalSlots} chỗ",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Widget chọn thời gian
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Chọn thời gian đặt chỗ",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            BookingTimePickerWidget(
                              selectedDate: _selectedDate,
                              startTime: _startTime,
                              endTime: _endTime,
                              onDateChanged: _validateAndUpdateDate,
                              onStartTimeChanged: (time) => _validateAndUpdateTime(time, _endTime),
                              onEndTimeChanged: (time) => _validateAndUpdateTime(_startTime, time),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Nút "Tiếp tục"
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _errorMessage != null ? null : () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.bookingSlot,
                        arguments: {
                          'parkingLot': widget.parkingLot,
                          'selectedDate': _selectedDate,
                          'startTime': _startTime,
                          'endTime': _endTime,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Tiếp tục",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: blueColor, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}