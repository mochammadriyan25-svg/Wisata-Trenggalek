import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ===============================
  // COLLECTION REFERENCE
  // ===============================

  CollectionReference _favoriteCollection(
      String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites');
  }

  // ===============================
  // ADD FAVORITE
  // ===============================

  Future<void> addFavorite(
      String userId,
      String destinationId) async {
    await _favoriteCollection(userId)
        .doc(destinationId)
        .set({
      'createdAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ===============================
  // REMOVE FAVORITE
  // ===============================

  Future<void> removeFavorite(
      String userId,
      String destinationId) async {
    await _favoriteCollection(userId)
        .doc(destinationId)
        .delete();
  }

  // ===============================
  // CHECK IS FAVORITE
  // ===============================

  Future<bool> isFavorite(
      String userId,
      String destinationId) async {
    final doc =
        await _favoriteCollection(userId)
            .doc(destinationId)
            .get();

    return doc.exists;
  }

  // ===============================
  // GET ALL FAVORITE IDS (REALTIME)
  // ===============================

  Stream<List<String>>
      getUserFavoriteIds(String userId) {
    return _favoriteCollection(userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.id)
          .toList();
    });
  }
}