import 'package:flutter/material.dart';

IconData getCategoryIcon(String iconName) {
  switch (iconName.toLowerCase()) {
    case 'park':
      return Icons.park;
    case 'beach_access':
      return Icons.beach_access;
    case 'restaurant':
      return Icons.restaurant;
    case 'temple_hindu':
      return Icons.temple_hindu;
    case 'water':
      return Icons.water;
    case 'hotel':
      return Icons.hotel;
    case 'card_travel':
      return Icons.card_travel;
    default:
      return Icons.category;
  }
}