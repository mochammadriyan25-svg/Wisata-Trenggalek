// lib/data/models/category_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryType {
  static const String package = 'package';
  static const String destination = 'destination';
  static const String accommodation = 'accommodation';
  static const String placeWorship = 'place_worship'; // ✅ NEW
  static const String placeHealth = 'place_health'; // ✅ NEW

  static const List<String> values = [
    package,
    destination,
    accommodation,
    placeWorship,
    placeHealth,
  ];
}

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String imageUrl;
  final String type;
  final Timestamp? createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
    required this.type,
    this.createdAt,
  });

  // ── GETTERS
  bool get isPackageCategory => type == CategoryType.package;
  bool get isDestinationCategory => type == CategoryType.destination;
  bool get isAccommodationCategory => type == CategoryType.accommodation;
  bool get isPlaceWorshipCategory => type == CategoryType.placeWorship; // ✅ NEW
  bool get isPlaceHealthCategory => type == CategoryType.placeHealth; // ✅ NEW
  bool get isPlaceCategory =>
      isPlaceWorshipCategory || isPlaceHealthCategory; // ✅ Helper

  // ✅ collectionName untuk semua type
  String get collectionName {
    switch (type) {
      case CategoryType.package:
        return 'packages';
      case CategoryType.accommodation:
        return 'accommodations';
      case CategoryType.destination:
        return 'destinations';
      case CategoryType.placeWorship:
      case CategoryType.placeHealth:
        return 'places';
      default:
        return 'destinations';
    }
  }

  // ── FACTORY
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = data['type'] ?? CategoryType.destination;

    assert(CategoryType.values.contains(type), 'Unknown category type: $type');

    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      type:
          CategoryType.values.contains(type) ? type : CategoryType.destination,
      createdAt: data['createdAt'],
    );
  }

  // ── SERIALIZATION
  Map<String, dynamic> toCreateMap() {
    return {
      'name': name,
      'icon': icon,
      'imageUrl': imageUrl,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {'name': name, 'icon': icon, 'imageUrl': imageUrl, 'type': type};
  }

  // ── UTILITY
  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? imageUrl,
    String? type,
    Timestamp? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CategoryModel{id: $id, name: $name, type: $type}';
  }
}
