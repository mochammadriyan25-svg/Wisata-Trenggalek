// lib/data/models/menu_item_model.dart

import 'package:intl/intl.dart';

class MenuItemModel {
  final String name;

  /// null = harga belum diinput/ditentukan
  /// 0    = memang gratis
  /// > 0  = harga normal
  final int? price;

  final String? description; // opsional, misal: "pedas, berkuah"

  const MenuItemModel({required this.name, this.price, this.description});

  // ── GETTERS ───────────────────────────────────────────────────────────────

  /// true hanya jika harga eksplisit diisi 0 (gratis), bukan saat belum diinput
  bool get isFree => price == 0;

  /// true jika harga sudah diinput (baik gratis maupun berbayar)
  bool get isPriceSet => price != null;

  /// null -> "-", 0 -> "Gratis", >0 -> "Rp 15.000"
  String get formattedPrice {
    if (price == null) return '-';
    if (price == 0) return 'Gratis';
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(price)}';
  }

  // ── FACTORY ───────────────────────────────────────────────────────────────

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    int? toNullableInt(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString());
    }

    return MenuItemModel(
      name: map['name'] ?? '',
      price: toNullableInt(map['price']),
      description: map['description'] as String?,
    );
  }

  // ── SERIALIZATION ─────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      if (description != null) 'description': description,
    };
  }

  // ── UTILITY ───────────────────────────────────────────────────────────────

  MenuItemModel copyWith({String? name, int? price, String? description}) {
    return MenuItemModel(
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItemModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          price == other.price;

  @override
  int get hashCode => name.hashCode ^ price.hashCode;

  @override
  String toString() => 'MenuItemModel{name: $name, price: $price}';
}
