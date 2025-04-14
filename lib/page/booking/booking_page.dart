import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/bloc/booking_bloc/booking_bloc.dart';
import 'package:park/config/colors.dart';
import 'package:park/page/reservation/reservation_page.dart';
import 'package:park/widgets/custom_date_picker.dart';

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
    _loadSlots();
  }

  // Hàm này sẽ được gọi mỗi khi thời gian thay đổi
  void _loadSlots() {
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

    // Gọi sự kiện LoadSlots để tải lại các slot với thời gian mới
    context.read<BookingBloc>().add(LoadSlots(
      widget.parkingLot.id,
      startDateTime,
      endDateTime,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt chỗ - ${widget.parkingLot.name}'),
        backgroundColor: blueColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.parkingLot.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.parkingLot.parkingLotMap,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),

            // Widget chọn thời gian
            BookingTimePickerWidget(
              selectedDate: _selectedDate,
              startTime: _startTime,
              endTime: _endTime,
              onDateChanged: (date) => setState(() {
                _selectedDate = date;
                _loadSlots(); // Gọi lại khi thay đổi ngày
              }),
              onStartTimeChanged: (time) => setState(() {
                _startTime = time;
                _loadSlots(); // Gọi lại khi thay đổi thời gian bắt đầu
              }),
              onEndTimeChanged: (time) => setState(() {
                _endTime = time;
                _loadSlots(); // Gọi lại khi thay đổi thời gian kết thúc
              }),
            ),

            const SizedBox(height: 20),

            BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                if (state is BookingLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is BookingLoaded) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: state.slots.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final slot = state.slots[index];

                      return GestureDetector(
                        onTap: () {
                          if (!slot.isBooked) {
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

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservationPage(
                                  parkingLot: widget.parkingLot,
                                  slot: slot,
                                  startTime: startDateTime,
                                  endTime: endDateTime,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: slot.isBooked ? Colors.grey[700] : Colors.green[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            slot.id,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is BookingError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Center(child: Text(state.message)),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}

