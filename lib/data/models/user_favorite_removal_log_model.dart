// lib/data/models/user_favorite_removal_log_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'favorite_model.dart';

/// Log setiap kali USER sendiri menghapus favorit miliknya.
/// Collection: `user_favorite_removal_logs` (append-only).
/// Berbeda dari admin_favorite_deletion_logs yang hanya dicatat saat
/// admin yang menghapus milik user lain.
class UserFavoriteRemovalLogModel {
  final String id;
  final String userId;
  final String
  userName; // nama user yang menghapus (bisa kosong jika tidak diteruskan)
  final String itemId;
  final FavoriteItemType itemType;
  final String
  itemName; // nama item saat dihapus (bisa kosong jika tidak di-cache)
  final Timestamp removedAt;

  UserFavoriteRemovalLogModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.itemId,
    required this.itemType,
    required this.itemName,
    required this.removedAt,
  });

  factory UserFavoriteRemovalLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserFavoriteRemovalLogModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      itemId: data['itemId'] ?? '',
      itemType: FavoriteItemType.values.firstWhere(
        (e) => e.name == (data['itemType'] ?? 'destination'),
        orElse: () => FavoriteItemType.destination,
      ),
      itemName: data['itemName'] ?? '',
      removedAt: data['removedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userName': userName,
    'itemId': itemId,
    'itemType': itemType.name,
    'itemName': itemName,
    'removedAt': FieldValue.serverTimestamp(),
  };

  String get typeLabel => switch (itemType) {
    FavoriteItemType.destination => 'Destinasi',
    FavoriteItemType.accommodation => 'Akomodasi',
    FavoriteItemType.package => 'Paket',
  };
}
