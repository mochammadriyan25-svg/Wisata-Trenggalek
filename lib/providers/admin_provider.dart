// lib/providers/admin_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_wisata/data/models/user_model.dart';
import 'package:aplikasi_wisata/data/models/favorite_model.dart';
import 'package:aplikasi_wisata/data/models/favorite_stat_model.dart';
import 'package:aplikasi_wisata/data/models/favorite_deletion_log_model.dart';
import 'package:aplikasi_wisata/data/models/user_favorite_removal_log_model.dart';
import 'package:aplikasi_wisata/data/services/firestore/user_service.dart';
import 'package:aplikasi_wisata/data/services/firestore/favorite_service.dart';
import 'package:aplikasi_wisata/data/services/firestore/review_service.dart';
import 'package:aplikasi_wisata/data/models/review_model.dart';

// ── FavoriteLogEntry ─────────────────────────────────────────────────────────

enum FavoriteLogSource { userRemoved, adminDeleted }

class FavoriteLogEntry {
  final String id;
  final String userId;
  final String userName;
  final String itemId;
  final FavoriteItemType itemType;
  final String itemName;
  final FavoriteLogSource source;
  final String performedByName;
  final Timestamp activityAt;

  FavoriteLogEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.itemId,
    required this.itemType,
    required this.itemName,
    required this.source,
    required this.performedByName,
    required this.activityAt,
  });

  String get typeLabel => switch (itemType) {
    FavoriteItemType.destination => 'Destinasi',
    FavoriteItemType.accommodation => 'Akomodasi',
    FavoriteItemType.package => 'Paket',
  };

  String get sourceLabel => switch (source) {
    FavoriteLogSource.userRemoved => 'Dihapus oleh pengguna',
    FavoriteLogSource.adminDeleted => 'Dihapus oleh admin',
  };
}

// ── AdminReviewItem ───────────────────────────────────────────────────────────

class AdminReviewItem {
  final ReviewModel review;
  final ReviewTarget target;
  final String targetId;
  String targetName;

  AdminReviewItem({
    required this.review,
    required this.target,
    required this.targetId,
    this.targetName = '',
  });

  String get targetTypeLabel => switch (target) {
    ReviewTarget.destination => 'Destinasi',
    ReviewTarget.package => 'Paket',
    ReviewTarget.accommodation => 'Akomodasi',
  };
}

// ── AdminProvider ─────────────────────────────────────────────────────────────

class AdminProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final FavoriteService _favoriteService = FavoriteService();
  final ReviewService _reviewService = ReviewService();

  // ── User Management
  List<UserModel> _allUsers = [];
  bool _usersLoading = false;
  StreamSubscription<List<UserModel>>? _usersSub;

  // ── Favorite Stats
  List<FavoriteStatModel> _favoriteStats = [];
  bool _statsLoading = false;
  StreamSubscription<List<FavoriteStatModel>>? _statsSub;

  // ── Admin Deletion Logs
  List<FavoriteDeletionLogModel> _adminDeletionLogs = [];
  StreamSubscription<List<FavoriteDeletionLogModel>>? _adminLogsSub;

  // ── User Removal Logs
  List<UserFavoriteRemovalLogModel> _userRemovalLogs = [];
  StreamSubscription<List<UserFavoriteRemovalLogModel>>? _userRemovalLogsSub;

  // ── Per-user Favorites (on demand)
  List<FavoriteModel> _selectedUserFavorites = [];
  bool _userFavoritesLoading = false;
  StreamSubscription<List<FavoriteModel>>? _userFavoritesSub;
  String? _selectedUserId;

  // ── Reviews
  List<AdminReviewItem> _allReviews = [];
  bool _reviewsLoading = false;

  String? _errorMessage;

  // [FIX] Constructor KOSONG — stream tidak auto-start saat app launch
  // agar tidak kena permission-denied sebelum user login.
  // Panggil init() eksplisit dari AdminDashboardPage.initState.
  AdminProvider();

  // ── GETTERS ───────────────────────────────────────────────────────────────

  List<UserModel> get allUsers => _allUsers;
  bool get usersLoading => _usersLoading;
  List<FavoriteStatModel> get favoriteStats => _favoriteStats;
  bool get statsLoading => _statsLoading;
  List<FavoriteModel> get selectedUserFavorites => _selectedUserFavorites;
  bool get userFavoritesLoading => _userFavoritesLoading;
  List<AdminReviewItem> get allReviews => _allReviews;
  bool get reviewsLoading => _reviewsLoading;
  String? get errorMessage => _errorMessage;

  /// Log terpadu: admin deletions + user self-removals, diurutkan terbaru.
  List<FavoriteLogEntry> get mergedActivityLogs {
    final adminEntries = _adminDeletionLogs.map(
      (log) => FavoriteLogEntry(
        id: 'admin_${log.id}',
        userId: log.userId,
        userName: log.userName,
        itemId: log.itemId,
        itemType: log.itemType,
        itemName: log.itemName,
        source: FavoriteLogSource.adminDeleted,
        performedByName: log.deletedByName,
        activityAt: log.deletedAt,
      ),
    );

    final userEntries = _userRemovalLogs.map(
      (log) => FavoriteLogEntry(
        id: 'user_${log.id}',
        userId: log.userId,
        userName: log.userName,
        itemId: log.itemId,
        itemType: log.itemType,
        itemName: log.itemName,
        source: FavoriteLogSource.userRemoved,
        performedByName: log.userName.isNotEmpty ? log.userName : 'Pengguna',
        activityAt: log.removedAt,
      ),
    );

    final combined = [...adminEntries, ...userEntries].toList();
    combined.sort((a, b) => b.activityAt.compareTo(a.activityAt));
    return combined;
  }

  // ── INIT (dipanggil eksplisit setelah user login) ─────────────────────────

  /// Mulai semua stream admin. Panggil dari AdminDashboardPage setelah
  /// user login. Aman untuk dipanggil berulang — stream lama dibatalkan.
  void init() {
    debugPrint('[AdminProvider] init() — starting streams');
    _listenUsers();
    _listenFavoriteStats();
    _listenAdminDeletionLogs();
    _listenUserRemovalLogs();
  }

  // ── Listeners ─────────────────────────────────────────────────────────────

  void _listenUsers() {
    _usersLoading = true;
    _usersSub?.cancel();
    _usersSub = _userService.getAllUsers().listen(
      (users) {
        _allUsers = users;
        _usersLoading = false;
        notifyListeners();
      },
      onError: (error) {
        // Error ter-log agar bisa di-debug — cek apakah isAdmin: true
        // sudah diset di Firestore document user admin.
        debugPrint('[AdminProvider] _listenUsers error: $error');
        _usersLoading = false;
        notifyListeners();
      },
    );
  }

  void _listenFavoriteStats() {
    _statsLoading = true;
    _statsSub?.cancel();
    _statsSub = _favoriteService.getFavoriteStats().listen(
      (stats) {
        _favoriteStats = stats;
        _statsLoading = false;
        notifyListeners();
      },
      onError: (error) {
        // Jika error di sini: periksa rules favorite_stats di Firestore
        // (harus allow read: if isAuthenticated())
        debugPrint('[AdminProvider] _listenFavoriteStats error: $error');
        _statsLoading = false;
        notifyListeners();
      },
    );
  }

  void _listenAdminDeletionLogs() {
    _adminLogsSub?.cancel();
    _adminLogsSub = _favoriteService.getAdminDeletionLogs().listen(
      (logs) {
        _adminDeletionLogs = logs;
        notifyListeners();
      },
      onError: (error) {
        // Jika error: periksa rules admin_favorite_deletion_logs
        // (harus allow read: if isAdmin()) dan pastikan isAdmin: true
        // di dokumen Firestore user admin.
        debugPrint('[AdminProvider] _listenAdminDeletionLogs error: $error');
      },
    );
  }

  void _listenUserRemovalLogs() {
    _userRemovalLogsSub?.cancel();
    _userRemovalLogsSub = _favoriteService.getUserRemovalLogs().listen(
      (logs) {
        _userRemovalLogs = logs;
        notifyListeners();
      },
      onError: (error) {
        // Jika error: periksa rules user_favorite_removal_logs
        debugPrint('[AdminProvider] _listenUserRemovalLogs error: $error');
      },
    );
  }

  // ── Per-user Favorites ────────────────────────────────────────────────────

  void watchUserFavorites(String userId) {
    if (_selectedUserId == userId) return;
    _selectedUserId = userId;
    _userFavoritesLoading = true;
    _userFavoritesSub?.cancel();
    _userFavoritesSub = _favoriteService
        .getUserFavorites(userId)
        .listen(
          (favs) {
            _selectedUserFavorites = favs;
            _userFavoritesLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('[AdminProvider] watchUserFavorites error: $error');
            _userFavoritesLoading = false;
            notifyListeners();
          },
        );
    notifyListeners();
  }

  void clearSelectedUserFavorites() {
    _selectedUserId = null;
    _userFavoritesSub?.cancel();
    _selectedUserFavorites = [];
    notifyListeners();
  }

  // ── Reviews ───────────────────────────────────────────────────────────────

  Future<void> loadAllReviews() async {
    _reviewsLoading = true;
    notifyListeners();
    try {
      final rawList = await _reviewService.getAllReviewsAdmin();
      _allReviews =
          rawList
              .map(
                (r) => AdminReviewItem(
                  review: r.review,
                  target: r.target,
                  targetId: r.targetId,
                ),
              )
              .toList();
    } catch (e) {
      debugPrint('[AdminProvider] loadAllReviews error: $e');
      _errorMessage = e.toString();
    } finally {
      _reviewsLoading = false;
      notifyListeners();
    }
  }

  Future<void> adminDeleteReview(
    ReviewTarget target,
    String targetId,
    String reviewId,
  ) async {
    await _reviewService.deleteReview(target, targetId, reviewId);
    await loadAllReviews();
  }

  // ── Favorite Admin Delete ─────────────────────────────────────────────────

  Future<void> adminDeleteFavorite({
    required String adminUid,
    required String adminName,
    required String userId,
    required String userName,
    required String itemId,
    required FavoriteItemType itemType,
    required String itemName,
  }) async {
    await _favoriteService.adminDeleteFavorite(
      adminUid: adminUid,
      adminName: adminName,
      userId: userId,
      userName: userName,
      itemId: itemId,
      itemType: itemType,
      itemName: itemName,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    _statsSub?.cancel();
    _adminLogsSub?.cancel();
    _userRemovalLogsSub?.cancel();
    _userFavoritesSub?.cancel();
    super.dispose();
  }
}
