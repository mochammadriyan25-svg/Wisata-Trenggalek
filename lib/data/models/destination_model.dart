// lib/data/models/destination_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  // Ticket
  final int priceAdult;
  final int priceChild;
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
    required this.priceAdult,
    required this.priceChild,
    required this.isRecommended,
    this.createdAt,
  }) : rating = rating.clamp(0.0, 5.0),
       assert(
         !hasVirtualTour || maps360Url != null,
         'maps360Url wajib diisi jika hasVirtualTour = true',
       );

  // ── GETTERS ───────────────────────────────────────────────────────────────

  bool get isFree => priceAdult == 0;
  bool get hasGallery => images.isNotEmpty;

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

    // Helper: aman parse angka dari String maupun num
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

    return DestinationModel(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      rating: toDouble(data['rating']),
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      latitude: toDouble(data['latitude']),
      longitude: toDouble(data['longitude']),
      mapsUrl: data['mapsUrl'] ?? '',
      hasVirtualTour: hasVirtualTour,
      maps360Url: hasVirtualTour == true ? data['maps360Url'] : null,
      priceAdult: toInt(data['priceAdult']),
      priceChild: toInt(data['priceChild']),
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
      'priceAdult': priceAdult,
      'priceChild': priceChild,
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
      'priceAdult': priceAdult,
      'priceChild': priceChild,
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
