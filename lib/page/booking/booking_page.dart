import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/bloc/booking_bloc/booking_bloc.dart';
import 'package:park/config/colors.dart';
import 'package:park/page/reservation/reservation_page.dart';
import 'package:park/bloc/reservation_bloc/reservation_bloc.dart';

class BookingPage extends StatelessWidget {
  final ParkingLot parkingLot;

  const BookingPage({super.key, required this.parkingLot});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingBloc(FirebaseFirestore.instance)..add(LoadSlots(parkingLot.id)),
      child: Scaffold(
        appBar: AppBar(title: Text('Đặt chỗ - ${parkingLot.name}'), backgroundColor: blueColor),
        body: Column(
          children: [
            // Hiển thị sơ đồ bãi đậu (ảnh)
            if (parkingLot.imageUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    parkingLot.parkingLotMap,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Expanded(
              child: BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {
                  if (state is BookingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BookingLoaded) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ReservationPage(parkingLot: parkingLot, slot: slot); // No BlocProvider needed here
                                  },
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
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}