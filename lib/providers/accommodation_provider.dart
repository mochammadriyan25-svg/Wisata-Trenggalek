// lib/providers/accommodation_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/accommodation_model.dart';
import '../data/services/firestore/accommodation_service.dart';

class AccommodationProvider extends ChangeNotifier {
  final AccommodationService _service = AccommodationService();

  // ── STREAM SUBSCRIPTIONS ──────────────────────────────────────────────────
  StreamSubscription<List<AccommodationModel>>? _allAccomSub;
  StreamSubscription<List<AccommodationModel>>? _recommendedSub;

  // ── STATE ─────────────────────────────────────────────────────────────────
  List<AccommodationModel> _allAccommodations = [];
  List<AccommodationModel> _recommendedAccommodations = [];
  List<AccommodationModel> _filteredAccommodations = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategoryId = '';
  String _searchKeyword = '';

  // ── CONSTRUCTOR — init otomatis, tidak perlu panggil init() manual
  AccommodationProvider() {
    _listenAllAccommodations();
    _listenRecommendedAccommodations();
  }

  // ── GETTERS ───────────────────────────────────────────────────────────────
  List<AccommodationModel> get allAccommodations => _allAccommodations;
  List<AccommodationModel> get recommendedAccommodations =>
      _recommendedAccommodations;
  List<AccommodationModel> get filteredAccommodations => _filteredAccommodations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategoryId => _selectedCategoryId;
  bool get hasFilter =>
      _selectedCategoryId.isNotEmpty || _searchKeyword.isNotEmpty;

  // ── STREAM LISTENERS ──────────────────────────────────────────────────────
  void _listenAllAccommodations() {
    _setLoading(true);
    _allAccomSub?.cancel();
    _allAccomSub = _service.getAllAccommodations().listen(
      (list) {
        _allAccommodations = list;
        _applyFilter();
        _setLoading(false);
      },
      onError: (e) {
        _errorMessage = e.toString();
        _setLoading(false);
      },
    );
  }

  void _listenRecommendedAccommodations() {
    _recommendedSub?.cancel();
    _recommendedSub = _service.getRecommendedAccommodations().listen(
      (list) {
        _recommendedAccommodations = list;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
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
    List<AccommodationModel> result = _allAccommodations;

    if (_selectedCategoryId.isNotEmpty) {
      result =
          result
              .where((a) => a.categoryId == _selectedCategoryId)
              .toList();
    }

    if (_searchKeyword.isNotEmpty) {
      result =
          result
              .where((a) => a.name.toLowerCase().contains(_searchKeyword))
              .toList();
    }

    _filteredAccommodations = result;
    notifyListeners();
  }

  void clearFilter() {
    _selectedCategoryId = '';
    _searchKeyword = '';
    _applyFilter();
  }

  // ── GET SINGLE ACCOMMODATION ──────────────────────────────────────────────
  Future<AccommodationModel?> getById(String id) async {
    final cached = _allAccommodations.where((a) => a.id == id).firstOrNull;
    if (cached != null) return cached;
    return await _service.getById(id);
  }

  // ── STREAM SINGLE ACCOMMODATION ───────────────────────────────────────────
  Stream<AccommodationModel?> streamById(String id) {
    return _service.streamById(id);
  }

  // ── UTILITY ───────────────────────────────────────────────────────────────
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
    _allAccomSub?.cancel();
    _recommendedSub?.cancel();
    super.dispose();
  }
}