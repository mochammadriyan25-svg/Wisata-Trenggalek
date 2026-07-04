// lib/data/services/firestore/favorite_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/favorite_model.dart';
import '../../models/favorite_stat_model.dart';
import '../../models/favorite_deletion_log_model.dart';
import '../../models/user_favorite_removal_log_model.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _favoriteCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('favorites');

  CollectionReference get _statsCollection =>
      _firestore.collection('favorite_stats');

  CollectionReference get _adminLogsCollection =>
      _firestore.collection('admin_favorite_deletion_logs');

  CollectionReference get _userRemovalLogsCollection =>
      _firestore.collection('user_favorite_removal_logs');

  String _docId(String itemId, FavoriteItemType itemType) =>
      '${itemType.name}_$itemId';

  // ── USER OPERATIONS ───────────────────────────────────────────────────────

  /// Tambah favorit + increment favorite_stats (batched write).
  Future<void> addFavorite(
    String userId,
    String itemId,
    FavoriteItemType itemType,
  ) async {
    final docId = _docId(itemId, itemType);
    debugPrint('Writing to: users/$userId/favorites/$docId');

    final batch = _firestore.batch();

    // 1. Tambah ke subcollection user
    batch.set(_favoriteCollection(userId).doc(docId), {
      'itemId': itemId,
      'itemType': itemType.name,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Increment favorite_stats (create jika belum ada via merge)
    batch.set(_statsCollection.doc(docId), {
      'itemId': itemId,
      'itemType': itemType.name,
      'count': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
    debugPrint('SUCCESS: Favorite added + stats updated!');
  }

  /// Hapus favorit + decrement stats + catat ke user_favorite_removal_logs.
  ///
  /// [userName] — nama user yang menghapus (opsional, dari AuthProvider).
  /// [itemName] — nama item yang dihapus (opsional, dari cache FavoriteProvider).
  ///
  /// Log ditulis secara non-blocking (try-catch terpisah) agar kegagalan
  /// log tidak membatalkan operasi utama.
  Future<void> removeFavorite(
    String userId,
    String itemId,
    FavoriteItemType itemType, {
    String userName = '',
    String itemName = '',
  }) async {
    final docId = _docId(itemId, itemType);
    debugPrint('Deleting: users/$userId/favorites/$docId');

    // Hapus dari subcollection user
    await _favoriteCollection(userId).doc(docId).delete();

    // Decrement stats (non-fatal jika dokumen belum ada)
    try {
      await _statsCollection.doc(docId).update({
        'count': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Stats dokumen belum ada — bisa terjadi pada data legacy
    }

    // Catat ke log penghapusan user (non-fatal)
    try {
      await _userRemovalLogsCollection.add({
        'userId': userId,
        'userName': userName,
        'itemId': itemId,
        'itemType': itemType.name,
        'itemName': itemName,
        'removedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Log gagal tidak membatalkan penghapusan favorit
    }

    debugPrint('SUCCESS: Favorite removed!');
  }

  Future<bool> isFavorite(
    String userId,
    String itemId,
    FavoriteItemType itemType,
  ) async {
    final doc =
        await _favoriteCollection(userId).doc(_docId(itemId, itemType)).get();
    return doc.exists;
  }

  Stream<List<FavoriteModel>> getUserFavorites(String userId) {
    return _favoriteCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FavoriteModel(
          id: doc.id,
          userId: userId,
          itemId: data['itemId'] ?? '',
          itemType: FavoriteItemType.values.firstWhere(
            (e) => e.name == (data['itemType'] ?? 'destination'),
            orElse: () => FavoriteItemType.destination,
          ),
          createdAt: data['createdAt'],
        );
      }).toList();
    });
  }

  // ── ADMIN OPERATIONS ──────────────────────────────────────────────────────

  /// Admin hapus favorit user — batched write:
  /// 1. Hapus dari subcollection user
  /// 2. Decrement favorite_stats
  /// 3. Tulis ke admin_favorite_deletion_logs
  Future<void> adminDeleteFavorite({
    required String adminUid,
    required String adminName,
    required String userId,
    required String userName,
    required String itemId,
    required FavoriteItemType itemType,
    required String itemName,
  }) async {
    final docId = _docId(itemId, itemType);
    final batch = _firestore.batch();

    batch.delete(_favoriteCollection(userId).doc(docId));

    batch.update(_statsCollection.doc(docId), {
      'count': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(_adminLogsCollection.doc(), {
      'itemId': itemId,
      'itemType': itemType.name,
      'itemName': itemName,
      'userId': userId,
      'userName': userName,
      'deletedBy': adminUid,
      'deletedByName': adminName,
      'deletedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ── ANALYTICS STREAMS ─────────────────────────────────────────────────────

  Stream<List<FavoriteStatModel>> getFavoriteStats({int limit = 20}) {
    return _statsCollection
        .orderBy('count', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => FavoriteStatModel.fromFirestore(doc))
                  .where((s) => s.count > 0)
                  .toList(),
        );
  }

  /// Log penghapusan oleh admin.
  Stream<List<FavoriteDeletionLogModel>> getAdminDeletionLogs({
    int limit = 50,
  }) {
    return _adminLogsCollection
        .orderBy('deletedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => FavoriteDeletionLogModel.fromFirestore(doc))
                  .toList(),
        );
  }

  /// [BARU] Log penghapusan oleh user sendiri.
  Stream<List<UserFavoriteRemovalLogModel>> getUserRemovalLogs({
    int limit = 50,
  }) {
    return _userRemovalLogsCollection
        .orderBy('removedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => UserFavoriteRemovalLogModel.fromFirestore(doc))
                  .toList(),
        );
  }

  /// [DEPRECATED] Gunakan getAdminDeletionLogs() — dipertahankan agar
  /// tidak breaking change pada kode yang masih pakai nama lama.
  Stream<List<FavoriteDeletionLogModel>> getDeletionLogs({int limit = 50}) =>
      getAdminDeletionLogs(limit: limit);
}
