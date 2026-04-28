// lib/providers/review_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/review_model.dart';
import '../data/services/firestore/review_service.dart';

export '../data/services/firestore/review_service.dart' show ReviewTarget;

enum ReviewSubmitState { idle, loading, success, error, alreadyReviewed }

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService;

  ReviewProvider({ReviewService? reviewService})
    : _reviewService = reviewService ?? ReviewService();

  // ─── State ───────────────────────────────────────────────
  ReviewSubmitState _submitState = ReviewSubmitState.idle;
  String _errorMessage = '';
  double _selectedRating = 5.0;
  bool _showForm = false;

  // ─── Getters ─────────────────────────────────────────────
  ReviewSubmitState get submitState => _submitState;
  String get errorMessage => _errorMessage;
  double get selectedRating => _selectedRating;
  bool get showForm => _showForm;
  bool get isLoading => _submitState == ReviewSubmitState.loading;

  // ─── User info dari FirebaseAuth ──────────────────────────
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _userName =>
      FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous';
  String get _userAvatar => FirebaseAuth.instance.currentUser?.photoURL ?? '';

  // ─── Stream reviews ───────────────────────────────────────
  Stream<List<ReviewModel>> getReviews(ReviewTarget target, String targetId) {
    return _reviewService.getReviews(target, targetId);
  }

  // ─── Toggle form ─────────────────────────────────────────
  void toggleForm() {
    _showForm = !_showForm;
    _submitState = ReviewSubmitState.idle;
    notifyListeners();
  }

  void hideForm() {
    _showForm = false;
    _submitState = ReviewSubmitState.idle;
    notifyListeners();
  }

  // ─── Set rating ──────────────────────────────────────────
  void setRating(double rating) {
    _selectedRating = rating;
    notifyListeners();
  }

  // ─── Submit review ────────────────────────────────────────
  Future<void> submitReview({
    required ReviewTarget target,
    required String targetId,
    required String comment,
  }) async {
    if (comment.trim().isEmpty) return;

    _submitState = ReviewSubmitState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final alreadyReviewed = await _reviewService.hasUserReviewed(
        target,
        targetId,
        _userId,
      );

      if (alreadyReviewed) {
        _submitState = ReviewSubmitState.alreadyReviewed;
        notifyListeners();
        return;
      }

      final review = ReviewModel(
        id: '',
        userId: _userId,
        userName: _userName,
        userAvatar: _userAvatar,
        rating: _selectedRating,
        comment: comment.trim(),
        createdAt: Timestamp.now(),
      );

      await _reviewService.addReview(target, targetId, review);

      _submitState = ReviewSubmitState.success;
      _showForm = false;
      _selectedRating = 5.0;
      notifyListeners();
    } catch (e) {
      _submitState = ReviewSubmitState.error;
      _errorMessage = 'Gagal mengirim ulasan. Coba lagi.';
      notifyListeners();
    }
  }

  // ─── Delete review ────────────────────────────────────────
  Future<void> deleteReview({
    required ReviewTarget target,
    required String targetId,
    required String reviewId,
  }) async {
    try {
      await _reviewService.deleteReview(target, targetId, reviewId);
    } catch (e) {
      _errorMessage = 'Gagal menghapus ulasan.';
      notifyListeners();
    }
  }

  // ─── Reset state ──────────────────────────────────────────
  void resetSubmitState() {
    _submitState = ReviewSubmitState.idle;
    notifyListeners();
  }
}
