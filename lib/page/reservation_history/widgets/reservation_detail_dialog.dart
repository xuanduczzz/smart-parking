import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:park/config/colors.dart';
import 'package:park/data/model/reservation.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReservationDetailDialog extends StatelessWidget {
  final Reservation reservation;

  const ReservationDetailDialog({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 500;
    final maxDialogHeight = MediaQuery.of(context).size.height * 0.85;

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
                _buildHeader(context),
                const SizedBox(height: 12),
                Divider(color: Theme.of(context).dividerColor.withAlpha((0.2 * 255).round())),
                const SizedBox(height: 6),
                _buildReservationDetails(context, isWide),
                if (reservation.qrCode.isNotEmpty) _buildQRCode(context, isWide),
                const SizedBox(height: 14),
                _buildCloseButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
    );
  }

  Widget _buildReservationDetails(BuildContext context, bool isWide) {
    if (isWide) {
      return Row(
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
      );
    }

    return Column(
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
    );
  }

  Widget _buildQRCode(BuildContext context, bool isWide) {
    return Column(
      children: [
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
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
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
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close_rounded, size: 20),
        label: const Text(
          'Đóng',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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