// lib/data/services/firestore/accommodation_service.dart.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_wisata/data/models/accommodation_model.dart';

class AccommodationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collection =>
      _firestore.collection('accommodations');

  // ── GET ALL ACCOMMODATIONS (Realtime) ─────────────────────────────────────
  Stream<List<AccommodationModel>> getAllAccommodations() {
    return _collection
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => AccommodationModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // ── GET RECOMMENDED ACCOMMODATIONS ───────────────────────────────────────
  /// Catatan: butuh composite index di Firestore untuk
  /// isRecommended + rating
  Stream<List<AccommodationModel>> getRecommendedAccommodations() {
    return _collection
        .where('isRecommended', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => AccommodationModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // ── GET ACCOMMODATIONS BY CATEGORY ───────────────────────────────────────
  Stream<List<AccommodationModel>> getByCategory(String categoryId) {
    return _collection
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => AccommodationModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // ── SEARCH BY NAME ────────────────────────────────────────────────────────
  /// Firestore prefix search — case sensitive
  /// Untuk case-insensitive, pertimbangkan Algolia/Typesense
  Stream<List<AccommodationModel>> searchByName(String keyword) {
    final lower = keyword.toLowerCase();
    return _collection
        .where('name', isGreaterThanOrEqualTo: lower)
        .where('name', isLessThanOrEqualTo: '$lower\uf8ff')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => AccommodationModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // ── GET SINGLE BY ID (Future) ─────────────────────────────────────────────
  Future<AccommodationModel?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return AccommodationModel.fromFirestore(doc);
  }

  // ── STREAM SINGLE BY ID (Realtime) ────────────────────────────────────────
  /// Digunakan agar data di detail page update otomatis
  Stream<AccommodationModel?> streamById(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AccommodationModel.fromFirestore(doc);
    });
  }
}