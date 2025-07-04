import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/widgets/custom_date_picker.dart';
import 'package:park/page/booking/booking_slot_page.dart';
import 'package:park/config/colors.dart';
import 'package:park/config/routes.dart';
import 'package:park/page/booking//utils/booking_validator.dart';
import 'package:park/widgets/car_dropdown.dart';
import 'package:park/bloc/booking_bloc/booking_bloc.dart';

/// Trang đặt chỗ đỗ xe
/// Cho phép người dùng chọn thời gian và xem thông tin bãi đỗ xe
class BookingPage extends StatefulWidget {
  /// Thông tin bãi đỗ xe được chọn
  final ParkingLot parkingLot;

  const BookingPage({super.key, required this.parkingLot});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  /// Ngày được chọn để đặt chỗ
  DateTime _selectedDate = DateTime.now();
  /// Thời gian bắt đầu đặt chỗ
  TimeOfDay _startTime = BookingValidator.getDefaultStartTime();
  /// Thời gian kết thúc đặt chỗ
  TimeOfDay _endTime = BookingValidator.getDefaultEndTime();
  /// Thông báo lỗi khi chọn thời gian không hợp lệ
  String? _errorMessage;
  /// Loại xe được chọn
  String? _selectedVehicleType;

  String selectedVehicle = 'Car'; // mặc định là Car

  /// Gọi sự kiện load slots từ bloc
  void _loadSlots() {
    if (_errorMessage != null || _selectedVehicleType == null) return;

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    context.read<BookingBloc>().add(LoadSlots(
      widget.parkingLot.id,
      startDateTime,
      endDateTime,
      _selectedVehicleType!,
    ));
  }

  /// Kiểm tra xem ngày được chọn có hợp lệ không
  /// Ngày phải là ngày hiện tại hoặc trong tương lai
  bool _isValidDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    return selected.isAfter(today) || selected.isAtSameMomentAs(today);
  }

  /// Kiểm tra xem thời gian được chọn cho ngày hiện tại có hợp lệ không
  /// Thời gian phải sau thời gian hiện tại
  bool _isValidTimeForToday(TimeOfDay time) {
    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final timeInMinutes = time.hour * 60 + time.minute;
    final currentTimeInMinutes = currentTime.hour * 60 + currentTime.minute;
    return timeInMinutes >= currentTimeInMinutes;
  }

  /// Kiểm tra xem khoảng thời gian đặt chỗ có hợp lệ không
  /// - Thời gian kết thúc phải sau thời gian bắt đầu
  /// - Khoảng thời gian không được quá 24 giờ
  /// - Nếu là ngày hiện tại, thời gian bắt đầu phải sau thời gian hiện tại
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

  /// Cập nhật thời gian đặt chỗ và kiểm tra tính hợp lệ
  void _validateAndUpdateTime(TimeOfDay newStartTime, TimeOfDay newEndTime) {
    setState(() {
      _errorMessage = BookingValidator.validateBookingTime(_selectedDate, newStartTime, newEndTime);
      if (_errorMessage == null) {
        _startTime = newStartTime;
        _endTime = newEndTime;
        _loadSlots();
      }
    });
  }

  /// Cập nhật ngày đặt chỗ và kiểm tra tính hợp lệ
  /// Nếu chọn ngày hiện tại, sẽ cập nhật thời gian mặc định
  void _validateAndUpdateDate(DateTime newDate) {
    setState(() {
      _errorMessage = BookingValidator.validateBookingTime(newDate, _startTime, _endTime);
      if (_errorMessage == null) {
        _selectedDate = newDate;
        _loadSlots();
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
                      const SizedBox(height: 16),
                      // Widget chọn loại xe
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
                              "Chọn loại xe",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CarDropdown(
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedVehicleType = value;
                                  if (value != null) {
                                    _loadSlots();
                                  }
                                });
                              },
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
                      // Hiển thị số lượng chỗ trống khi đã nhập đủ thông tin
                      if (_errorMessage == null && _selectedVehicleType != null)
                        BlocBuilder<BookingBloc, BookingState>(
                          builder: (context, state) {
                            int available = 0;
                            if (state is BookingLoaded) {
                              available = state.slots.where((slot) => !slot.isBooked).length;
                              print('UI: Số slot trống nhận được từ bloc: $available');
                            } else {
                              print('UI: State hiện tại là $state');
                            }
                            return Container(
                              margin: const EdgeInsets.only(top: 16),
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
                                    "Thông tin đặt chỗ",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoItem(
                                        context,
                                        Icons.local_parking,
                                        "Chỗ trống",
                                        "$available chỗ",
                                      ),
                                      _buildInfoItem(
                                        context,
                                        Icons.access_time,
                                        "Thời gian",
                                        "${_startTime.format(context)} - ${_endTime.format(context)}",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
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
                    onPressed: (_errorMessage != null || _selectedVehicleType == null) ? null : () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.bookingSlot,
                        arguments: {
                          'parkingLot': widget.parkingLot,
                          'selectedDate': _selectedDate,
                          'startTime': _startTime,
                          'endTime': _endTime,
                          'vehicleType': _selectedVehicleType,
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