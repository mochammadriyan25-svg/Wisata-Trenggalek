// lib/data/services/firestore/review_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_wisata/data/models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore;
  static const String _collection = 'reviews';

  ReviewService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // =====================================================
  // GET REVIEWS (Realtime stream)
  // =====================================================
  Stream<List<ReviewModel>> getReviews(String destinationId) {
    return _firestore
        .collection(_collection)
        .where('destinationId', isEqualTo: destinationId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList());
  }

  // =====================================================
  // ADD REVIEW + update rating destinasi
  // =====================================================
  Future<void> addReview(ReviewModel review) async {
    await _firestore.collection(_collection).add({
      ...review.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // ✅ Hitung ulang & update rating di dokumen destinasi
    await _updateDestinationRating(review.destinationId);
  }

  // =====================================================
  // CHECK USER ALREADY REVIEWED
  // =====================================================
  Future<bool> hasUserReviewed(String userId, String destinationId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('destinationId', isEqualTo: destinationId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // =====================================================
  // DELETE REVIEW + update rating destinasi
  // ✅ Tambah parameter destinationId
  // =====================================================
  Future<void> deleteReview(String reviewId, String destinationId) async {
    await _firestore.collection(_collection).doc(reviewId).delete();

    // ✅ Hitung ulang & update rating di dokumen destinasi
    await _updateDestinationRating(destinationId);
  }

  // =====================================================
  // PRIVATE: Hitung rata-rata rating & update Firestore
  // =====================================================
  Future<void> _updateDestinationRating(String destinationId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('destinationId', isEqualTo: destinationId)
        .get();

    double avgRating = 0.0;

    if (snapshot.docs.isNotEmpty) {
      final totalRating = snapshot.docs.fold<double>(
        0,
        (sum, doc) => sum + (doc.data()['rating'] ?? 0).toDouble(),
      );
      avgRating = totalRating / snapshot.docs.length;

      // Bulatkan ke 1 desimal, contoh: 4.3
      avgRating = double.parse(avgRating.toStringAsFixed(1));
    }

    await _firestore
        .collection('destinations')
        .doc(destinationId)
        .update({'rating': avgRating});
  }
}