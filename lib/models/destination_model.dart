import 'package:cloud_firestore/cloud_firestore.dart';

class DestinationModel {
  final String id;
  final String name;
  final String location;
  final String description;
  final String category;
  final double rating;
  final String imageUrl;

  // Maps
  final double latitude;
  final double longitude;
  final String mapsUrl;

  // 360 Google Maps
  final bool hasVirtualTour;
  final String maps360Url;

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
    required this.category,
    required this.rating,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.mapsUrl,
    required this.hasVirtualTour,
    required this.maps360Url,
    required this.priceAdult,
    required this.priceChild,
    required this.isRecommended,
    this.createdAt,
  });

  factory DestinationModel.fromFirestore(
      DocumentSnapshot doc) {
    final data =
        doc.data() as Map<String, dynamic>;

    return DestinationModel(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      rating:
          (data['rating'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      latitude:
          (data['latitude'] ?? 0).toDouble(),
      longitude:
          (data['longitude'] ?? 0).toDouble(),
      mapsUrl: data['mapsUrl'] ?? '',
      hasVirtualTour:
          data['hasVirtualTour'] ?? false,
      maps360Url:
          data['maps360Url'] ?? '',
      priceAdult:
          data['priceAdult'] ?? 0,
      priceChild:
          data['priceChild'] ?? 0,
      isRecommended:
          data['isRecommended'] ?? false,
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'category': category,
      'rating': rating,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'mapsUrl': mapsUrl,
      'hasVirtualTour': hasVirtualTour,
      'maps360Url': maps360Url,
      'priceAdult': priceAdult,
      'priceChild': priceChild,
      'isRecommended': isRecommended,
      'createdAt':
          createdAt ??
              FieldValue.serverTimestamp(),
    };
  }
}