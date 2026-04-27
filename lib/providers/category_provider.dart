// lib/providers/category_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/category_model.dart';
import '../data/services/firestore/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  // ── STREAM SUBSCRIPTIONS ──────────────────────────────────────────────────
  StreamSubscription<List<CategoryModel>>? _categoriesSub;

  // ── STATE ─────────────────────────────────────────────────────────────────
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── CONSTRUCTOR — ✅ auto-init, konsisten dengan provider lainnya
  CategoryProvider() {
    _listenCategories();
  }

  // ── GETTERS ───────────────────────────────────────────────────────────────
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Hanya kategori untuk destinasi (Pantai, Kuliner, Alam, dll)
  List<CategoryModel> get destinationCategories =>
      _categories.where((c) => c.isDestinationCategory).toList();

  /// Hanya kategori untuk paket wisata
  List<CategoryModel> get packageCategories =>
      _categories.where((c) => c.isPackageCategory).toList();

  /// ✅ Hanya kategori untuk akomodasi (Hotel, Villa, dll)
  List<CategoryModel> get accommodationCategories =>
      _categories.where((c) => c.isAccommodationCategory).toList();

  // ── STREAM LISTENER ───────────────────────────────────────────────────────
  void _listenCategories() {
    _setLoading(true);
    _categoriesSub?.cancel();
    _categoriesSub = _service.getAllCategories().listen(
      (list) {
        _categories = list;
        _setLoading(false);
      },
      onError: (e) {
        _errorMessage = e.toString();
        _setLoading(false);
      },
    );
  }

  // ── GET SINGLE CATEGORY ───────────────────────────────────────────────────
  Future<CategoryModel?> getById(String id) async {
    // Cek dari cache dulu sebelum fetch ke Firestore
    final cached = _categories.where((c) => c.id == id).firstOrNull;
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
    _categoriesSub?.cancel();
    super.dispose();
  }
}
