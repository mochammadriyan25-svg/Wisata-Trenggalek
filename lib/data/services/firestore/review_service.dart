// lib/data/services/firestore/review_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_wisata/data/models/review_model.dart';

enum ReviewTarget { destination, package, accommodation }

class ReviewService {
  final FirebaseFirestore _firestore;

  ReviewService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ─── Helper: ambil subcollection ref ─────────────────────
  CollectionReference _reviewsRef(ReviewTarget target, String targetId) {
    final parent = switch (target) {
      ReviewTarget.destination => 'destinations',
      ReviewTarget.package => 'packages',
      ReviewTarget.accommodation => 'accommodations',
    };
    return _firestore.collection(parent).doc(targetId).collection('reviews');
  }

  // =====================================================
  // GET REVIEWS (Realtime stream)
  // =====================================================
  Stream<List<ReviewModel>> getReviews(ReviewTarget target, String targetId) {
    return _reviewsRef(target, targetId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ReviewModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // =====================================================
  // ADD REVIEW
  // =====================================================
  Future<void> addReview(
    ReviewTarget target,
    String targetId,
    ReviewModel review,
  ) async {
    await _reviewsRef(target, targetId).add(review.toMap());

    if (target == ReviewTarget.destination) {
      await _updateDestinationRating(targetId);
    } else if (target == ReviewTarget.package) {
      await _updatePackageRating(targetId);
    }
  }

  // =====================================================
  // CHECK USER ALREADY REVIEWED
  // =====================================================
  Future<bool> hasUserReviewed(
    ReviewTarget target,
    String targetId,
    String userId,
  ) async {
    final snapshot =
        await _reviewsRef(
          target,
          targetId,
        ).where('userId', isEqualTo: userId).limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  // =====================================================
  // DELETE REVIEW
  // =====================================================
  Future<void> deleteReview(
    ReviewTarget target,
    String targetId,
    String reviewId,
  ) async {
    await _reviewsRef(target, targetId).doc(reviewId).delete();

    if (target == ReviewTarget.destination) {
      await _updateDestinationRating(targetId);
    } else if (target == ReviewTarget.package) {
      await _updatePackageRating(targetId);
    }
  }

  // =====================================================
  // PRIVATE: Hitung rata-rata rating destinasi
  // =====================================================
  Future<void> _updateDestinationRating(String destinationId) async {
    final snapshot =
        await _reviewsRef(ReviewTarget.destination, destinationId).get();

    double avgRating = 0.0;

    if (snapshot.docs.isNotEmpty) {
      final totalRating = snapshot.docs.fold<double>(
        0.0,
        (acc, doc) =>
            acc +
            ((doc.data() as Map<String, dynamic>)['rating'] as num? ?? 0)
                .toDouble(),
      );
      avgRating = double.parse(
        (totalRating / snapshot.docs.length).toStringAsFixed(1),
      );
    }

    await _firestore.collection('destinations').doc(destinationId).update({
      'rating': avgRating,
    });
  }

  // =====================================================
  // PRIVATE: Hitung rata-rata rating paket
  // =====================================================
  Future<void> _updatePackageRating(String packageId) async {
    final snapshot = await _reviewsRef(ReviewTarget.package, packageId).get();

    double avgRating = 0.0;

    if (snapshot.docs.isNotEmpty) {
      final totalRating = snapshot.docs.fold<double>(
        0.0,
        (acc, doc) =>
            acc +
            ((doc.data() as Map<String, dynamic>)['rating'] as num? ?? 0)
                .toDouble(),
      );
      avgRating = double.parse(
        (totalRating / snapshot.docs.length).toStringAsFixed(1),
      );
    }

    await _firestore.collection('packages').doc(packageId).update({
      'rating': avgRating,
    });
  }
}
