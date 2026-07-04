// lib/data/services/firestore/accommodation_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_wisata/data/models/accommodation_model.dart';

class AccommodationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collection =>
      _firestore.collection('accommodations');

  // ── READ ─────────────────────────────────────────────────────────────────

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

  Future<AccommodationModel?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return AccommodationModel.fromFirestore(doc);
  }

  Stream<AccommodationModel?> streamById(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AccommodationModel.fromFirestore(doc);
    });
  }

  // ── WRITE (Admin) ─────────────────────────────────────────────────────────

  /// Buat akomodasi baru. Returns the new document ID.
  Future<String> createAccommodation(AccommodationModel accommodation) async {
    final ref = await _collection.add(accommodation.toCreateMap());
    return ref.id;
  }

  /// Update akomodasi yang sudah ada.
  Future<void> updateAccommodation(
    String id,
    AccommodationModel accommodation,
  ) async {
    await _collection.doc(id).update(accommodation.toUpdateMap());
  }

  /// Hapus akomodasi. Subcollection `reviews` tidak ikut terhapus secara
  /// otomatis di client — di produksi gunakan Cloud Function untuk cleanup.
  Future<void> deleteAccommodation(String id) async {
    await _collection.doc(id).delete();
  }
}
