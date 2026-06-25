// lib/core/utils/icon_mapper.dart
import 'package:flutter/material.dart';

const List<String> kValidCategoryIconKeys = [
  'park',
  'beach_access',
  'water',
  'mountain',
  'waterfall',
  'temple_hindu',
  'temple_buddhist',
  'mosque',
  'museum',
  'restaurant',
  'food',
  'cafe',
  'hotel',
  'villa',
  'camping',
  'card_travel',
  'tour',
  'map',
];

IconData getCategoryIcon(String iconName) {
  switch (iconName.toLowerCase()) {
    // ── Alam & Wisata
    case 'park':
      return Icons.forest_rounded;
    case 'beach_access':
      return Icons.beach_access_rounded;
    case 'water':
      return Icons.water_rounded;
    case 'mountain':
      return Icons.landscape_rounded;
    case 'waterfall':
      return Icons.tsunami_rounded;

    // ── Budaya & Religi
    case 'temple_hindu':
      return Icons.temple_hindu_rounded;
    case 'temple_buddhist':
      return Icons.temple_buddhist_rounded;
    case 'mosque':
      return Icons.mosque_rounded;
    case 'museum':
      return Icons.museum_rounded;

    // ── Kuliner
    case 'restaurant':
      return Icons.restaurant_rounded;
    case 'food':
      return Icons.lunch_dining_rounded;
    case 'cafe':
      return Icons.local_cafe_rounded;

    // ── Akomodasi
    case 'hotel':
      return Icons.hotel_rounded;
    case 'villa':
      return Icons.cottage_rounded;
    case 'camping':
      return Icons.cabin_rounded;

    // ── Paket Wisata
    case 'card_travel':
      return Icons.travel_explore_rounded;
    case 'tour':
      return Icons.tour_rounded;
    case 'map':
      return Icons.map_rounded;

    // ── Default
    default:
      return Icons.explore_rounded;
  }
}
