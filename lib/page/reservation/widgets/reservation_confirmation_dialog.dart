import 'package:flutter/material.dart';
import 'package:park/data/model/reservation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:park/page/map/map_page.dart';
import 'package:park/bloc/booking_bloc/booking_bloc.dart';
import 'package:park/config/colors.dart';
import 'package:park/config/routes.dart';
import 'package:park/page/payment/payment_page.dart';
import 'dart:developer' as developer;

void showConfirmationDialog({
  required BuildContext context,
  required Reservation reservation,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BlocListener<ReservationBloc, ReservationState>(
        listener: (context, state) {
          developer.log('Reservation state: $state', name: 'ConfirmationDialog');
          if (state is ReservationSuccess) {
            developer.log('Navigating to payment page with QR: ${state.qrImageUrl}', name: 'ConfirmationDialog');
            Navigator.of(context).pop(); // Đóng dialog
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentPage(
                  totalAmount: state.totalAmount,
                  ownerId: state.ownerId,
                  qrImageUrl: state.qrImageUrl,
                  reservationId: state.reservationId,
                  reservation: state.reservation,
                ),
              ),
            );
          } else if (state is ReservationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
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
                          color: blueColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.receipt_long, color: blueColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Chi tiết đặt chỗ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailItem('🏢', 'Bãi xe', reservation.lotName),
                  _buildDetailItem('🅿️', 'Vị trí', reservation.slotId),
                  _buildDetailItem('👤', 'Tên người đặt', reservation.name),
                  _buildDetailItem('📞', 'Số điện thoại', reservation.phoneNumber),
                  _buildDetailItem('🚘', 'Biển số xe', reservation.vehicleId),
                  _buildDetailItem(
                    '🕒',
                    'Bắt đầu',
                    '${reservation.startTime.toLocal()}'.split(' ')[0] + ' ${reservation.startTime.hour}:${reservation.startTime.minute}',
                  ),
                  _buildDetailItem(
                    '🕒',
                    'Kết thúc',
                    '${reservation.endTime.toLocal()}'.split(' ')[0] + ' ${reservation.endTime.hour}:${reservation.endTime.minute}',
                  ),
                  _buildDetailItem('💵', 'Giá/giờ', '${reservation.pricePerHour} VND'),
                  _buildDetailItem(
                    '💰',
                    'Tổng giá',
                    '${reservation.totalPrice.toStringAsFixed(0)} VND',
                    valueColor: Colors.green,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          developer.log('Confirm button pressed', name: 'ConfirmationDialog');
                          context.read<ReservationBloc>().add(SaveReservation(reservation: reservation));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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

Widget _buildDetailItem(String emoji, String label, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
