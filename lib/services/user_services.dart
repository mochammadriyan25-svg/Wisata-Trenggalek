import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

String get uid => _auth.currentUser!.uid;

Future<void> saveUserData({
required String name,
required String phone,
}) async {

await _firestore
    .collection('users')
    .doc(uid)
    .set({
  'name': name,
  'phone': phone,
  'email': _auth.currentUser!.email,
}, SetOptions(merge: true));

}

Future<Map<String, dynamic>?> getUserData() async {

final doc =
    await _firestore
        .collection('users')
        .doc(uid)
        .get();

return doc.data();

}
}