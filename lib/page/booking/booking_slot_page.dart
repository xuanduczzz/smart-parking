import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/bloc/booking_bloc/booking_bloc.dart';
import 'package:park/page/reservation/reservation_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Trang chọn vị trí đỗ xe
/// Hiển thị sơ đồ bãi đỗ xe và danh sách các vị trí đỗ xe có thể đặt
class BookingSlotPage extends StatefulWidget {
  /// Thông tin bãi đỗ xe được chọn
  final ParkingLot parkingLot;
  /// Ngày đặt chỗ
  final DateTime selectedDate;
  /// Thời gian bắt đầu đặt chỗ
  final TimeOfDay startTime;
  /// Thời gian kết thúc đặt chỗ
  final TimeOfDay endTime;
  /// Loại xe được chọn
  final String vehicleType;

  const BookingSlotPage({
    super.key,
    required this.parkingLot,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.vehicleType,
  });

  @override
  State<BookingSlotPage> createState() => _BookingSlotPageState();
}

class _BookingSlotPageState extends State<BookingSlotPage> {
  /// Bộ lọc vị trí đỗ xe theo chữ cái (mặc định là ALL)
  String selectedFilter = "ALL";
  /// ID của vị trí đỗ xe đang trong trạng thái chờ xử lý
  String? _pendingSlotId;

  @override
  Widget build(BuildContext context) {
    // Chuyển đổi TimeOfDay thành DateTime để gửi lên server
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

    // Gửi sự kiện tải danh sách vị trí đỗ xe
    context.read<BookingBloc>().add(LoadSlots(
      widget.parkingLot.id, 
      startDateTime, 
      endDateTime,
      widget.vehicleType,
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn Slot - ${widget.parkingLot.name}'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hiển thị loại xe đã chọn
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_car, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Loại xe: ${widget.vehicleType}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lọc theo chữ cái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
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
                      widget.vehicleType,
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
            if (widget.parkingLot.parkingLotMap.isNotEmpty)
              SizedBox(
                height: 180,
                child: PageView.builder(
                  itemCount: widget.parkingLot.parkingLotMap.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Stack(
                                children: [
                                  InteractiveViewer(
                                    minScale: 0.5,
                                    maxScale: 4.0,
                                    child: Image.network(
                                      widget.parkingLot.parkingLotMap[index],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.parkingLot.parkingLotMap[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),

            BlocConsumer<BookingBloc, BookingState>(
              listener: (context, state) {
                if (state is BookingLoaded && _pendingSlotId != null) {
                  final user = FirebaseAuth.instance.currentUser;
                  final slotList = state.slots.where((s) => s.id == _pendingSlotId);
                  if (slotList.isNotEmpty) {
                    final slot = slotList.first;
                    if (slot.pendingReservations.any((p) => p.userId == user?.uid)) {
                      // Đã pending thành công, chuyển sang trang reservation
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
                      _pendingSlotId = null; // Reset
                    }
                  }
                }
              },
              builder: (context, state) {
                if (state is BookingLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BookingLoaded) {
                  // Lọc danh sách slot theo chữ cái được chọn và loại xe
                  final filteredSlots = state.slots.where((slot) {
                    // Lọc theo chữ cái
                    if (selectedFilter != "ALL" && !slot.id.startsWith(selectedFilter)) {
                      return false;
                    }
                    // Lọc theo loại xe
                    return slot.vehicleType == widget.vehicleType;
                  }).toList();

                  if (filteredSlots.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Không có slot phù hợp với loại xe đã chọn',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  }

                  // Chia danh sách slot thành các nhóm 10 slot
                  final List<List<dynamic>> slotPages = [];
                  for (var i = 0; i < filteredSlots.length; i += 10) {
                    slotPages.add(
                      filteredSlots.sublist(
                        i,
                        i + 10 > filteredSlots.length ? filteredSlots.length : i + 10,
                      ),
                    );
                  }

                  return SizedBox(
                    height: 470, // Chiều cao cố định cho PageView
                    child: PageView.builder(
                      itemCount: slotPages.length,
                      itemBuilder: (context, pageIndex) {
                        final slotsInPage = slotPages[pageIndex];
                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(), // Vô hiệu hóa scroll của GridView
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 2,
                          ),
                          itemCount: slotsInPage.length,
                          itemBuilder: (context, index) {
                            final slot = slotsInPage[index];
                            return GestureDetector(
                              onTap: slot.isBooked
                                  ? null
                                  : () {
                                      final user = FirebaseAuth.instance.currentUser;
                                      if (user != null) {
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
                                        
                                        context.read<BookingBloc>().add(
                                          AddPendingReservation(
                                            widget.parkingLot.id,
                                            slot.id,
                                            user.uid,
                                            startDateTime,
                                            endDateTime,
                                          ),
                                        );
                                      }
                                    },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: slot.isBooked
                                      ? Colors.grey[700]
                                      : Colors.green[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: slot.isBooked
                                    ? Image.asset(
                                        'assets/images/car.png',
                                        width: 80,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      )
                                    : Text(
                                        slot.id,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          },
                        );
                      },
                    ),
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
