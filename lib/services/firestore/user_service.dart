import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference get _collection =>
      _firestore.collection('users');

  // =====================================================
  // CREATE USER (SET FIRST TIME LOGIN)
  // =====================================================
  Future<void> createUser(UserModel user) async {
    await _collection.doc(user.id).set(
          user.toMap(),
        );
  }

  // =====================================================
  // GET USER BY ID
  // =====================================================
  Future<UserModel?> getUser(
      String userId) async {
    final doc =
        await _collection.doc(userId).get();

    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc);
  }

  // =====================================================
  // STREAM USER (REALTIME PROFILE)
  // =====================================================
  Stream<UserModel?> streamUser(
      String userId) {
    return _collection
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    });
  }

  // =====================================================
  // UPDATE USER
  // =====================================================
  Future<void> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _collection
        .doc(userId)
        .update(data);
  }
}