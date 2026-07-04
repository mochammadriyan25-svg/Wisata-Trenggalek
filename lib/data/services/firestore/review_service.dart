// lib/data/services/firestore/review_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_wisata/data/models/review_model.dart';

enum ReviewTarget { destination, package, accommodation }

/// Review dengan konteks parent — untuk tampilan admin review.
class ReviewWithContext {
  final ReviewModel review;
  final ReviewTarget target;
  final String targetId;

  ReviewWithContext({
    required this.review,
    required this.target,
    required this.targetId,
  });
}

class ReviewService {
  final FirebaseFirestore _firestore;

  ReviewService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _reviewsRef(ReviewTarget target, String targetId) {
    final parent = switch (target) {
      ReviewTarget.destination => 'destinations',
      ReviewTarget.package => 'packages',
      ReviewTarget.accommodation => 'accommodations',
    };
    return _firestore.collection(parent).doc(targetId).collection('reviews');
  }

  // ── USER OPERATIONS ───────────────────────────────────────────────────────

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

  // ── ADMIN OPERATIONS ──────────────────────────────────────────────────────

  /// Ambil semua review lintas collection via collectionGroup query.
  /// Perlu Firestore index `reviews(createdAt desc)` dan rule untuk
  /// collection group (lihat firestore.rules).
  Future<List<ReviewWithContext>> getAllReviewsAdmin({int limit = 100}) async {
    final snapshot =
        await _firestore
            .collectionGroup('reviews')
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();

    final results = <ReviewWithContext>[];
    for (final doc in snapshot.docs) {
      // Traverse: reviews → parent doc → parent collection
      final parentRef = doc.reference.parent.parent;
      if (parentRef == null) continue;

      final parentCollection = parentRef.parent.id;
      final targetId = parentRef.id;

      ReviewTarget? target;
      switch (parentCollection) {
        case 'destinations':
          target = ReviewTarget.destination;
          break;
        case 'packages':
          target = ReviewTarget.package;
          break;
        case 'accommodations':
          target = ReviewTarget.accommodation;
          break;
      }

      if (target == null) continue;

      results.add(
        ReviewWithContext(
          review: ReviewModel.fromFirestore(doc),
          target: target,
          targetId: targetId,
        ),
      );
    }
    return results;
  }

  // ── PRIVATE ───────────────────────────────────────────────────────────────

  Future<void> _updateDestinationRating(String destinationId) async {
    final snapshot =
        await _reviewsRef(ReviewTarget.destination, destinationId).get();
    double avgRating = 0.0;
    if (snapshot.docs.isNotEmpty) {
      final total = snapshot.docs.fold<double>(
        0.0,
        (acc, doc) =>
            acc +
            ((doc.data() as Map<String, dynamic>)['rating'] as num? ?? 0)
                .toDouble(),
      );
      avgRating = double.parse(
        (total / snapshot.docs.length).toStringAsFixed(1),
      );
    }
    await _firestore.collection('destinations').doc(destinationId).update({
      'rating': avgRating,
    });
  }

  Future<void> _updatePackageRating(String packageId) async {
    final snapshot = await _reviewsRef(ReviewTarget.package, packageId).get();
    double avgRating = 0.0;
    if (snapshot.docs.isNotEmpty) {
      final total = snapshot.docs.fold<double>(
        0.0,
        (acc, doc) =>
            acc +
            ((doc.data() as Map<String, dynamic>)['rating'] as num? ?? 0)
                .toDouble(),
      );
      avgRating = double.parse(
        (total / snapshot.docs.length).toStringAsFixed(1),
      );
    }
    await _firestore.collection('packages').doc(packageId).update({
      'rating': avgRating,
    });
  }
}
