// lib/data/services/firestore/favorite_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/favorite_model.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _favoriteCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  // doc ID pakai kombinasi: "type_itemId" supaya tidak tabrakan antar tipe
  String _docId(String itemId, FavoriteItemType itemType) =>
      '${itemType.name}_$itemId';

  Future<void> addFavorite(
    String userId,
    String itemId,
    FavoriteItemType itemType,
  ) async {
    final docId = _docId(itemId, itemType);
    debugPrint('Writing to: users/$userId/favorites/$docId');
    try {
      await _favoriteCollection(userId).doc(docId).set({
        'itemId': itemId,
        'itemType': itemType.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('SUCCESS: Favorite added!');
    } catch (e) {
      debugPrint('ERROR adding favorite: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(
    String userId,
    String itemId,
    FavoriteItemType itemType,
  ) async {
    final docId = _docId(itemId, itemType);
    debugPrint('Deleting: users/$userId/favorites/$docId');
    try {
      await _favoriteCollection(userId).doc(docId).delete();
      debugPrint('SUCCESS: Favorite removed!');
    } catch (e) {
      debugPrint('ERROR removing favorite: $e');
      rethrow;
    }
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

  // Mengembalikan semua FavoriteModel (bukan hanya ID)
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
}
