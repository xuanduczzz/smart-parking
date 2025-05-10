import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:park/bloc/reservation_history_bloc/reservation_history_bloc.dart';
import 'package:park/data/model/reservation.dart';
import 'package:park/presentation/bloc/review/review_bloc.dart';
import 'package:park/presentation/screens/review_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:park/config/colors.dart';
import 'package:park/config/routes.dart';

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
                          showReservationDetailDialog(context, res);
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
                                  _buildInfoRow(
                                    context,
                                    Icons.access_time,
                                    "Thời gian",
                                    "${formatDateTime(res.startTime)} - ${formatDateTime(res.endTime)}",
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    context,
                                    Icons.attach_money,
                                    "Tổng giá",
                                    "${res.totalPrice.toStringAsFixed(2)} VND",
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

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showReservationDetailDialog(BuildContext context, Reservation reservation) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isWide = MediaQuery.of(ctx).size.width > 500;
        final maxDialogHeight = MediaQuery.of(ctx).size.height * 0.85;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxDialogHeight,
              maxWidth: isWide ? 500 : double.infinity,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: blueColor.withAlpha((0.12 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.info_outline_rounded, color: blueColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Chi tiết đặt chỗ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Theme.of(context).dividerColor.withAlpha((0.2 * 255).round())),
                    const SizedBox(height: 6),
                    isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildDetailRow(context, Icons.local_parking, 'Bãi xe', reservation.lotName),
                                    _buildDetailRow(context, Icons.person, 'Tên người đặt', reservation.name),
                                    _buildDetailRow(context, Icons.directions_car, 'Biển số xe', reservation.vehicleId),
                                    _buildDetailRow(context, Icons.attach_money, 'Giá/giờ', '${reservation.pricePerHour} VND'),
                                    _buildDetailRow(context, Icons.info, 'Trạng thái', reservation.status, valueColor: _getStatusColor(reservation.status)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildDetailRow(context, Icons.place, 'Vị trí', reservation.slotId),
                                    _buildDetailRow(context, Icons.phone, 'Số điện thoại', reservation.phoneNumber),
                                    _buildDetailRow(context, Icons.access_time, 'Bắt đầu', DateFormat('dd/MM/yyyy HH:mm').format(reservation.startTime)),
                                    _buildDetailRow(context, Icons.timer_off, 'Kết thúc', DateFormat('dd/MM/yyyy HH:mm').format(reservation.endTime)),
                                    _buildDetailRow(context, Icons.payments, 'Tổng giá', '${reservation.totalPrice.toStringAsFixed(2)} VND', valueColor: Colors.green),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _buildDetailRow(context, Icons.local_parking, 'Bãi xe', reservation.lotName),
                              _buildDetailRow(context, Icons.place, 'Vị trí', reservation.slotId),
                              _buildDetailRow(context, Icons.person, 'Tên người đặt', reservation.name),
                              _buildDetailRow(context, Icons.phone, 'Số điện thoại', reservation.phoneNumber),
                              _buildDetailRow(context, Icons.directions_car, 'Biển số xe', reservation.vehicleId),
                              _buildDetailRow(context, Icons.access_time, 'Bắt đầu', DateFormat('dd/MM/yyyy HH:mm').format(reservation.startTime)),
                              _buildDetailRow(context, Icons.timer_off, 'Kết thúc', DateFormat('dd/MM/yyyy HH:mm').format(reservation.endTime)),
                              _buildDetailRow(context, Icons.attach_money, 'Giá/giờ', '${reservation.pricePerHour} VND'),
                              _buildDetailRow(context, Icons.payments, 'Tổng giá', '${reservation.totalPrice.toStringAsFixed(2)} VND', valueColor: Colors.green),
                              _buildDetailRow(context, Icons.info, 'Trạng thái', reservation.status, valueColor: _getStatusColor(reservation.status)),
                            ],
                          ),
                    if (reservation.qrCode.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: reservation.qrCode,
                            version: QrVersions.auto,
                            size: isWide ? 110 : 120,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'Mã QR check-in',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        label: const Text(
                          'Đóng',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: blueColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
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
