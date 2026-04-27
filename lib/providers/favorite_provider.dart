import 'dart:async';
import 'package:flutter/material.dart';
import '../data/services/firestore/favorite_service.dart';
import '../data/services/firestore/destination_service.dart';
import '../data/models/destination_model.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  final DestinationService _destinationService = DestinationService();

  List<String> _favoriteIds = [];
  List<DestinationModel> _favoriteDestinations = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<String>>? _favoriteSubscription;

  List<String> get favoriteIds => _favoriteIds;
  List<DestinationModel> get favoriteDestinations => _favoriteDestinations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isFavorite(String destinationId) => _favoriteIds.contains(destinationId);

  void init(String userId) {
    _cancelSubscription();
    _listenFavoriteIds(userId);
  }

  void _cancelSubscription() {
    _favoriteSubscription?.cancel();
    _favoriteSubscription = null;
  }

  void _listenFavoriteIds(String userId) {
    _favoriteSubscription = _favoriteService
        .getUserFavoriteIds(userId)
        .listen(
          (ids) async {
            _favoriteIds = ids;
            await _loadFavoriteDestinations(ids);
            notifyListeners();
          },
          onError: (e) {
            _errorMessage = e.toString();
            notifyListeners();
          },
        );
  }

  Future<void> _loadFavoriteDestinations(List<String> ids) async {
    if (ids.isEmpty) {
      _favoriteDestinations = [];
      return;
    }
    try {
      final List<DestinationModel> result = [];
      for (final id in ids) {
        final destination = await _destinationService.getById(id);
        if (destination != null) result.add(destination);
      }
      _favoriteDestinations = result;
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> toggleFavorite(String userId, String destinationId) async {
    final alreadyFavorite = isFavorite(destinationId);

    // Optimistic update
    if (alreadyFavorite) {
      _favoriteIds.remove(destinationId);
    } else {
      _favoriteIds.add(destinationId);
    }
    notifyListeners();

    _setLoading(true);
    try {
      if (alreadyFavorite) {
        await _favoriteService.removeFavorite(userId, destinationId);
      } else {
        await _favoriteService.addFavorite(userId, destinationId);
      }
    } catch (e) {
      // Rollback jika gagal
      if (alreadyFavorite) {
        _favoriteIds.add(destinationId);
      } else {
        _favoriteIds.remove(destinationId);
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
    _favoriteIds = [];
    _favoriteDestinations = [];
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
