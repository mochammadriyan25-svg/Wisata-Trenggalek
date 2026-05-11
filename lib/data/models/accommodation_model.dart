// lib/data/models/accommodation_model.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ── ROOM TYPE MODEL ────────────────────────────────────────────────────────

class RoomType {
  final String name;
  final int pricePerNight;
  final String description;
  final List<String> facilities; // e.g. ["WiFi", "AC", "TV", "Kamar Mandi Dalam"]
  final int maxGuest;
  final bool isAvailable;
  final bool isPopular;

  RoomType({
    required this.name,
    required this.pricePerNight,
    required this.description,
    required this.facilities,
    required this.maxGuest,
    this.isAvailable = true,
    this.isPopular = false,
  }) : assert(maxGuest > 0, 'maxGuest harus lebih dari 0'),
       assert(pricePerNight >= 0, 'pricePerNight tidak boleh negatif');

  // ── GETTERS ───────────────────────────────────────────────────────────────

  bool get isFree => pricePerNight == 0;
  bool get hasFacilities => facilities.isNotEmpty;

  String get formattedPrice {
    if (isFree) return 'Gratis';
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'IDR ${formatter.format(pricePerNight)} / malam';
  }

  String get guestLabel => '$maxGuest Tamu';

  // ── FACTORY ───────────────────────────────────────────────────────────────

  factory RoomType.fromMap(Map<String, dynamic> map) {
    return RoomType(
      name: map['name'] ?? '',
      pricePerNight: (map['pricePerNight'] as num?)?.toInt() ?? 0,
      description: map['description'] ?? '',
      facilities: List<String>.from(map['facilities'] ?? []),
      maxGuest: (map['maxGuest'] as num?)?.toInt() ?? 1,
      isAvailable: map['isAvailable'] ?? true,
      isPopular: map['isPopular'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'pricePerNight': pricePerNight,
      'description': description,
      'facilities': facilities,
      'maxGuest': maxGuest,
      'isAvailable': isAvailable,
      'isPopular': isPopular,
    };
  }

  RoomType copyWith({
    String? name,
    int? pricePerNight,
    String? description,
    List<String>? facilities,
    int? maxGuest,
    bool? isAvailable,
    bool? isPopular,
  }) {
    return RoomType(
      name: name ?? this.name,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      description: description ?? this.description,
      facilities: facilities ?? this.facilities,
      maxGuest: maxGuest ?? this.maxGuest,
      isAvailable: isAvailable ?? this.isAvailable,
      isPopular: isPopular ?? this.isPopular,
    );
  }

  @override
  String toString() =>
      'RoomType{name: $name, price: $formattedPrice, maxGuest: $maxGuest}';
}

// ── ACCOMMODATION MODEL ────────────────────────────────────────────────────

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

  // Harga dasar — digunakan sebagai fallback jika roomTypes kosong.
  // Jika roomTypes tidak kosong, gunakan [effectiveStartingPrice] sebagai
  // "harga mulai dari" agar tidak ada konflik data.
  final int pricePerNight;

  // Tipe kamar — boleh kosong jika akomodasi belum punya data tipe kamar
  final List<RoomType> roomTypes;

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
    this.roomTypes = const [],
    required double rating,
    required this.isRecommended,
    this.createdAt,
  }) : rating = rating.clamp(0.0, 5.0),
       assert(
         !hasVirtualTour || maps360Url != null,
         'maps360Url wajib diisi jika hasVirtualTour = true',
       ),
       assert(pricePerNight >= 0, 'pricePerNight tidak boleh negatif');

  // ── GETTERS ───────────────────────────────────────────────────────────────

  bool get isFree => effectiveStartingPrice == 0;
  bool get hasGallery => images.isNotEmpty;
  bool get hasRoomTypes => roomTypes.isNotEmpty;

  /// Harga terendah dari roomTypes jika ada,
  /// fallback ke pricePerNight jika roomTypes kosong.
  int get effectiveStartingPrice {
    if (roomTypes.isNotEmpty) {
      return roomTypes.map((r) => r.pricePerNight).reduce(min);
    }
    return pricePerNight;
  }

  /// Tipe kamar yang tersedia saja
  List<RoomType> get availableRoomTypes =>
      roomTypes.where((r) => r.isAvailable).toList();

  /// Tipe kamar yang paling populer (badge "Terpopuler")
  RoomType? get popularRoomType =>
      roomTypes.where((r) => r.isPopular).firstOrNull;

  /// Format harga mulai dari — konsisten untuk ditampilkan di card & detail
  String get formattedStartingPrice {
    if (isFree) return 'Gratis';
    final formatter = NumberFormat('#,###', 'id_ID');
    final prefix = hasRoomTypes ? 'Mulai IDR' : 'IDR';
    return '$prefix ${formatter.format(effectiveStartingPrice)} / malam';
  }

  /// Getter lama — dipertahankan agar tidak ada breaking change
  /// di widget yang sudah pakai [formattedPricePerNight]
  String get formattedPricePerNight => formattedStartingPrice;

  // ── FACTORY ───────────────────────────────────────────────────────────────

  factory AccommodationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final hasVirtualTour = data['hasVirtualTour'] ?? false;

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

    return AccommodationModel(
      id: doc.id,
      name: data['name'] ?? '',
      categoryId: data['categoryId'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      latitude: toDouble(data['latitude']),
      longitude: toDouble(data['longitude']),
      mapsUrl: data['mapsUrl'] ?? '',
      hasVirtualTour: hasVirtualTour,
      maps360Url: hasVirtualTour == true ? data['maps360Url'] : null,
      pricePerNight: toInt(data['pricePerNight']),
      roomTypes:
          (data['roomTypes'] as List<dynamic>?)
              ?.map((r) => RoomType.fromMap(r as Map<String, dynamic>))
              .toList() ??
          [],
      rating: toDouble(data['rating']),
      isRecommended: data['isRecommended'] ?? false,
      createdAt: data['createdAt'],
    );
  }

  // ── SERIALIZATION ─────────────────────────────────────────────────────────

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
      'roomTypes': roomTypes.map((r) => r.toMap()).toList(),
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
      'roomTypes': roomTypes.map((r) => r.toMap()).toList(),
      'rating': rating,
      'isRecommended': isRecommended,
    };
  }

  // ── UTILITY ───────────────────────────────────────────────────────────────

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
    List<RoomType>? roomTypes,
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
      roomTypes: roomTypes ?? this.roomTypes,
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
  String toString() =>
      'AccommodationModel{id: $id, name: $name, category: $categoryId, '
      'rating: $rating, roomTypes: ${roomTypes.length}}';
}