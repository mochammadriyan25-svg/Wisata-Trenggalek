import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthException implements Exception {
final String message;

AuthException(this.message);
}

class AuthService {

final FirebaseAuth _auth = FirebaseAuth.instance;

// ================= REGISTER =================
Future<User?> registerUser(
String email,
String password) async {

try {

  final credential =
      await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  return credential.user;

} on FirebaseAuthException catch (e) {

  if (e.code == 'email-already-in-use') {
    throw AuthException("Email sudah digunakan");
  }

  if (e.code == 'weak-password') {
    throw AuthException("Password terlalu lemah");
  }

  throw AuthException("Gagal registrasi");
}

}

// ================= LOGIN =================
Future<User?> loginUser(
String email,
String password) async {

try {

  final credential =
      await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  return credential.user;

} on FirebaseAuthException catch (e) {

  if (e.code == 'user-not-found') {
    throw AuthException("User tidak ditemukan");
  }

  if (e.code == 'wrong-password') {
    throw AuthException("Password salah");
  }

  throw AuthException("Login gagal");
}

}

// ================= GOOGLE LOGIN =================
Future<User?> signInWithGoogle() async {

try {

  final GoogleSignInAccount? googleUser =
      await GoogleSignIn().signIn();

  if (googleUser == null) return null;

  final googleAuth =
      await googleUser.authentication;

  final credential =
      GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final userCredential =
      await _auth.signInWithCredential(
          credential);

  return userCredential.user;

} catch (e) {
  throw AuthException("Login Google gagal");
}

}

// ================= LOGOUT =================
Future<void> logout() async {
await _auth.signOut();
}

// ================= RESET PASSWORD =================
Future<void> resetPassword(
String email) async {

try {

  await _auth.sendPasswordResetEmail(
      email: email);

} catch (e) {
  throw AuthException(
      "Gagal mengirim email reset");
}

}

// ================= GET CURRENT USER =================
User? getCurrentUser() {
return _auth.currentUser;
}
}