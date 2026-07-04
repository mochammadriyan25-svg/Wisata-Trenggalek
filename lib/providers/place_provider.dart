// lib/providers/place_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/data/models/place_model.dart';
import 'package:aplikasi_wisata/data/services/firestore/place_service.dart';

class PlaceProvider extends ChangeNotifier {
  final PlaceService _service = PlaceService();

  List<PlaceModel> _allPlaces = [];
  bool _isLoading = false;
  String? _errorMessage; // ✅ NEW
  StreamSubscription<List<PlaceModel>>? _sub;

  // ── GETTERS ───────────────────────────────────────────────────────────────

  List<PlaceModel> get allPlaces => _allPlaces;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage; // ✅ NEW

  /// Hanya tempat ibadah
  List<PlaceModel> get worshipPlaces =>
      _allPlaces.where((p) => p.placeType == PlaceType.worship).toList();

  /// Hanya fasilitas kesehatan
  List<PlaceModel> get healthPlaces =>
      _allPlaces.where((p) => p.placeType == PlaceType.health).toList();

  // ✅ NEW: Filter by categoryId
  List<PlaceModel> getPlacesByCategory(String categoryId) =>
      _allPlaces.where((p) => p.categoryId == categoryId).toList();

  PlaceProvider() {
    _listenPlaces();
  }

  void _listenPlaces() {
    _isLoading = true;
    _sub?.cancel();
    _sub = _service.getAllPlaces().listen(
      (places) {
        _allPlaces = places;
        _isLoading = false;
        _errorMessage = null; // ✅ Clear error saat sukses
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString(); // ✅ Tangkap error
        debugPrint('[PlaceProvider] error: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ✅ NEW
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
