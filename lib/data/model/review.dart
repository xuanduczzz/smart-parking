import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String reservationId;
  final String lotId;
  final String review;
  final int star;
  final String uid;
  final String? imageUrl;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.reservationId,
    required this.lotId,
    required this.review,
    required this.star,
    required this.uid,
    this.imageUrl,
    required this.createdAt,
  });

  factory Review.fromFirestore(String id, Map<String, dynamic> data) {
    return Review(
      id: id,
      reservationId: data['reservationId'] ?? '',
      lotId: data['lotId'] ?? '',
      review: data['review'] ?? '',
      star: data['star'] ?? 0,
      uid: data['uid'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reservationId': reservationId,
      'lotId': lotId,
      'review': review,
      'star': star,
      'uid': uid,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 