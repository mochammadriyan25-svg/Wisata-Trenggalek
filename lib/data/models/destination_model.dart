// lib/data/models/destination_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'menu_item_model.dart';

/// ID kategori kuliner — sesuaikan jika berbeda di Firestore-mu
const String kCategoryKuliner = 'cat_kuliner';

class DestinationModel {
  final String id;
  final String name;
  final String location;
  final String description;
  final String categoryId;
  final double rating;
  final String imageUrl;
  final List<String> images;

  // Maps
  final double latitude;
  final double longitude;
  final String mapsUrl;

  // 360 Virtual Tour
  final bool hasVirtualTour;
  final String? maps360Url;

  // Ticket — hanya relevan untuk NON-kuliner
  final int priceAdult;
  final int priceChild;

  // Menu — hanya relevan untuk kuliner
  final List<MenuItemModel> menus;

  final bool isRecommended;
  final Timestamp? createdAt;

  DestinationModel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.categoryId,
    required double rating,
    required this.imageUrl,
    this.images = const [],
    required this.latitude,
    required this.longitude,
    required this.mapsUrl,
    required this.hasVirtualTour,
    this.maps360Url,
    this.priceAdult = 0,
    this.priceChild = 0,
    this.menus = const [],
    required this.isRecommended,
    this.createdAt,
  }) : rating = rating.clamp(0.0, 5.0),
       assert(
         !hasVirtualTour || maps360Url != null,
         'maps360Url wajib diisi jika hasVirtualTour = true',
       );

  // ── GETTERS ───────────────────────────────────────────────────────────────

  /// Apakah destinasi ini kategori kuliner
  bool get isKuliner => categoryId == kCategoryKuliner;

  /// Apakah gratis masuk (hanya berlaku untuk non-kuliner)
  bool get isFree => priceAdult == 0;

  bool get hasGallery => images.isNotEmpty;

  /// Apakah punya daftar menu (hanya kuliner)
  bool get hasMenus => menus.isNotEmpty;

  /// Harga terendah dari daftar menu kuliner
  int? get lowestMenuPrice {
    if (!hasMenus) return null;
    return menus.map((m) => m.price).reduce((a, b) => a < b ? a : b);
  }

  /// Harga tertinggi dari daftar menu kuliner
  int? get highestMenuPrice {
    if (!hasMenus) return null;
    return menus.map((m) => m.price).reduce((a, b) => a > b ? a : b);
  }

  /// Range harga untuk ditampilkan di UI, contoh: "IDR 5.000 – IDR 50.000"
  String get priceRangeFormatted {
    if (!isKuliner) return formattedPriceAdult;
    if (!hasMenus) return 'Lihat menu';
    final formatter = NumberFormat('#,###', 'id_ID');
    if (lowestMenuPrice == highestMenuPrice) {
      return 'IDR ${formatter.format(lowestMenuPrice)}';
    }
    return 'IDR ${formatter.format(lowestMenuPrice)} – IDR ${formatter.format(highestMenuPrice)}';
  }

  String get formattedPriceAdult {
    if (isFree) return 'Gratis';
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'IDR ${formatter.format(priceAdult)}';
  }

  String get formattedPriceChild {
    if (priceChild == 0) return 'Gratis';
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'IDR ${formatter.format(priceChild)}';
  }

  // ── FACTORY ───────────────────────────────────────────────────────────────

  factory DestinationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final hasVirtualTour = data['hasVirtualTour'] ?? false;
    final categoryId = data['categoryId'] ?? '';

    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    // Parse menus hanya jika kategori kuliner
    List<MenuItemModel> parseMenus() {
      if (categoryId != kCategoryKuliner) return [];
      final raw = data['menus'];
      if (raw == null || raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(MenuItemModel.fromMap)
          .toList();
    }

    return DestinationModel(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      categoryId: categoryId,
      rating: toDouble(data['rating']),
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      latitude: toDouble(data['latitude']),
      longitude: toDouble(data['longitude']),
      mapsUrl: data['mapsUrl'] ?? '',
      hasVirtualTour: hasVirtualTour,
      maps360Url: hasVirtualTour == true ? data['maps360Url'] : null,
      // priceAdult & priceChild diabaikan untuk kuliner
      priceAdult:
          categoryId == kCategoryKuliner ? 0 : toInt(data['priceAdult']),
      priceChild:
          categoryId == kCategoryKuliner ? 0 : toInt(data['priceChild']),
      menus: parseMenus(),
      isRecommended: data['isRecommended'] ?? false,
      createdAt: data['createdAt'],
    );
  }

  // ── SERIALIZATION ─────────────────────────────────────────────────────────

  Map<String, dynamic> toCreateMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'categoryId': categoryId,
      'rating': rating,
      'imageUrl': imageUrl,
      'images': images,
      'latitude': latitude,
      'longitude': longitude,
      'mapsUrl': mapsUrl,
      'hasVirtualTour': hasVirtualTour,
      if (hasVirtualTour && maps360Url != null)
        'maps360Url': maps360Url
      else
        'maps360Url': null,
      // Kuliner: simpan menus, hapus ticket fields
      // Non-kuliner: simpan ticket, hapus menus
      if (isKuliner) ...{
        'menus': menus.map((m) => m.toMap()).toList(),
        'priceAdult': FieldValue.delete(),
        'priceChild': FieldValue.delete(),
      } else ...{
        'priceAdult': priceAdult,
        'priceChild': priceChild,
        'menus': FieldValue.delete(),
      },
      'isRecommended': isRecommended,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'categoryId': categoryId,
      'rating': rating,
      'imageUrl': imageUrl,
      'images': images,
      'latitude': latitude,
      'longitude': longitude,
      'mapsUrl': mapsUrl,
      'hasVirtualTour': hasVirtualTour,
      if (hasVirtualTour && maps360Url != null)
        'maps360Url': maps360Url
      else
        'maps360Url': FieldValue.delete(),
      if (isKuliner) ...{
        'menus': menus.map((m) => m.toMap()).toList(),
        'priceAdult': FieldValue.delete(),
        'priceChild': FieldValue.delete(),
      } else ...{
        'priceAdult': priceAdult,
        'priceChild': priceChild,
        'menus': FieldValue.delete(),
      },
      'isRecommended': isRecommended,
    };
  }

  // ── UTILITY ───────────────────────────────────────────────────────────────

  DestinationModel copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    String? categoryId,
    double? rating,
    String? imageUrl,
    List<String>? images,
    double? latitude,
    double? longitude,
    String? mapsUrl,
    bool? hasVirtualTour,
    String? maps360Url,
    int? priceAdult,
    int? priceChild,
    List<MenuItemModel>? menus,
    bool? isRecommended,
    Timestamp? createdAt,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      hasVirtualTour: hasVirtualTour ?? this.hasVirtualTour,
      maps360Url: maps360Url ?? this.maps360Url,
      priceAdult: priceAdult ?? this.priceAdult,
      priceChild: priceChild ?? this.priceChild,
      menus: menus ?? this.menus,
      isRecommended: isRecommended ?? this.isRecommended,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DestinationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DestinationModel{id: $id, name: $name, category: $categoryId, rating: $rating}';
  }
}
