// 📁 lib/page/home/home_page.dart (Đã hỗ trợ Dark Mode hoàn chỉnh)
import 'package:flutter/material.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/config/colors.dart';
import 'package:park/page/booking/booking_page.dart';

class HomePage extends StatefulWidget {
  final ParkingLot parkingLot;

  const HomePage({super.key, required this.parkingLot});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final parkingLot = widget.parkingLot;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(parkingLot.name),
        backgroundColor: blueColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carousel hình ảnh
            if (parkingLot.imageUrls.isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    height: 220,
                    child: PageView.builder(
                      itemCount: parkingLot.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          child: Image.network(
                            parkingLot.imageUrls[index],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Text("Không thể tải ảnh"),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(parkingLot.imageUrls.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentImageIndex == index ? 12 : 8,
                        height: _currentImageIndex == index ? 12 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == index ? blueColor : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ],
              )
            else
              const SizedBox(
                height: 200,
                child: Center(child: Text("Không có hình ảnh")),
              ),

            // Thông tin
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(context, Icons.location_on, "Địa chỉ", parkingLot.address),
                      const SizedBox(height: 12),
                      _buildInfoRow(context, Icons.local_parking, "Tổng số chỗ", parkingLot.totalSlots.toString()),
                      const SizedBox(height: 12),
                      _buildInfoRow(context, Icons.attach_money, "Giá", "${parkingLot.pricePerHour} VND / giờ"),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blueColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.car_rental, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingPage(parkingLot: parkingLot),
                              ),
                            );
                          },
                          label: const Text(
                            "ĐẶT CHỖ NGAY",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
