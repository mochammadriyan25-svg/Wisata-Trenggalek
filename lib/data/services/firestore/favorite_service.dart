import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _favoriteCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  Future<void> addFavorite(String userId, String destinationId) async {
    debugPrint('Writing to: users/$userId/favorites/$destinationId');
    try {
      await _favoriteCollection(
        userId,
      ).doc(destinationId).set({'createdAt': FieldValue.serverTimestamp()});
      debugPrint('SUCCESS: Favorite added!');
    } catch (e) {
      debugPrint('ERROR adding favorite: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(String userId, String destinationId) async {
    debugPrint('Deleting: users/$userId/favorites/$destinationId');
    try {
      await _favoriteCollection(userId).doc(destinationId).delete();
      debugPrint('SUCCESS: Favorite removed!');
    } catch (e) {
      debugPrint('ERROR removing favorite: $e');
      rethrow;
    }
  }

  Future<bool> isFavorite(String userId, String destinationId) async {
    final doc = await _favoriteCollection(userId).doc(destinationId).get();
    return doc.exists;
  }

  Stream<List<String>> getUserFavoriteIds(String userId) {
    return _favoriteCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }
}
