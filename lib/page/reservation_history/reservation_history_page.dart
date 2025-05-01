import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park/bloc/reservation_history_bloc/reservation_history_bloc.dart';
import 'package:park/data/model/reservation.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReservationHistoryPage extends StatelessWidget {
  const ReservationHistoryPage({super.key});

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy – HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      ReservationHistoryBloc(FirebaseFirestore.instance)
        ..add(LoadReservations()),
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
                  child: Text("Bạn chưa có đặt chỗ nào.",
                      style: TextStyle(fontSize: 16)),
                );
              }

              return ListView.builder(
                itemCount: state.reservations.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final res = state.reservations[index];
                  return InkWell(
                    onTap: () => showReservationDetailDialog(context, res),
                    child: Card(
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
                                const Icon(Icons.local_parking,
                                    color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Bãi: ${res.lotName} – Vị trí: ${res
                                        .slotId}",
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
                              "Tổng giá: ${res.totalPrice.toStringAsFixed(
                                  2)} VND",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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

  void showReservationDetailDialog(BuildContext context,
      Reservation reservation) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxHeight: 600),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Chi tiết đặt chỗ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 1.2),
                  _buildDetailItem('🏢', 'Bãi xe', reservation.lotName),
                  _buildDetailItem('🅿️', 'Vị trí', reservation.slotId),
                  _buildDetailItem('👤', 'Tên người đặt', reservation.name),
                  _buildDetailItem(
                      '📞', 'Số điện thoại', reservation.phoneNumber),
                  _buildDetailItem('🚘', 'Biển số xe', reservation.vehicleId),
                  _buildDetailItem('🕒', 'Bắt đầu',
                      DateFormat('dd/MM/yyyy HH:mm').format(
                          reservation.startTime)),
                  _buildDetailItem('🕒', 'Kết thúc',
                      DateFormat('dd/MM/yyyy HH:mm').format(
                          reservation.endTime)),
                  _buildDetailItem(
                      '💵', 'Giá/giờ', '${reservation.pricePerHour} VND'),
                  _buildDetailItem('💰', 'Tổng giá',
                      '${reservation.totalPrice.toStringAsFixed(2)} VND'),
                  _buildDetailItem('📌', 'Trạng thái', reservation.status),
                  if (reservation.qrCode.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        '🔳 Mã QR',
                        style: TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: reservation.qrCode,
                          version: QrVersions.auto,
                          size: 160,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius
                            .circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 14),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Đóng', style: TextStyle(fontSize: 16)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                children: [
                  TextSpan(text: '$label: ',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
