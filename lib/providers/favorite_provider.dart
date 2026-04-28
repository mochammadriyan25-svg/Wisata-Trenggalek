// lib/providers/favorite_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../data/services/firestore/favorite_service.dart';
import '../data/services/firestore/destination_service.dart';
import '../data/services/firestore/accommodation_service.dart';
import '../data/services/firestore/package_service.dart';
import '../data/models/favorite_model.dart';
import '../data/models/destination_model.dart';
import '../data/models/accommodation_model.dart';
import '../data/models/package_model.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  final DestinationService _destinationService = DestinationService();
  final AccommodationService _accommodationService = AccommodationService();
  final PackageService _packageService = PackageService();

  List<FavoriteModel> _favorites = [];

  // Data hasil resolve per tipe
  List<DestinationModel> _favoriteDestinations = [];
  List<AccommodationModel> _favoriteAccommodations = [];
  List<PackageModel> _favoritePackages = [];

  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<FavoriteModel>>? _favoriteSubscription;

  // ── GETTERS
  List<FavoriteModel> get favorites => _favorites;
  List<DestinationModel> get favoriteDestinations => _favoriteDestinations;
  List<AccommodationModel> get favoriteAccommodations =>
      _favoriteAccommodations;
  List<PackageModel> get favoritePackages => _favoritePackages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Cek favorit berdasarkan itemId + tipe
  bool isFavorite(String itemId, FavoriteItemType itemType) {
    return _favorites.any((f) => f.itemId == itemId && f.itemType == itemType);
  }

  void init(String userId) {
    _cancelSubscription();
    _listenFavorites(userId);
  }

  void _cancelSubscription() {
    _favoriteSubscription?.cancel();
    _favoriteSubscription = null;
  }

  void _listenFavorites(String userId) {
    _favoriteSubscription = _favoriteService
        .getUserFavorites(userId)
        .listen(
          (favorites) async {
            _favorites = favorites;
            await _loadAllFavoriteItems(favorites);
            notifyListeners();
          },
          onError: (e) {
            _errorMessage = e.toString();
            notifyListeners();
          },
        );
  }

  Future<void> _loadAllFavoriteItems(List<FavoriteModel> favorites) async {
    final destinationIds =
        favorites
            .where((f) => f.itemType == FavoriteItemType.destination)
            .map((f) => f.itemId)
            .toList();

    final accommodationIds =
        favorites
            .where((f) => f.itemType == FavoriteItemType.accommodation)
            .map((f) => f.itemId)
            .toList();

    final packageIds =
        favorites
            .where((f) => f.itemType == FavoriteItemType.package)
            .map((f) => f.itemId)
            .toList();

    // Load paralel supaya lebih cepat
    await Future.wait([
      _loadDestinations(destinationIds),
      _loadAccommodations(accommodationIds),
      _loadPackages(packageIds),
    ]);
  }

  Future<void> _loadDestinations(List<String> ids) async {
    if (ids.isEmpty) {
      _favoriteDestinations = [];
      return;
    }
    try {
      final result = <DestinationModel>[];
      for (final id in ids) {
        final item = await _destinationService.getById(id);
        if (item != null) result.add(item);
      }
      _favoriteDestinations = result;
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> _loadAccommodations(List<String> ids) async {
    if (ids.isEmpty) {
      _favoriteAccommodations = [];
      return;
    }
    try {
      final result = <AccommodationModel>[];
      for (final id in ids) {
        final item = await _accommodationService.getById(id);
        if (item != null) result.add(item);
      }
      _favoriteAccommodations = result;
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> _loadPackages(List<String> ids) async {
    if (ids.isEmpty) {
      _favoritePackages = [];
      return;
    }
    try {
      final result = <PackageModel>[];
      for (final id in ids) {
        final item = await _packageService.getById(id);
        if (item != null) result.add(item);
      }
      _favoritePackages = result;
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> toggleFavorite(
    String userId,
    String itemId,
    FavoriteItemType itemType,
  ) async {
    final alreadyFavorite = isFavorite(itemId, itemType);

    // Optimistic update
    if (alreadyFavorite) {
      _favorites.removeWhere(
        (f) => f.itemId == itemId && f.itemType == itemType,
      );
    } else {
      _favorites.add(
        FavoriteModel(
          id: '${itemType.name}_$itemId',
          userId: userId,
          itemId: itemId,
          itemType: itemType,
        ),
      );
    }
    notifyListeners();

    _setLoading(true);
    try {
      if (alreadyFavorite) {
        await _favoriteService.removeFavorite(userId, itemId, itemType);
      } else {
        await _favoriteService.addFavorite(userId, itemId, itemType);
      }
    } catch (e) {
      // Rollback jika gagal
      if (alreadyFavorite) {
        _favorites.add(
          FavoriteModel(
            id: '${itemType.name}_$itemId',
            userId: userId,
            itemId: itemId,
            itemType: itemType,
          ),
        );
      } else {
        _favorites.removeWhere(
          (f) => f.itemId == itemId && f.itemType == itemType,
        );
      }
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void reset() {
    _cancelSubscription();
    _favorites = [];
    _favoriteDestinations = [];
    _favoriteAccommodations = [];
    _favoritePackages = [];
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}
