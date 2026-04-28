// lib/providers/destination_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/destination_model.dart';
import '../data/services/firestore/destination_service.dart';

class DestinationProvider extends ChangeNotifier {
  final DestinationService _service = DestinationService();

  // ── STREAM SUBSCRIPTIONS ──────────────────────────────────────────────────
  StreamSubscription<List<DestinationModel>>? _allDestSub;
  StreamSubscription<List<DestinationModel>>? _recommendedSub;

  // ── STATE ─────────────────────────────────────────────────────────────────
  List<DestinationModel> _allDestinations = [];
  List<DestinationModel> _recommendedDestinations = [];
  List<DestinationModel> _filteredDestinations = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategoryId = '';
  String _searchKeyword = '';

  // ── CONSTRUCTOR ───────────────────────────────────────────────────────────
  DestinationProvider() {
    _listenAllDestinations();
    _listenRecommendedDestinations();
  }

  // ── GETTERS ───────────────────────────────────────────────────────────────
  List<DestinationModel> get allDestinations => _allDestinations;
  List<DestinationModel> get recommendedDestinations =>
      _recommendedDestinations;
  List<DestinationModel> get filteredDestinations => _filteredDestinations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategoryId => _selectedCategoryId;
  bool get hasFilter =>
      _selectedCategoryId.isNotEmpty || _searchKeyword.isNotEmpty;

  // ── STREAM LISTENERS ──────────────────────────────────────────────────────
  void _listenAllDestinations() {
    _setLoading(true);
    _allDestSub?.cancel();
    _allDestSub = _service.getAllDestinations().listen(
      (list) {
        _allDestinations = list;
        _errorMessage = null; // clear error saat data berhasil masuk
        _applyFilter();
        _setLoading(false);
      },
      onError: (e) {
        _errorMessage = e.toString(); // di-set sebelum notifyListeners
        _setLoading(false);
      },
    );
  }

  void _listenRecommendedDestinations() {
    _recommendedSub?.cancel();
    _recommendedSub = _service.getRecommendedDestinations().listen(
      (list) {
        _recommendedDestinations = list;
        notifyListeners();
      },
      onError: (e) {
        // Error recommended tidak masuk _errorMessage utama
        // agar tidak merusak tampilan ExplorePage
        debugPrint('Recommended stream error: $e');
        notifyListeners();
      },
    );
  }

  // ── FILTER & SEARCH ───────────────────────────────────────────────────────
  void filterByCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilter();
  }

  void search(String keyword) {
    _searchKeyword = keyword.toLowerCase();
    _applyFilter();
  }

  void _applyFilter() {
    List<DestinationModel> result = _allDestinations;

    if (_selectedCategoryId.isNotEmpty) {
      result =
          result.where((d) => d.categoryId == _selectedCategoryId).toList();
    }

    if (_searchKeyword.isNotEmpty) {
      result =
          result
              .where((d) => d.name.toLowerCase().contains(_searchKeyword))
              .toList();
    }

    _filteredDestinations = result;
    notifyListeners();
  }

  void clearFilter() {
    _selectedCategoryId = '';
    _searchKeyword = '';
    _applyFilter();
  }

  // ── CLEAR ERROR + RESTART STREAM ──────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
    _listenAllDestinations(); // restart stream yang mungkin sudah mati
  }

  // ── GET SINGLE DESTINATION ────────────────────────────────────────────────
  Future<DestinationModel?> getById(String id) async {
    final cached = _allDestinations.where((d) => d.id == id).firstOrNull;
    if (cached != null) return cached;
    return await _service.getById(id);
  }

  // ── STREAM SINGLE DESTINATION ─────────────────────────────────────────────
  Stream<DestinationModel?> streamById(String id) {
    return _service.streamById(id);
  }

  // ── UTILITY ───────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _allDestSub?.cancel();
    _recommendedSub?.cancel();
    super.dispose();
  }
}
