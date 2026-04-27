import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String id;
  final String userId;
  final String destinationId;
  final Timestamp? createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.destinationId,
    this.createdAt,
  });

  factory FavoriteModel.fromFirestore(
      DocumentSnapshot doc) {
    final data =
        doc.data() as Map<String, dynamic>;

    return FavoriteModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      destinationId:
          data['destinationId'] ?? '',
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'destinationId': destinationId,
      'createdAt':
          createdAt ??
              FieldValue.serverTimestamp(),
    };
  }
}