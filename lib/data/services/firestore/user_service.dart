// lib/data/services/firestore/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_wisata/data/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('users');

  // ── CREATE (first time login) ──────────────────
  Future<void> createUser(UserModel user) async {
    await _collection.doc(user.id).set(user.toMap());
  }

  // ── SAVE / UPDATE PARTIAL DATA ─────────────────
  // Dipakai saat register email/password & login sosial
  Future<void> saveUserData({
    required String userId,
    required String name,
    required String phone,
    required String email,
    String? photoUrl, // ← TAMBAH
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'phone': phone,
      'email': email,
    };

    if (photoUrl != null && photoUrl.isNotEmpty) {
      data['photoUrl'] = photoUrl;
    }

    await _collection.doc(userId).set(data, SetOptions(merge: true));
  }

  // ── GET (one-time fetch) ───────────────────────
  Future<UserModel?> getUser(String userId) async {
    final doc = await _collection.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // ── STREAM (realtime) ──────────────────────────
  Stream<UserModel?> streamUser(String userId) {
    return _collection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // ── UPDATE PARTIAL ─────────────────────────────
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _collection.doc(userId).update(data);
  }

  // ── DELETE ─────────────────────────────────────
  Future<void> deleteUser(String userId) async {
    await _collection.doc(userId).delete();
  }
}
