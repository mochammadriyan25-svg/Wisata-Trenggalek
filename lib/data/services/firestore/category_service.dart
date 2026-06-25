// lib/data/services/firestore/category_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_wisata/data/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('category');

  // ── GET ALL CATEGORIES (Realtime) ─────────────────────────────────────────
  Stream<List<CategoryModel>> getAllCategories() {
    return _collection
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => CategoryModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // ── GET CATEGORIES BY TYPE ────────────────────────────────────────────────
  /// Gunakan CategoryType constants untuk menghindari typo:
  /// getByType(CategoryType.destination)
  /// getByType(CategoryType.package)
  /// getByType(CategoryType.accommodation)
  Stream<List<CategoryModel>> getByType(String type) {
    // ✅ Validasi type sebelum query ke Firestore
    assert(
      CategoryType.values.contains(type),
      'Unknown category type: $type. Gunakan CategoryType constants.',
    );

    return _collection
        .where('type', isEqualTo: type)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => CategoryModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // ── GET SINGLE CATEGORY BY ID ─────────────────────────────────────────────
  Future<CategoryModel?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return CategoryModel.fromFirestore(doc);
  }

  // ── CREATE ──────────────────────────────────────────────────────────────
  Future<void> createCategory(CategoryModel category) async {
    await _collection.add(category.toCreateMap());
  }

  // ── UPDATE ──────────────────────────────────────────────────────────────
  Future<void> updateCategory(String id, CategoryModel category) async {
    await _collection.doc(id).update(category.toUpdateMap());
  }

  // ── CHECK USAGE BEFORE DELETE ───────────────────────────────────────────
  /// Cek apakah kategori ini masih dipakai destinasi/paket/akomodasi —
  /// mencegah data yatim (kehilangan kategori) saat dihapus.
  Future<bool> isCategoryInUse(CategoryModel category) async {
    final snapshot =
        await _firestore
            .collection(category.collectionName)
            .where('categoryId', isEqualTo: category.id)
            .limit(1)
            .get();
    return snapshot.docs.isNotEmpty;
  }

  // ── DELETE ──────────────────────────────────────────────────────────────
  Future<void> deleteCategory(String id) async {
    await _collection.doc(id).delete();
  }
}
