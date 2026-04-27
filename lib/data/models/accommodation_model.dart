// lib/data/models/accommodation_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AccommodationModel {
  final String id;
  final String name;
  final String categoryId;
  final String description;
  final String location;
  final String imageUrl;
  final List<String> images;

  // Maps
  final double latitude;
  final double longitude;
  final String mapsUrl;

  // 360 Virtual Tour
  final bool hasVirtualTour;
  final String? maps360Url;

  // Price (informasi only, no payment)
  final int pricePerNight;

  final double rating;
  final bool isRecommended;
  final Timestamp? createdAt;

  AccommodationModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.location,
    required this.imageUrl,
    this.images = const [],
    required this.latitude,
    required this.longitude,
    required this.mapsUrl,
    required this.hasVirtualTour,
    this.maps360Url,
    required this.pricePerNight,
    required double rating,
    required this.isRecommended,
    this.createdAt,
  })  : rating = rating.clamp(0.0, 5.0),
        assert(
          !hasVirtualTour || maps360Url != null,
          'maps360Url wajib diisi jika hasVirtualTour = true',
        );

  // ── GETTERS

  bool get isFree => pricePerNight == 0;
  bool get hasGallery => images.isNotEmpty;

  /// Format harga per malam — contoh: "IDR 150.000 / malam"
  String get formattedPricePerNight {
    if (isFree) return 'Gratis';
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'IDR ${formatter.format(pricePerNight)} / malam';
  }

  // ── FACTORY
  factory AccommodationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final hasVirtualTour = data['hasVirtualTour'] ?? false;
    return AccommodationModel(
      id: doc.id,
      name: data['name'] ?? '',
      categoryId: data['categoryId'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      mapsUrl: data['mapsUrl'] ?? '',
      hasVirtualTour: hasVirtualTour,
      maps360Url: hasVirtualTour == true ? data['maps360Url'] : null,
      pricePerNight: (data['pricePerNight'] as num?)?.toInt() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      isRecommended: data['isRecommended'] ?? false,
      createdAt: data['createdAt'],
    );
  }

  // ── SERIALIZATION
  Map<String, dynamic> toCreateMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'description': description,
      'location': location,
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
      'pricePerNight': pricePerNight,
      'rating': rating,
      'isRecommended': isRecommended,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'description': description,
      'location': location,
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
      'pricePerNight': pricePerNight,
      'rating': rating,
      'isRecommended': isRecommended,
    };
  }

  // ── UTILITY
  AccommodationModel copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? description,
    String? location,
    String? imageUrl,
    List<String>? images,
    double? latitude,
    double? longitude,
    String? mapsUrl,
    bool? hasVirtualTour,
    String? maps360Url,
    int? pricePerNight,
    double? rating,
    bool? isRecommended,
    Timestamp? createdAt,
  }) {
    return AccommodationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      hasVirtualTour: hasVirtualTour ?? this.hasVirtualTour,
      maps360Url: maps360Url ?? this.maps360Url,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      rating: rating ?? this.rating,
      isRecommended: isRecommended ?? this.isRecommended,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccommodationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AccommodationModel{id: $id, name: $name, category: $categoryId, rating: $rating}';
  }
}