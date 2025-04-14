import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/bloc/booking_bloc/booking_bloc.dart';
import 'package:park/page/reservation/reservation_page.dart';

class BookingSlotPage extends StatefulWidget {
  final ParkingLot parkingLot;
  final DateTime selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const BookingSlotPage({
    super.key,
    required this.parkingLot,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<BookingSlotPage> createState() => _BookingSlotPageState();
}

class _BookingSlotPageState extends State<BookingSlotPage> {
  String selectedFilter = "ALL"; // Default filter to ALL

  @override
  Widget build(BuildContext context) {
    final startDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      widget.startTime.hour,
      widget.startTime.minute,
    );

    final endDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      widget.endTime.hour,
      widget.endTime.minute,
    );

    // Gửi sự kiện tải slot
    context.read<BookingBloc>().add(LoadSlots(widget.parkingLot.id, startDateTime, endDateTime));

    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn Slot - ${widget.parkingLot.name}'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Lọc theo chữ cái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lọc theo chữ cái:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: selectedFilter,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                    });
                    // Gửi lại sự kiện để lọc các slot theo chữ cái
                    context.read<BookingBloc>().add(LoadSlots(
                      widget.parkingLot.id,
                      startDateTime,
                      endDateTime,
                    ));
                  },
                  items: <String>['ALL', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Hiển thị hình ảnh bãi đỗ xe (sơ đồ)
            if (widget.parkingLot.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.parkingLot.parkingLotMap, // Sử dụng đường dẫn hình ảnh của sơ đồ bãi đỗ xe
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),

            BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                if (state is BookingLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BookingLoaded) {
                  // Lọc danh sách slot theo chữ cái được chọn
                  final filteredSlots = state.slots.where((slot) {
                    if (selectedFilter == "ALL") {
                      return true;
                    }
                    return slot.id.startsWith(selectedFilter);
                  }).toList();

                  return GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Hiển thị 4 slot mỗi hàng
                      mainAxisSpacing: 8, // Khoảng cách giữa các hàng
                      crossAxisSpacing: 8, // Khoảng cách giữa các cột
                      childAspectRatio: 2, // Tỷ lệ chiều rộng/chiều cao của slot
                    ),
                    itemCount: filteredSlots.length,
                    itemBuilder: (context, index) {
                      final slot = filteredSlots[index];

                      return GestureDetector(
                        onTap: () {
                          if (!slot.isBooked) {
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
                            color: slot.isBooked
                                ? Colors.grey[700] // Slot đã đặt
                                : Colors.green[300], // Slot trống
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: slot.isBooked
                              ? Image.asset(
                            'assets/images/car.png', // Hình xe cho slot đã đặt
                            width: 80,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                              : Text(
                            slot.id, // Hiển thị ID cho slot trống
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is BookingError) {
                  return Center(child: Text(state.message));
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
