import 'dart:io';

abstract class ReviewEvent {}

class SubmitReview extends ReviewEvent {
  final String reservationId;
  final String review;
  final int star;
  final String uid;
  final File? imageFile;

  SubmitReview({
    required this.reservationId,
    required this.review,
    required this.star,
    required this.uid,
    this.imageFile,
  });
} 