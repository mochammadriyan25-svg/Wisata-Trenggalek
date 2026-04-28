// lib/data/models/favorite_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum FavoriteItemType { destination, accommodation, package }

class FavoriteModel {
  final String id;
  final String userId;
  final String itemId; // ganti dari destinationId
  final FavoriteItemType itemType; // NEW
  final Timestamp? createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemType,
    this.createdAt,
  });

  factory FavoriteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FavoriteModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      itemId: data['itemId'] ?? '',
      itemType: FavoriteItemType.values.firstWhere(
        (e) => e.name == (data['itemType'] ?? 'destination'),
        orElse: () => FavoriteItemType.destination,
      ),
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'itemId': itemId,
      'itemType': itemType.name, // simpan sebagai string: "destination", dll
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
