import 'package:flutter/material.dart';

class QRCodeWidget extends StatelessWidget {
  final String imageUrl;
  final double size;

  const QRCodeWidget({
    Key? key,
    required this.imageUrl,
    this.size = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Không thể tải ảnh QR',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
} 