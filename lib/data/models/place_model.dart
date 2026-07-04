// lib/data/models/place_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'destination_model.dart' show StreetViewConfig, Image360Config;

// ── Local helpers
double _pd(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  return double.tryParse(val.toString()) ?? 0.0;
}

// ── Tipe tempat (klasifikasi utama: ibadah vs kesehatan)
enum PlaceType { worship, health }

// ── PlaceModel
class PlaceModel {
  final String id;
  final PlaceType placeType;
  final String? categoryId; // ✅ NEW: referensi ke CategoryModel tipe 'place'
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final List<String> images;

  // Maps
  final double latitude;
  final double longitude;
  final String mapsUrl;

  // Virtual Tour
  final bool hasVirtualTour;
  final String? panoId;
  final StreetViewConfig streetView;
  final Image360Config image360;

  final Timestamp? createdAt;

  PlaceModel({
    required this.id,
    required this.placeType,
    this.categoryId,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    this.images = const [],
    required this.latitude,
    required this.longitude,
    required this.mapsUrl,
    required this.hasVirtualTour,
    this.panoId,
    this.streetView = const StreetViewConfig(),
    this.image360 = const Image360Config(),
    this.createdAt,
  });

  // ── GETTERS
  bool get isWorship => placeType == PlaceType.worship;
  bool get isHealth => placeType == PlaceType.health;
  bool get hasGallery => images.isNotEmpty;
  bool get hasPhotoSphere => panoId != null && panoId!.isNotEmpty;
  bool get hasImage360 => image360.isValid;

  String get placeTypeLabel =>
      placeType == PlaceType.worship ? 'Tempat Ibadah' : 'Fasilitas Kesehatan';

  // ── FACTORY
  factory PlaceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final hasVirtualTour = data['hasVirtualTour'] ?? false;

    return PlaceModel(
      id: doc.id,
      placeType:
          data['placeType'] == 'health' ? PlaceType.health : PlaceType.worship,
      categoryId: data['categoryId'], // ✅ NEW
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      latitude: _pd(data['latitude']),
      longitude: _pd(data['longitude']),
      mapsUrl: data['mapsUrl'] ?? '',
      hasVirtualTour: hasVirtualTour,
      panoId: data['panoId'] as String?,
      streetView: () {
        final raw = data['streetView'];
        return raw is Map<String, dynamic>
            ? StreetViewConfig.fromMap(raw)
            : const StreetViewConfig();
      }(),
      image360: () {
        final raw = data['image360'];
        return raw is Map<String, dynamic>
            ? Image360Config.fromMap(raw)
            : const Image360Config();
      }(),
      createdAt: data['createdAt'],
    );
  }

  // ── SERIALIZATION
  Map<String, dynamic> toCreateMap() => {
    'placeType': placeType.name,
    if (categoryId != null) 'categoryId': categoryId,
    'name': name,
    'location': location,
    'description': description,
    'imageUrl': imageUrl,
    'images': images,
    'latitude': latitude,
    'longitude': longitude,
    'mapsUrl': mapsUrl,
    'hasVirtualTour': hasVirtualTour,
    if (panoId != null) 'panoId': panoId,
    'streetView': streetView.toMap(),
    if (image360.isValid) 'image360': image360.toMap(),
    'createdAt': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> toUpdateMap() => {
    'placeType': placeType.name,
    if (categoryId != null)
      'categoryId': categoryId
    else
      'categoryId': FieldValue.delete(),
    'name': name,
    'location': location,
    'description': description,
    'imageUrl': imageUrl,
    'images': images,
    'latitude': latitude,
    'longitude': longitude,
    'mapsUrl': mapsUrl,
    'hasVirtualTour': hasVirtualTour,
    if (panoId != null) 'panoId': panoId else 'panoId': FieldValue.delete(),
    'streetView': streetView.toMap(),
    if (image360.isValid)
      'image360': image360.toMap()
    else
      'image360': FieldValue.delete(),
  };

  PlaceModel copyWith({
    String? id,
    PlaceType? placeType,
    String? categoryId,
    String? name,
    String? location,
    String? description,
    String? imageUrl,
    List<String>? images,
    double? latitude,
    double? longitude,
    String? mapsUrl,
    bool? hasVirtualTour,
    String? panoId,
    StreetViewConfig? streetView,
    Image360Config? image360,
    Timestamp? createdAt,
  }) => PlaceModel(
    id: id ?? this.id,
    placeType: placeType ?? this.placeType,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    location: location ?? this.location,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    images: images ?? this.images,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    mapsUrl: mapsUrl ?? this.mapsUrl,
    hasVirtualTour: hasVirtualTour ?? this.hasVirtualTour,
    panoId: panoId ?? this.panoId,
    streetView: streetView ?? this.streetView,
    image360: image360 ?? this.image360,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PlaceModel{id: $id, name: $name, type: ${placeType.name}}';
}
