// lib/providers/package_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/package_model.dart';
import '../data/services/firestore/package_service.dart';

class PackageProvider extends ChangeNotifier {
  final PackageService _service = PackageService();

  // ── STREAM SUBSCRIPTIONS ──────────────────────────────────────────────────
  StreamSubscription<List<PackageModel>>? _packagesSub;

  // ── STATE ─────────────────────────────────────────────────────────────────
  List<PackageModel> _allPackages = [];
  List<PackageModel> _filteredPackages = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategoryId = '';
  String _searchKeyword = '';

  // ── GETTERS ───────────────────────────────────────────────────────────────
  List<PackageModel> get allPackages => _allPackages;
  List<PackageModel> get filteredPackages => _filteredPackages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategoryId => _selectedCategoryId;
  bool get hasFilter => _selectedCategoryId.isNotEmpty || _searchKeyword.isNotEmpty;

  // ── INIT ──────────────────────────────────────────────────────────────────
  void init() {
    _listenActivePackages();
  }

  void _listenActivePackages() {
    _setLoading(true);
    _packagesSub?.cancel();
    _packagesSub = _service.getActivePackages().listen(
      (list) {
        _allPackages = list;
        _applyFilter();
        _setLoading(false);
      },
      onError: (e) {
        _errorMessage = e.toString();
        _setLoading(false);
      },
    );
  }

  // ── FILTER & SEARCH ───────────────────────────────────────────────────────

  /// Filter berdasarkan categoryId — sesuai flow:
  /// user tap kategori "Paket Wisata" → tampilkan packages by categoryId
  void filterByCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilter();
  }

  void search(String keyword) {
    _searchKeyword = keyword.toLowerCase();
    _applyFilter();
  }

  void _applyFilter() {
    List<PackageModel> result = _allPackages;

    if (_selectedCategoryId.isNotEmpty) {
      result = result
          .where((p) => p.categoryId == _selectedCategoryId)
          .toList();
    }

    if (_searchKeyword.isNotEmpty) {
      result = result
          .where((p) => p.name.toLowerCase().contains(_searchKeyword))
          .toList();
    }

    _filteredPackages = result;
    notifyListeners();
  }

  void clearFilter() {
    _selectedCategoryId = '';
    _searchKeyword = '';
    _applyFilter();
  }

  // ── SORT ──────────────────────────────────────────────────────────────────
  void sortByPrice({bool ascending = true}) {
    _filteredPackages.sort((a, b) =>
        ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price));
    notifyListeners();
  }

  void sortByDuration({bool ascending = true}) {
    _filteredPackages.sort((a, b) => ascending
        ? a.durationDays.compareTo(b.durationDays)
        : b.durationDays.compareTo(a.durationDays));
    notifyListeners();
  }

  // ── GET SINGLE PACKAGE ────────────────────────────────────────────────────
  Future<PackageModel?> getById(String id) async {
    // Cek dari cache dulu sebelum fetch ke Firestore
    final cached = _allPackages.where((p) => p.id == id).firstOrNull;
    if (cached != null) return cached;

    try {
      return await _service.getById(id);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
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
    _packagesSub?.cancel();
    super.dispose();
  }
}