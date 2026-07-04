// lib/data/models/favorite_stat_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'favorite_model.dart';

/// Model untuk analytics favorit — disimpan di collection `favorite_stats`.
/// Doc ID: `{itemType}_{itemId}` (e.g., "destination_abc123")
/// Di-update setiap kali user add/remove favorite.
class FavoriteStatModel {
  final String id; // doc ID = itemType_itemId
  final String itemId;
  final FavoriteItemType itemType;
  final int count;
  final Timestamp? updatedAt;

  FavoriteStatModel({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.count,
    this.updatedAt,
  });

  factory FavoriteStatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteStatModel(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      itemType: FavoriteItemType.values.firstWhere(
        (e) => e.name == (data['itemType'] ?? 'destination'),
        orElse: () => FavoriteItemType.destination,
      ),
      count: (data['count'] as num?)?.toInt() ?? 0,
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'itemType': itemType.name,
        'count': count,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  String get typeLabel => switch (itemType) {
        FavoriteItemType.destination => 'Destinasi',
        FavoriteItemType.accommodation => 'Akomodasi',
        FavoriteItemType.package => 'Paket',
      };
}