// lib/data/models/package_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PackageModel {
  final String id;
  final String categoryId;
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final List<String> images;
  final int price;
  final double rating;
  final bool isActive;
  final Timestamp? createdAt;

  // Maps
  final double latitude;
  final double longitude;
  final String mapsUrl;

  // 360 Virtual Tour
  final bool hasVirtualTour;
  final String? maps360Url;

  const PackageModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    this.images = const [],
    required this.price,
    required double rating,
    required this.isActive,
    this.createdAt,
    // Maps
    required this.latitude,
    required this.longitude,
    required this.mapsUrl,
    // Virtual Tour
    required this.hasVirtualTour,
    this.maps360Url,
  }) : rating =
           rating < 0.0
               ? 0.0
               : rating > 5.0
               ? 5.0
               : rating,
       assert(
         !hasVirtualTour || maps360Url != null,
         'maps360Url wajib diisi jika hasVirtualTour = true',
       );

  // ── GETTERS
  bool get hasGallery => images.isNotEmpty;
  bool get isFree => price == 0;

  String get formattedPrice {
    if (isFree) return 'Gratis';
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'IDR ${formatter.format(price)}';
  }

  // ── FACTORY
  factory PackageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final hasVirtualTour = data['hasVirtualTour'] ?? false;

    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return PackageModel(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      price: (data['price'] as num?)?.toInt() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'],
      // Maps
      latitude: toDouble(data['latitude']),
      longitude: toDouble(data['longitude']),
      mapsUrl: data['mapsUrl'] ?? '',
      // Virtual Tour
      hasVirtualTour: hasVirtualTour,
      maps360Url: hasVirtualTour == true ? data['maps360Url'] : null,
    );
  }

  // ── SERIALIZATION
  Map<String, dynamic> toCreateMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'images': images,
      'price': price,
      'rating': rating,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      // Maps
      'latitude': latitude,
      'longitude': longitude,
      'mapsUrl': mapsUrl,
      // Virtual Tour
      'hasVirtualTour': hasVirtualTour,
      if (hasVirtualTour && maps360Url != null)
        'maps360Url': maps360Url
      else
        'maps360Url': null,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'images': images,
      'price': price,
      'rating': rating,
      'isActive': isActive,
      // Maps
      'latitude': latitude,
      'longitude': longitude,
      'mapsUrl': mapsUrl,
      // Virtual Tour
      'hasVirtualTour': hasVirtualTour,
      if (hasVirtualTour && maps360Url != null)
        'maps360Url': maps360Url
      else
        'maps360Url': FieldValue.delete(),
    };
  }

  // ── UTILITY
  PackageModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? location,
    String? description,
    String? imageUrl,
    List<String>? images,
    int? price,
    double? rating,
    bool? isActive,
    Timestamp? createdAt,
    // Maps
    double? latitude,
    double? longitude,
    String? mapsUrl,
    // Virtual Tour
    bool? hasVirtualTour,
    String? maps360Url,
  }) {
    return PackageModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      // Maps
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      // Virtual Tour
      hasVirtualTour: hasVirtualTour ?? this.hasVirtualTour,
      maps360Url: maps360Url ?? this.maps360Url,
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
  String toString() =>
      'PackageModel{id: $id, name: $name, location: $location, price: $formattedPrice, rating: $rating}';
}
