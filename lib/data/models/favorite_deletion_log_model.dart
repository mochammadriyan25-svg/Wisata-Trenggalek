// lib/data/models/favorite_deletion_log_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'favorite_model.dart';

/// Log immutable setiap kali admin menghapus favorit user.
/// Collection: `admin_favorite_deletion_logs` (append-only).
class FavoriteDeletionLogModel {
  final String id;
  final String itemId;
  final FavoriteItemType itemType;
  final String itemName; // denormalized agar tetap terbaca meski item dihapus
  final String userId;
  final String userName; // denormalized
  final String deletedBy; // UID admin
  final String deletedByName; // nama admin, denormalized
  final Timestamp deletedAt;

  FavoriteDeletionLogModel({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.itemName,
    required this.userId,
    required this.userName,
    required this.deletedBy,
    required this.deletedByName,
    required this.deletedAt,
  });

  factory FavoriteDeletionLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteDeletionLogModel(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      itemType: FavoriteItemType.values.firstWhere(
        (e) => e.name == (data['itemType'] ?? 'destination'),
        orElse: () => FavoriteItemType.destination,
      ),
      itemName: data['itemName'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      deletedBy: data['deletedBy'] ?? '',
      deletedByName: data['deletedByName'] ?? '',
      deletedAt: data['deletedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'itemType': itemType.name,
        'itemName': itemName,
        'userId': userId,
        'userName': userName,
        'deletedBy': deletedBy,
        'deletedByName': deletedByName,
        'deletedAt': FieldValue.serverTimestamp(),
      };

  String get typeLabel => switch (itemType) {
        FavoriteItemType.destination => 'Destinasi',
        FavoriteItemType.accommodation => 'Akomodasi',
        FavoriteItemType.package => 'Paket',
      };
}