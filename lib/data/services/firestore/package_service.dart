// lib/data/services/firestore/package_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_wisata/data/models/package_model.dart';

class PackageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('packages');

  // ── READ ─────────────────────────────────────────────────────────────────

  /// Hanya paket aktif — untuk halaman user-facing.
  Stream<List<PackageModel>> getActivePackages() {
    return _collection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PackageModel.fromFirestore(doc))
                  .toList(),
        );
  }

  /// Semua paket termasuk nonaktif — untuk halaman admin.
  Stream<List<PackageModel>> getAllPackages() {
    return _collection
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PackageModel.fromFirestore(doc))
                  .toList(),
        );
  }

  Future<PackageModel?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return PackageModel.fromFirestore(doc);
  }

  Stream<PackageModel?> streamById(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return PackageModel.fromFirestore(doc);
    });
  }

  // ── WRITE (Admin) ─────────────────────────────────────────────────────────

  /// Buat paket baru. Rating di-init 0.0 via toCreateMap(). Returns new ID.
  Future<String> createPackage(PackageModel package) async {
    final ref = await _collection.add(package.toCreateMap());
    return ref.id;
  }

  /// Update paket. Rating TIDAK di-update dari sini (dikelola ReviewService).
  Future<void> updatePackage(String id, PackageModel package) async {
    await _collection.doc(id).update(package.toUpdateMap());
  }

  /// Hapus paket. Subcollection `reviews` tidak ikut terhapus di client.
  Future<void> deletePackage(String id) async {
    await _collection.doc(id).delete();
  }
}
