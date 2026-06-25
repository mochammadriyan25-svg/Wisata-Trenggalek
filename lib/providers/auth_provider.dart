// lib/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/auth/auth_service.dart';
import 'package:aplikasi_wisata/data/services/firestore/user_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isGuest => _status == AuthStatus.unauthenticated;
  bool get isAdmin =>
      _user?.isAdmin ?? false; // untuk pengecekan saat sudah di dalam app

  //Ambil UID langsung dari Firebase Auth sebagai fallback
  String? get userId => FirebaseAuth.instance.currentUser?.uid ?? _user?.id;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
    } else {
      _status = AuthStatus.authenticated;
      final userFromFirestore = await _userService.getUser(firebaseUser.uid);

      if (userFromFirestore != null) {
        _user = userFromFirestore;
      } else {
        // Fallback ke email kalau displayName kosong, jangan 'User'
        final String effectiveName =
            firebaseUser.displayName?.isNotEmpty == true
                ? firebaseUser.displayName!
                : (firebaseUser.email ?? 'User');

        _user = UserModel(
          id: firebaseUser.uid,
          name: effectiveName,
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL ?? '',
        );

        // Simpan ke Firestore agar konsisten
        await _userService.saveUserData(
          userId: firebaseUser.uid,
          name: effectiveName,
          phone: firebaseUser.phoneNumber ?? '',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL ?? '', // ← TAMBAH
        );
      }
    }
    notifyListeners();
  }

  // ── LOGIN ──────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.loginUser(email, password);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── REGISTER ───────────────────────────────────
  Future<bool> register(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    _setLoading(true);
    try {
      final firebaseUser = await _authService.registerUser(email, password);
      if (firebaseUser != null) {
        await _userService.saveUserData(
          userId: firebaseUser.uid,
          name: name,
          phone: phone,
          email: email,
          // photoUrl tidak perlu karena register email/password tanpa foto
        );
      }
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── GOOGLE LOGIN ───────────────────────────────
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.signInWithGoogle();

      // Simpan ke Firestore agar konsisten
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final existingUser = await _userService.getUser(firebaseUser.uid);
        if (existingUser == null) {
          await _userService.saveUserData(
            userId: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'User',
            phone: firebaseUser.phoneNumber ?? '',
            email: firebaseUser.email ?? '',
            photoUrl: firebaseUser.photoURL ?? '', // ← TAMBAH
          );
        }
      }

      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch langsung dari Firestore (bypass stream) — dipanggil khusus
  /// tepat setelah login()/signInWithGoogle() sukses, untuk hindari race
  /// condition dengan _onAuthStateChanged yang masih proses di background.
  Future<bool> isCurrentUserAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final freshUser = await _userService.getUser(uid);
    return freshUser?.isAdmin ?? false;
  }

  // ── LOGOUT ─────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
