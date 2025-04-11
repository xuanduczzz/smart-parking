import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:park/bloc/reservation_history_bloc/reservation_history_bloc.dart';

class ReservationHistoryPage extends StatelessWidget {
  const ReservationHistoryPage({super.key});

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy – HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReservationHistoryBloc(FirebaseFirestore.instance)..add(LoadReservations()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lịch sử đặt chỗ"),
          backgroundColor: Colors.blueAccent,
        ),
        body: BlocBuilder<ReservationHistoryBloc, ReservationHistoryState>(
          builder: (context, state) {
            if (state is ReservationHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ReservationHistoryError) {
              return Center(child: Text(state.message));
            } else if (state is ReservationHistoryLoaded) {
              if (state.reservations.isEmpty) {
                return const Center(
                  child: Text("Chưa có đặt chỗ nào.", style: TextStyle(fontSize: 16)),
                );
              }

              return ListView.builder(
                itemCount: state.reservations.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final res = state.reservations[index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_parking, color: Colors.blueAccent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Bãi: ${res.lotName} – Vị trí: ${res.slotId}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("Từ: ${formatDateTime(res.startTime)}"),
                          Text("Đến: ${formatDateTime(res.endTime)}"),
                          const SizedBox(height: 8),
                          Text(
                            "Tổng giá: ${res.totalPrice.toStringAsFixed(2)} VND",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
