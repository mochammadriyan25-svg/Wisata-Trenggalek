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
  Stream<List<DestinationModel>> getByCategory(String categoryId) {
    return _collection
        .where('categoryId', isEqualTo: categoryId)
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
  Stream<DestinationModel?> streamById(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DestinationModel.fromFirestore(doc);
    });
  }

  // ── CREATE ──────────────────────────────────────────────────────────────
  Future<void> createDestination(DestinationModel destination) async {
    // Pakai doc().set(..., merge:true) BUKAN .add() — karena toCreateMap()
    // mengandung FieldValue.delete() (utk priceAdult/priceChild/menus
    // tergantung kategori). FieldValue.delete() HANYA valid di update() atau
    // set() dengan SetOptions(merge:true). .add() = set() TANPA merge,
    // akan throw runtime error kalau dipanggil langsung.
    final docRef = _collection.doc();
    await docRef.set(destination.toCreateMap(), SetOptions(merge: true));
  }

  // ── UPDATE ──────────────────────────────────────────────────────────────
  Future<void> updateDestination(
    String id,
    DestinationModel destination,
  ) async {
    await _collection.doc(id).update(destination.toUpdateMap());
  }

  // ── CHECK USAGE BEFORE DELETE ───────────────────────────────────────────
  /// Cek apakah destinasi ini termasuk dalam destinationIds salah satu Paket —
  /// mencegah Paket "kehilangan" destinasi secara tidak sengaja.
  Future<bool> isDestinationInAnyPackage(String destinationId) async {
    final snapshot =
        await _firestore
            .collection('packages')
            .where('destinationIds', arrayContains: destinationId)
            .limit(1)
            .get();
    return snapshot.docs.isNotEmpty;
  }

  // ── DELETE (+ CASCADE SUBCOLLECTION) ────────────────────────────────────
  /// Hapus destinasi BESERTA subcollection reviews-nya. Firestore tidak
  /// cascade-delete subcollection otomatis — kalau cuma hapus dokumen induk,
  /// reviews-nya jadi data yatim yang nggak akan pernah terhapus. Pakai
  /// batch agar atomic (semua berhasil atau semua gagal, tidak setengah-setengah).
  Future<void> deleteDestination(String id) async {
    final reviewsSnapshot =
        await _collection.doc(id).collection('reviews').get();
    final batch = _firestore.batch();
    for (final doc in reviewsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_collection.doc(id));
    await batch.commit();
  }
}
