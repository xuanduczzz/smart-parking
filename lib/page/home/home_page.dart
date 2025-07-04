// 📁 lib/page/home/home_page.dart (Đã hỗ trợ Dark Mode hoàn chỉnh)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park/bloc/home_bloc/home_bloc.dart';
import 'package:park/config/colors.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/data/model/slots.dart';
import 'package:park/page/booking/booking_page.dart';
import 'package:park/config/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final ParkingLot parkingLot;

  const HomePage({super.key, required this.parkingLot});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Không cần load lại thông tin vì đã có sẵn từ HomeBloc
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.parkingLot.name,
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
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(RefreshParkingLotInfo(parkingLotId: widget.parkingLot.id));
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is AllParkingLotsLoaded) {
            final lotInfo = state.parkingLotsInfo[widget.parkingLot.id];
            if (lotInfo == null) {
              return const Center(child: Text('Không tìm thấy thông tin bãi xe'));
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('parking_lots')
                  .doc(widget.parkingLot.id)
                  .collection('slots')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Đang tải thông tin chỗ đỗ xe...'),
                      ],
                    ),
                  );
                }

                final slots = snapshot.data!.docs
                    .map((doc) => ParkingSlot.fromMap(doc.data() as Map<String, dynamic>))
                    .toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeBloc>().add(LoadAllParkingLots());
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Carousel hình ảnh
                        if (widget.parkingLot.imageUrls.isNotEmpty)
                          Column(
                            children: [
                              Container(
                                height: 250,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: PageView.builder(
                                  itemCount: widget.parkingLot.imageUrls.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentImageIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(30),
                                        bottomRight: Radius.circular(30),
                                      ),
                                      child: Image.network(
                                        widget.parkingLot.imageUrls[index],
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(Icons.error_outline, size: 50, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(widget.parkingLot.imageUrls.length, (index) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: _currentImageIndex == index ? 20 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: _currentImageIndex == index ? blueColor : Colors.grey[300],
                                    ),
                                  );
                                }),
                              ),
                            ],
                          )
                        else
                          Container(
                            height: 200,
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text(
                                    "Không có hình ảnh",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Thông tin
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Card(
                            elevation: 8,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: Theme.of(context).cardColor,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Thông tin bãi đỗ xe",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInfoRow(Icons.location_on, "Địa chỉ", widget.parkingLot.address),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(Icons.local_parking, "Tổng số chỗ", "${slots.length} chỗ"),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(Icons.attach_money, "Giá", "${widget.parkingLot.pricePerHour.toStringAsFixed(0)} VND / giờ"),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(Icons.phone, "Số điện thoại chủ bãi", lotInfo['ownerPhone'] as String),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Đánh giá trung bình: ${(lotInfo['averageRating'] as double).toStringAsFixed(1)} sao",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: blueColor,
                                        foregroundColor: Colors.white,
                                        elevation: 5,
                                        shadowColor: blueColor.withOpacity(0.5),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      ),
                                      icon: const Icon(Icons.car_rental, size: 24),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.booking,
                                          arguments: {'parkingLot': widget.parkingLot},
                                        );
                                      },
                                      label: const Text(
                                        "ĐẶT CHỖ NGAY",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
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
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: blueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: blueColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
