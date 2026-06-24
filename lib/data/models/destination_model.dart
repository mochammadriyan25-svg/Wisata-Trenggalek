// lib/data/models/destination_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'menu_item_model.dart';

const String kCategoryKuliner = 'cat_kuliner';

// ── Helper konversi double (dipakai semua config) ─────────────────────────────
double _toDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  return double.tryParse(val.toString()) ?? 0.0;
}

double? _toNullableDouble(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toDouble();
  return double.tryParse(val.toString());
}

// ── Helper konversi int nullable (untuk field harga: null = belum diinput) ────
int? _toNullableInt(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toInt();
  return int.tryParse(val.toString());
}

// ── Helper format harga tunggal (dipakai di halaman Detail) ───────────────────
// null = belum diinput  -> "-"
// 0    = gratis          -> "Gratis"
// > 0  = harga normal    -> "Rp 15.000"
String _formatRupiah(int? price) {
  if (price == null) return '-';
  if (price == 0) return 'Gratis';
  final formatter = NumberFormat('#,###', 'id_ID');
  return 'Rp ${formatter.format(price)}';
}

// ── Helper format range harga (dipakai di card Explore) ───────────────────────
// Entry null diabaikan dari perhitungan range.
// - Semua null            -> "-"
// - Tersisa 1 nilai unik  -> format single (bukan range)
// - Tersisa ≥2 nilai beda -> "Rp {min} - {max}" atau "Gratis - Rp {max}"
//   jika min == 0 (angka max TIDAK mengulang "Rp" kecuali min adalah "Gratis")
String _formatRupiahRange(List<int?> prices) {
  final valid = prices.whereType<int>().toList();
  if (valid.isEmpty) return '-';

  final minPrice = valid.reduce((a, b) => a < b ? a : b);
  final maxPrice = valid.reduce((a, b) => a > b ? a : b);

  if (minPrice == maxPrice) return _formatRupiah(minPrice);

  final formatter = NumberFormat('#,###', 'id_ID');
  final minStr = minPrice == 0 ? 'Gratis' : 'Rp ${formatter.format(minPrice)}';
  final maxStr =
      minPrice == 0
          ? 'Rp ${formatter.format(maxPrice)}'
          : formatter.format(maxPrice);

  return '$minStr - $maxStr';
}

/// Konfigurasi orientasi awal kamera Street View.
///
/// Disimpan di Firestore sebagai Map bernama `streetView`:
///   streetView: { heading: 219, pitch: -2 }
///
/// heading: arah pandang awal 0–360° (0=Utara, 90=Timur, 180=Selatan, 270=Barat)
/// pitch  : sudut vertikal -90..90° (0=lurus, negatif=bawah, positif=atas)
class StreetViewConfig {
  final double heading;
  final double pitch;

  const StreetViewConfig({this.heading = 0.0, this.pitch = 0.0});

  factory StreetViewConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const StreetViewConfig();
    return StreetViewConfig(
      heading: _toDouble(map['heading']),
      pitch: _toDouble(map['pitch']),
    );
  }

  Map<String, dynamic> toMap() => {'heading': heading, 'pitch': pitch};

  StreetViewConfig copyWith({double? heading, double? pitch}) =>
      StreetViewConfig(
        heading: heading ?? this.heading,
        pitch: pitch ?? this.pitch,
      );
}

/// Konfigurasi Foto 360° UGC (Pannellum viewer).
///
/// Disimpan di Firestore sebagai Map bernama `image360`:
///   image360: {
///     url     : "https://lh3.googleusercontent.com/...=w4096-h2048-k-no",
///     heading : 90,
///     pitch   : -10
///   }
///
/// heading/pitch terpisah dari Street View karena foto UGC sering diambil
/// dengan orientasi berbeda dari panorama Street View di titik yang sama.
class Image360Config {
  final String url;
  final double heading;
  final double pitch;

  const Image360Config({this.url = '', this.heading = 0.0, this.pitch = 0.0});

  /// true jika ada URL gambar 360° yang valid
  bool get isValid => url.isNotEmpty;

  factory Image360Config.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const Image360Config();
    return Image360Config(
      url: (map['url'] ?? '') as String,
      heading: _toDouble(map['heading']),
      pitch: _toDouble(map['pitch']),
    );
  }

  Map<String, dynamic> toMap() => {
    'url': url,
    'heading': heading,
    'pitch': pitch,
  };

  Image360Config copyWith({String? url, double? heading, double? pitch}) =>
      Image360Config(
        url: url ?? this.url,
        heading: heading ?? this.heading,
        pitch: pitch ?? this.pitch,
      );
}

class DestinationModel {
  final String id;
  final String name;
  final String location;
  final String description;
  final String categoryId;
  final double rating;
  final String imageUrl;
  final List<String> images;

  // ── Maps ──────────────────────────────────────────────────────────────────
  final double latitude;
  final double longitude;
  final String mapsUrl;

  // ── Virtual Tour ──────────────────────────────────────────────────────────
  final bool hasVirtualTour;

  /// ID panorama Photo Sphere (format AF1Qip...) via Maps JS API. Opsional.
  final String? panoId;

  /// Konfigurasi orientasi Street View (heading + pitch).
  /// Street View memakai latitude/longitude top-level untuk mencari panorama.
  final StreetViewConfig streetView;

  /// Konfigurasi Foto 360° UGC (url + heading + pitch).
  final Image360Config image360;

  /// null = belum diinput, 0 = gratis, >0 = harga normal
  final int? priceAdult;

  /// null = belum diinput, 0 = gratis, >0 = harga normal
  final int? priceChild;

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
    this.panoId,
    this.streetView = const StreetViewConfig(),
    this.image360 = const Image360Config(),
    this.priceAdult,
    this.priceChild,
    this.menus = const [],
    required this.isRecommended,
    this.createdAt,
  }) : rating = rating.clamp(0.0, 5.0);

  // ── GETTERS ───────────────────────────────────────────────────────────────

  bool get isKuliner => categoryId == kCategoryKuliner;

  /// true hanya jika harga dewasa eksplisit 0 (gratis), bukan saat belum diinput
  bool get isFree => priceAdult == 0;

  bool get hasGallery => images.isNotEmpty;
  bool get hasMenus => menus.isNotEmpty;

  /// true jika punya Photo Sphere via Maps JS API (AF1Qip format)
  bool get hasPhotoSphere => panoId != null && panoId!.isNotEmpty;

  /// true jika punya Foto 360° UGC (Pannellum)
  bool get hasImage360 => image360.isValid;

  /// true jika ada SALAH SATU mode Foto 360° tambahan (selain Street View)
  bool get hasAnyPhotoMode => hasPhotoSphere || hasImage360;

  /// Harga menu termurah (mengabaikan menu yang harganya belum diinput/null)
  int? get lowestMenuPrice {
    final valid = menus.map((m) => m.price).whereType<int>().toList();
    if (valid.isEmpty) return null;
    return valid.reduce((a, b) => a < b ? a : b);
  }

  /// Harga menu termahal (mengabaikan menu yang harganya belum diinput/null)
  int? get highestMenuPrice {
    final valid = menus.map((m) => m.price).whereType<int>().toList();
    if (valid.isEmpty) return null;
    return valid.reduce((a, b) => a > b ? a : b);
  }

  /// Format harga untuk card Explore: range termurah–termahal.
  /// - Kuliner     -> range dari harga semua menu
  /// - Non-kuliner -> range dari harga dewasa & anak
  /// Lihat `_formatRupiahRange` untuk detail aturan (null diabaikan, single
  /// value tidak jadi range, dst).
  String get priceRangeFormatted {
    if (isKuliner) {
      if (!hasMenus) return 'Lihat menu';
      return _formatRupiahRange(menus.map((m) => m.price).toList());
    }
    return _formatRupiahRange([priceAdult, priceChild]);
  }

  /// Format harga dewasa untuk halaman Detail (selalu individual, bukan range).
  /// null -> "-", 0 -> "Gratis", >0 -> "Rp 15.000"
  String get formattedPriceAdult => _formatRupiah(priceAdult);

  /// Format harga anak untuk halaman Detail (selalu individual, bukan range).
  /// null -> "-", 0 -> "Gratis", >0 -> "Rp 15.000"
  String get formattedPriceChild => _formatRupiah(priceChild);

  // ── FACTORY ───────────────────────────────────────────────────────────────

  factory DestinationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final hasVirtualTour = data['hasVirtualTour'] ?? false;
    final categoryId = data['categoryId'] ?? '';

    List<MenuItemModel> parseMenus() {
      if (categoryId != kCategoryKuliner) return [];
      final raw = data['menus'];
      if (raw == null || raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(MenuItemModel.fromMap)
          .toList();
    }

    // ── Parsing streetView config ───────────────────────────────────────────
    // Prioritas: Map `streetView` baru.
    // Fallback : field datar lama (initialHeading/initialPitch) agar dokumen
    //            yang belum dimigrasi tetap berfungsi.
    StreetViewConfig parseStreetView() {
      final raw = data['streetView'];
      if (raw is Map<String, dynamic>) {
        return StreetViewConfig.fromMap(raw);
      }
      // Backward-compat: field datar lama
      return StreetViewConfig(
        heading: _toNullableDouble(data['initialHeading']) ?? 0.0,
        pitch: _toNullableDouble(data['initialPitch']) ?? 0.0,
      );
    }

    // ── Parsing image360 config ──────────────────────────────────────────────
    // Prioritas: Map `image360` baru.
    // Fallback : field datar lama `image360Url` (heading/pitch = 0).
    Image360Config parseImage360() {
      final raw = data['image360'];
      if (raw is Map<String, dynamic>) {
        return Image360Config.fromMap(raw);
      }
      // Backward-compat: field datar lama
      final oldUrl = data['image360Url'];
      if (oldUrl is String && oldUrl.isNotEmpty) {
        return Image360Config(url: oldUrl);
      }
      return const Image360Config();
    }

    return DestinationModel(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      categoryId: categoryId,
      rating: _toDouble(data['rating']),
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      latitude: _toDouble(data['latitude']),
      longitude: _toDouble(data['longitude']),
      mapsUrl: data['mapsUrl'] ?? '',
      hasVirtualTour: hasVirtualTour,
      panoId: data['panoId'] as String?,
      streetView: parseStreetView(),
      image360: parseImage360(),
      // null = field belum ada/belum diisi di Firestore -> tampil "-" di UI
      priceAdult:
          categoryId == kCategoryKuliner
              ? null
              : _toNullableInt(data['priceAdult']),
      priceChild:
          categoryId == kCategoryKuliner
              ? null
              : _toNullableInt(data['priceChild']),
      menus: parseMenus(),
      isRecommended: data['isRecommended'] ?? false,
      createdAt: data['createdAt'],
    );
  }

  // ── SERIALIZATION ─────────────────────────────────────────────────────────

  Map<String, dynamic> toCreateMap() => {
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
    if (panoId != null) 'panoId': panoId,
    'streetView': streetView.toMap(),
    if (image360.isValid) 'image360': image360.toMap(),
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

  Map<String, dynamic> toUpdateMap() => {
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
    if (panoId != null) 'panoId': panoId else 'panoId': FieldValue.delete(),
    'streetView': streetView.toMap(),
    if (image360.isValid)
      'image360': image360.toMap()
    else
      'image360': FieldValue.delete(),
    // Bersihkan field datar lama jika ada (migrasi otomatis saat update)
    'initialHeading': FieldValue.delete(),
    'initialPitch': FieldValue.delete(),
    'image360Url': FieldValue.delete(),
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
    String? panoId,
    StreetViewConfig? streetView,
    Image360Config? image360,
    int? priceAdult,
    int? priceChild,
    List<MenuItemModel>? menus,
    bool? isRecommended,
    Timestamp? createdAt,
  }) => DestinationModel(
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
    panoId: panoId ?? this.panoId,
    streetView: streetView ?? this.streetView,
    image360: image360 ?? this.image360,
    priceAdult: priceAdult ?? this.priceAdult,
    priceChild: priceChild ?? this.priceChild,
    menus: menus ?? this.menus,
    isRecommended: isRecommended ?? this.isRecommended,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DestinationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DestinationModel{id: $id, name: $name, '
      'streetView: ${streetView.heading}/${streetView.pitch}, '
      'hasImage360: $hasImage360}';
}
