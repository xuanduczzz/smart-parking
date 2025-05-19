import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:park/bloc/reservation_history_bloc/reservation_history_bloc.dart';
import 'package:park/config/colors.dart';
import 'package:park/config/routes.dart';
import 'package:park/page/reservation_history/widgets/reservation_detail_dialog.dart';
import 'package:park/page/reservation_history/widgets/reservation_info_row.dart';

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            "Lịch sử đặt chỗ",
            style: TextStyle(
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
          child: BlocBuilder<ReservationHistoryBloc, ReservationHistoryState>(
            builder: (context, state) {
              if (state is ReservationHistoryLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(blueColor),
                  ),
                );
              } else if (state is ReservationHistoryError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 50, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is ReservationHistoryLoaded) {
                if (state.reservations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Bạn chưa có đặt chỗ nào",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: state.reservations.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final res = state.reservations[index];
                    return InkWell(
                      onTap: () {
                        if (res.status.toLowerCase() == 'checkout') {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.review,
                            arguments: {'reservationId': res.id},
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => ReservationDetailDialog(reservation: res),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: blueColor.withAlpha((0.1 * 255).round()),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: blueColor.withAlpha((0.2 * 255).round()),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.local_parking,
                                      color: blueColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          res.lotName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Vị trí: ${res.slotId}",
                                          style: TextStyle(
                                            color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(res.status).withAlpha((0.2 * 255).round()),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      res.status,
                                      style: TextStyle(
                                        color: _getStatusColor(res.status),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  ReservationInfoRow(
                                    icon: Icons.access_time,
                                    label: "Thời gian",
                                    value: "${formatDateTime(res.startTime)} - ${formatDateTime(res.endTime)}",
                                  ),
                                  const SizedBox(height: 12),
                                  ReservationInfoRow(
                                    icon: Icons.attach_money,
                                    label: "Tổng giá",
                                    value: "${res.totalPrice.toStringAsFixed(2)} VND",
                                    valueColor: Colors.green,
                                  ),
                                  if (res.status.toLowerCase() == 'đã checkout') ...[
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.review,
                                          arguments: {'reservationId': res.id},
                                        );
                                      },
                                      icon: const Icon(Icons.rate_review),
                                      label: const Text('Đánh giá'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: blueColor,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
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
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'đã xác nhận':
        return Colors.green;
      case 'đang chờ':
        return Colors.orange;
      case 'đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
