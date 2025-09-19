import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/error_util.dart';
import '../models/review_model.dart';

class ReviewController {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final String _reviewCollection;

  ReviewController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    String reviewCollection = 'reviews',
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _reviewCollection = reviewCollection;

  CollectionReference<Review> get _reviewsRef => _db
      .collection(_reviewCollection)
      .withConverter<Review>(
        fromFirestore: (snap, _) => Review.fromFirestore(snap),
        toFirestore: (review, _) => review.toFirestore(),
      );

  Future<bool> isUserReviewOwner(String reviewId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final doc = await _reviewsRef.doc(reviewId).get();
      if (doc.exists) {
        final review = doc.data();
        return review?.userId == userId;
      }
      return false;
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<Review> _populateUserInfo(Review review) async {
    try {
      final userDoc = await _db.collection('users').doc(review.userId).get();
      final userData = userDoc.data();
      final userName = userData?['name'] ?? 'Khách';

      return review.copyWith(
        userName: userName,
        userAvatar: userData?['avatar'],
      );
    } catch (e) {
      // Nếu lỗi vẫn trả về review gốc
      return review;
    }
  }

  Future<void> updateCourtRating(String courtId) async {
    try {
      final reviews = await getCourtReviews(courtId);

      if (reviews.isEmpty) {
        await _db.collection('courts').doc(courtId).update({
          'rating': 0,
          'reviewCount': 0,
        });
        return;
      }

      final totalRating = reviews.fold(0, (sum, review) => sum + review.rating);
      final averageRating = totalRating / reviews.length;

      final roundedRating = double.parse(averageRating.toStringAsFixed(1));

      await _db.collection('courts').doc(courtId).update({
        'rating': roundedRating,
        'reviewCount': reviews.length,
      });
    } catch (e) {
      print('Error updating court rating: $e');
    }
  }

  Future<Review?> getUserReviewForCourt(String courtId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final query = _reviewsRef
          .where('courtId', isEqualTo: courtId)
          .where('userId', isEqualTo: userId)
          .limit(1);

      final snap = await query.get();
      if (snap.docs.isNotEmpty) {
        final review = snap.docs.first.data();
        return await _populateUserInfo(review);
      }
      return null;
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<List<Review>> getCourtReviews(String courtId) async {
    try {
      final userId = _auth.currentUser?.uid;
      final query = _reviewsRef
          .where('courtId', isEqualTo: courtId)
          .orderBy('createdAt', descending: true);

      final snap = await query.get();

      final reviewsWithUserInfo = await Future.wait(
        snap.docs.map((doc) async {
          final review = doc.data();
          final populatedReview = await _populateUserInfo(review);
          return populatedReview.copyWith(isOwner: review.userId == userId);
        }),
      );

      return reviewsWithUserInfo;
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<void> createReview(
    String courtId,
    int rating,
    String title,
    String comment,
    bool isAnonymous,
  ) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final existingReview = await getUserReviewForCourt(courtId);
      if (existingReview != null) {
        throw Exception('Bạn đã đánh giá court này rồi');
      }

      final review = Review(
        courtId: courtId,
        userId: userId,
        title: title,
        comment: comment,
        rating: rating,
        isAnonymous: isAnonymous,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _reviewsRef.add(review);
      await updateCourtRating(courtId);
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<void> updateReview(
    String reviewId,
    int rating,
    String title,
    String comment,
    bool isAnonymous,
  ) async {
    try {
      final oldReviewDoc = await _reviewsRef.doc(reviewId).get();
      if (!oldReviewDoc.exists) throw Exception('Review not found');

      final oldReview = oldReviewDoc.data();
      final courtId = oldReview!.courtId;

      await _reviewsRef.doc(reviewId).update({
        'rating': rating,
        'title': title,
        'comment': comment,
        'isAnonymous': isAnonymous,
        'updatedAt': Timestamp.now(),
      });
      await updateCourtRating(courtId);
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      final reviewDoc = await _reviewsRef.doc(reviewId).get();
      if (!reviewDoc.exists) throw Exception('Review not found');

      final review = reviewDoc.data();
      final courtId = review!.courtId;

      await _reviewsRef.doc(reviewId).delete();

      await updateCourtRating(courtId);
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }
}

final reviewControllerProvider = Provider<ReviewController>((ref) {
  return ReviewController();
});

final courtReviewsFutureProvider = FutureProvider.family<List<Review>, String>((
  ref,
  courtId,
) async {
  final controller = ref.read(reviewControllerProvider);
  return await controller.getCourtReviews(courtId);
});
