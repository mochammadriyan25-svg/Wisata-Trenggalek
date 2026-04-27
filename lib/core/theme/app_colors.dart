// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Palet warna terpusat — terinspirasi alam Trenggalek:
/// pantai selatan, hutan tropis, dan tebing kapur.
abstract final class AppColors {
  // ── Primary — Deep Teal (laut selatan Trenggalek)
  static const Color primary         = Color(0xFF0A6E6E);
  static const Color primaryLight    = Color(0xFF0D8F8F);
  static const Color primaryDark     = Color(0xFF064E4E);
  static const Color primarySurface  = Color(0xFFE6F4F4);

  // ── Accent — Warm Sand (pantai Prigi & Pelang)
  static const Color accent          = Color(0xFFC8965A);
  static const Color accentLight     = Color(0xFFE8B97A);
  static const Color accentSurface   = Color(0xFFFDF3E7);

  // ── Earth — Auth tone (krem & tanah hangat, pelengkap teal)
  static const Color earth           = Color(0xFFB8845A);  // Clay warm
  static const Color earthLight      = Color(0xFFDDB98A);  // Sandy beige
  static const Color earthSurface    = Color(0xFFFAF3EC);  // Warm cream fill
  static const Color bark            = Color(0xFF7A5438);  // Dark bark brown
  static const Color textEarth       = Color(0xFF6B4530);  // Earthy brown text

  // ── Neutral
  static const Color white           = Color(0xFFFFFFFF);
  static const Color background      = Color(0xFFF7F9F9);
  static const Color surface         = Color(0xFFFFFFFF);
  static const Color divider         = Color(0xFFE8EEEE);

  // ── Text
  static const Color textPrimary     = Color(0xFF0D2B2B);
  static const Color textSecondary   = Color(0xFF4A6A6A);
  static const Color textHint        = Color(0xFF8AABAB);
  static const Color textOnDark      = Color(0xFFFFFFFF);

  // ── Gradient — splash & hero (existing, tidak diubah)
  static const List<Color> splashGradient = [
    Color(0xFF083D3D),
    Color(0xFF0A6E6E),
    Color(0xFF0D8F8F),
  ];

  static const List<Color> heroOverlay = [
    Colors.transparent,
    Color(0xCC0D2B2B),
  ];

  // ── Gradient — auth screens (baru, harmonis dengan teal)
  static const LinearGradient authHeroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
    colors: [
      Colors.transparent,
      Color(0x33064E4E),
      Color(0xBF0D2B2B),
    ],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D8F8F), Color(0xFF064E4E)],
  );

  static const LinearGradient footerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE6F4F4), Color(0xFFFDF3E7), Color(0xFFE6F4F4)],
  );

  // ── Semantic
  static const Color success         = Color(0xFF2E9E6B);
  static const Color error           = Color(0xFFD94F4F);
  static const Color warning         = Color(0xFFE8A020);

  // ── Shadow
  static const Color shadowPrimary   = Color(0x280A6E6E);
  static const Color shadowNeutral   = Color(0x140D2B2B);
  static const Color shadowDeep      = Color(0x26064E4E);
}