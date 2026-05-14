// lib/data/models/menu_item_model.dart

import 'package:intl/intl.dart';

class MenuItemModel {
  final String name;
  final int price;
  final String? description; // opsional, misal: "pedas, berkuah"

  const MenuItemModel({
    required this.name,
    required this.price,
    this.description,
  });

  // ── GETTERS ───────────────────────────────────────────────────────────────

  bool get isFree => price == 0;

  String get formattedPrice {
    if (isFree) return 'Gratis';
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'IDR ${formatter.format(price)}';
  }

  // ── FACTORY ───────────────────────────────────────────────────────────────

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return MenuItemModel(
      name: map['name'] ?? '',
      price: toInt(map['price']),
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

  MenuItemModel copyWith({
    String? name,
    int? price,
    String? description,
  }) {
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