// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Palet warna terpusat — terinspirasi alam Trenggalek:
/// pantai selatan, hutan tropis, dan tebing kapur.
abstract final class AppColors {
  // ── Primary — Deep Teal (laut selatan Trenggalek)
  static const Color primary = Color(0xFF0A6E6E);
  static const Color primaryLight = Color(0xFF0D8F8F);
  static const Color primaryDark = Color(0xFF064E4E);
  static const Color primarySurface = Color(0xFFE6F4F4);

  // ── Accent — Warm Sand (pantai Prigi & Pelang)
  static const Color accent = Color(0xFFC8965A);
  static const Color accentLight = Color(0xFFE8B97A);
  static const Color accentSurface = Color(0xFFFDF3E7);

  // ── Earth — Auth tone (krem & tanah hangat, pelengkap teal)
  static const Color earth = Color(0xFFB8845A); // Clay warm
  static const Color earthLight = Color(0xFFDDB98A); // Sandy beige
  static const Color earthSurface = Color(0xFFFAF3EC); // Warm cream fill
  static const Color bark = Color(0xFF7A5438); // Dark bark brown
  static const Color textEarth = Color(0xFF6B4530); // Earthy brown text

  // ── Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F9F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8EEEE);

  // ── Text
  static const Color textPrimary = Color(0xFF0D2B2B);
  static const Color textSecondary = Color(0xFF4A6A6A);
  static const Color textHint = Color(0xFF8AABAB);
  static const Color textOnDark = Color(0xFFFFFFFF);

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
    colors: [Colors.transparent, Color(0x33064E4E), Color(0xBF0D2B2B)],
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
  static const Color success = Color(0xFF2E9E6B);
  static const Color error = Color(0xFFD94F4F);
  static const Color warning = Color(0xFFE8A020);
  static const Color starColor = Color(0xFFFFD166);

  // ── Shadow
  static const Color shadowPrimary = Color(0x280A6E6E);
  static const Color shadowNeutral = Color(0x140D2B2B);
  static const Color shadowDeep = Color(0x26064E4E);

  // ── Virtual Tour — Glass & Overlay (floating buttons tetap hitam — max contrast di panorama)
  static const Color vtBackground = Color(0xFF000000); // Scaffold VT
  static const Color vtGlassFill = Color(
    0x8C000000,
  ); // 55% black — floating button bg
  static const Color vtScrimDark = Color(0xDE000000); // 87% black — SnackBar bg
  static const Color vtTextSubtle = Color(
    0x99FFFFFF,
  ); // 60% white — subtle icon/hint
  static const Color vtTextMuted = Color(
    0x80FFFFFF,
  ); // 50% white — muted body text
  static const Color vtTextDim = Color(
    0x59FFFFFF,
  ); // 35% white — dim/disabled UI

  // ── Virtual Tour — Glass Surface (teal-tinted — identitas laut Trenggalek)
  static const Color vtSheetBg = Color(
    0xF2052020,
  ); // deep teal-black — sheet bg
  static const Color vtGlassSurface = Color(
    0x180A6E6E,
  ); // 9%  primary teal — card fill
  static const Color vtGlassBorder = Color(
    0x330D8F8F,
  ); // 20% primaryLight — card stroke
  static const Color vtGlassIconBg = Color(
    0x280A6E6E,
  ); // 16% primary teal — icon circle
  static const Color vtGlassIconBorder = Color(
    0x660D8F8F,
  ); // 40% primaryLight — icon rim
  static const Color vtHandleColor = Color(0x800D8F8F);
  static const Color vtTextStrong = Color(
    0xCCFFFFFF,
  ); // 50% primaryLight — drag handle

  // ── Virtual Tour — Glass Dialog (white-based, untuk floating dialog)
  static const Color vtDialogSurface = Color(0x1AFFFFFF); // 10% white — card bg
  static const Color vtDialogBorder = Color(
    0x33FFFFFF,
  ); // 20% white — card & btn border
  static const Color vtDialogIconBg = Color(
    0x1FFFFFFF,
  ); // 12% white — icon circle
  static const Color vtDialogRim = Color(
    0x40FFFFFF,
  ); // 25% white — icon rim & action border
  static const Color vtDialogAction = Color(
    0x26FFFFFF,
  ); // 15% white — confirm button bg

  // ── Virtual Tour — Hero "360° Tour" Badge (glass dipertajam + blur)
  // Token terpisah dari vtDialogAction/vtDialogRim supaya badge rating di
  // DetailHeroInfoOverlay tidak ikut berubah. Dipakai bersama BackdropFilter
  // blur di DetailGlassTourButton — opacity dinaikkan dari 15% putih agar
  // badge tidak terlalu "hilang" transparan di atas foto cerah, tapi tetap
  // translucent (efek glass tetap terasa lewat blur, bukan warna solid).
  static const Color vtTourBadgeFill = Color(
    0x66000000,
  ); // 40% black — fill glass badge 360° Tour, lebih tegas
  static const Color vtTourBadgeBorder = Color(
    0x4DFFFFFF,
  ); // 30% white — rim glass badge 360° Tour, lebih tegas

  // ── Virtual Tour — Mode Indicators
  static const Color vtStreetViewAccent = Color(0xFF4FC3F7);
  static const Color vtStreetViewBg = Color(0xFF0D2B3E);
  static const Color vtPhotoSphereAccent = Color(0xFF2E9E6B);
  static const Color vtPhotoSphereBg = Color(0xFFE0F3EC);
  static const Color vtImage360Accent = Color(0xFFFFB74D);
  static const Color vtImage360Bg = Color(0xFF2E1F00);

  // ── Virtual Tour — Mode Badge Light Surfaces (untuk sheet light theme)
  static const Color vtModeStreetBg = Color(
    0xFFCAEDFD,
  ); // light blue — Street View
  static const Color vtModeSphereBg = Color(
    0xFFC8E6DA,
  ); // light green — Photo Sphere
  static const Color vtModeImageBg = Color(0xFFFFE9CA);

  static const Color vtPanelGlass = Color(
    0xCCF7F9F9,
  ); // 80% AppColors.background — medium glass panel // light amber — Image 360
  // 35% white — dim/disabled UI
}
