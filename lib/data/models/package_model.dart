// lib/data/models/package_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ── PACKAGE TIER MODEL ─────────────────────────────────────────────────────

class PackageTier {
  final String name;
  final int price;
  final String description;
  final List<String> includes;
  final int minPerson;
  final bool isPopular;

  PackageTier({
    required this.name,
    required this.price,
    required this.description,
    required this.includes,
    required this.minPerson,
    this.isPopular = false,
  });

  String get formattedPrice {
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'IDR ${formatter.format(price)}';
  }

  factory PackageTier.fromMap(Map<String, dynamic> map) {
    return PackageTier(
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      description: map['description'] ?? '',
      includes: List<String>.from(map['includes'] ?? []),
      minPerson: (map['minPerson'] as num?)?.toInt() ?? 1,
      isPopular: map['isPopular'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'includes': includes,
      'minPerson': minPerson,
      'isPopular': isPopular,
    };
  }
}

// ── PACKAGE MODEL ──────────────────────────────────────────────────────────

class PackageModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> images;
  final int price;
  final int durationDays;
  final int durationNights;
  final List<String> includes;
  final List<String> destinationIds;
  final List<PackageTier> tiers;
  final bool isActive;
  final Timestamp? createdAt;

  // ── RATING
  final double rating;

  PackageModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.images = const [],
    required this.price,
    required this.durationDays,
    required this.durationNights,
    required this.includes,
    required this.destinationIds,
    this.tiers = const [],
    required this.isActive,
    this.createdAt,
    required double rating,
  }) : rating = rating.clamp(0.0, 5.0);

  // ── GETTERS ───────────────────────────────────────────────────────────────

  String get durationLabel => '$durationDays Hari $durationNights Malam';

  String get formattedPrice {
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'IDR ${formatter.format(price)}';
  }

  bool get isDurationValid => durationNights == durationDays - 1;
  bool get hasGallery => images.isNotEmpty;
  bool get hasDestinations => destinationIds.isNotEmpty;
  bool get hasTiers => tiers.isNotEmpty;

  /// Tier yang paling populer (badge "Terlaris")
  PackageTier? get popularTier => tiers.where((t) => t.isPopular).firstOrNull;

  /// Rating
  String get ratingLabel => rating.toStringAsFixed(1); // "4.7"

  // ── FACTORY ───────────────────────────────────────────────────────────────

  factory PackageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

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

    return PackageModel(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      price: toInt(data['price']),
      durationDays: toInt(data['durationDays']),
      durationNights: toInt(data['durationNights']),
      includes: List<String>.from(data['includes'] ?? []),
      destinationIds: List<String>.from(data['destinationIds'] ?? []),
      tiers:
          (data['tiers'] as List<dynamic>?)
              ?.map((t) => PackageTier.fromMap(t as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'],
      rating: toDouble(data['rating']),
    );
  }

  // ── SERIALIZATION ─────────────────────────────────────────────────────────

  Map<String, dynamic> toCreateMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'images': images,
      'price': price,
      'durationDays': durationDays,
      'durationNights': durationNights,
      'includes': includes,
      'destinationIds': destinationIds,
      'tiers': tiers.map((t) => t.toMap()).toList(),
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      // Rating di-init 0.0 saat package pertama dibuat
      'rating': 0.0,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'images': images,
      'price': price,
      'durationDays': durationDays,
      'durationNights': durationNights,
      'includes': includes,
      'destinationIds': destinationIds,
      'tiers': tiers.map((t) => t.toMap()).toList(),
      'isActive': isActive,
      // rating TIDAK di-update dari sini,
      // dikelola oleh repository saat ada review baru masuk
    };
  }

  // ── UTILITY ───────────────────────────────────────────────────────────────

  PackageModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    String? imageUrl,
    List<String>? images,
    int? price,
    int? durationDays,
    int? durationNights,
    List<String>? includes,
    List<String>? destinationIds,
    List<PackageTier>? tiers,
    bool? isActive,
    Timestamp? createdAt,
    double? rating,
  }) {
    return PackageModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
      durationNights: durationNights ?? this.durationNights,
      includes: includes ?? this.includes,
      destinationIds: destinationIds ?? this.destinationIds,
      tiers: tiers ?? this.tiers,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PackageModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PackageModel{id: $id, name: $name, price: $formattedPrice, duration: $durationLabel, rating: $ratingLabel}';
  }
}
