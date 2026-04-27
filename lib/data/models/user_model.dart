// lib/Data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final Timestamp? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.createdAt,
  });

  factory UserModel.fromFirestore(
      DocumentSnapshot doc) {
    final data =
        doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt':
          createdAt ??
              FieldValue.serverTimestamp(),
    };
  }
}