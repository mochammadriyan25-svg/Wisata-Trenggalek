// lib/data/services/firestore/destination_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';

class DestinationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('destinations');

  // ── GET ALL DESTINATIONS (Realtime) ───────────────────────────────────────
  Stream<List<DestinationModel>> getAllDestinations() {
    return _collection
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => DestinationModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // ── GET RECOMMENDED DESTINATIONS ─────────────────────────────────────────
  /// Sort & limit langsung di Firestore — hemat bandwidth
  /// Catatan: butuh composite index di Firestore untuk
  /// isRecommended + rating
  Stream<List<DestinationModel>> getRecommendedDestinations() {
    return _collection
        .where('isRecommended', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => DestinationModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // ── GET DESTINATIONS BY CATEGORY ──────────────────────────────────────────
  /// ✅ Gunakan field 'categoryId' — konsisten dengan DestinationModel
  Stream<List<DestinationModel>> getByCategory(String categoryId) {
    return _collection
        .where(
          'categoryId',
          isEqualTo: categoryId,
        ) // ✅ fix: 'category' → 'categoryId'
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => DestinationModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // ── SEARCH BY NAME ────────────────────────────────────────────────────────
  /// Firestore prefix search — case sensitive
  /// Untuk case-insensitive, pertimbangkan Algolia/Typesense
  Stream<List<DestinationModel>> searchByName(String keyword) {
    final lower = keyword.toLowerCase();
    return _collection
        .where('name', isGreaterThanOrEqualTo: lower)
        .where('name', isLessThanOrEqualTo: '$lower\uf8ff')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => DestinationModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // ── GET SINGLE BY ID (Future) ─────────────────────────────────────────────
  Future<DestinationModel?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return DestinationModel.fromFirestore(doc);
  }

  // ── STREAM SINGLE BY ID (Realtime) ────────────────────────────────────────
  /// Digunakan agar rating di detail page update otomatis
  Stream<DestinationModel?> streamById(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DestinationModel.fromFirestore(doc);
    });
  }
}
