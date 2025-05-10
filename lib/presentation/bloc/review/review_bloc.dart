import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/review.dart';
import 'package:park/data/service/cloudinary_helper.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  ReviewBloc() : super(ReviewInitial()) {
    on<SubmitReview>(_onSubmitReview);
  }

  Future<void> _onSubmitReview(
    SubmitReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    try {
      // Tạo review trước
      final review = Review(
        id: '', // Will be set by Firestore
        reservationId: event.reservationId,
        review: event.review,
        star: event.star,
        uid: event.uid,
        imageUrl: null, // Will be updated after upload
        createdAt: DateTime.now(),
      );

      // Tạo document reference
      final reviewRef = FirebaseFirestore.instance.collection('reviews').doc();

      // Upload ảnh và lưu review song song
      String? imageUrl;
      if (event.imageFile != null) {
        // Upload ảnh
        imageUrl = await CloudinaryHelper.uploadImage(event.imageFile!);
      }

      // Cập nhật review với URL ảnh nếu có
      final updatedReview = Review(
        id: reviewRef.id,
        reservationId: review.reservationId,
        review: review.review,
        star: review.star,
        uid: review.uid,
        imageUrl: imageUrl,
        createdAt: review.createdAt,
      );

      // Lưu review vào Firestore
      await reviewRef.set(updatedReview.toMap());

      emit(ReviewSuccess());
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }
} 