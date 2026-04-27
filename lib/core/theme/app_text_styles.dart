// lib/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Hierarki tipografi terpusat.
/// Font: menggunakan system font (dapat diganti ke Google Fonts).
abstract final class AppTextStyles {
  // ── Display — untuk nama kota/judul besar (existing)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.5,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    color: AppColors.textPrimary,
    height: 1.15,
  );

  // ── Headline (existing)
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  // ── Title — italic, expressive (untuk branding splash) (existing)
  static const TextStyle titleExpressive = TextStyle(
    fontSize: 36,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textOnDark,
    height: 1.1,
  );

  // ── Label / Caption (spaced, uppercase) (existing)
  static const TextStyle labelSpaced = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 3.5,
    color: AppColors.textHint,
    height: 1.4,
  );

  static const TextStyle labelSpacedOnDark = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 3.5,
    color: AppColors.textOnDark,
    height: 1.4,
  );

  static const TextStyle labelSpacedSubtle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.0,
    color: AppColors.textHint,
  );

  static const TextStyle subtitleMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 4.0,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ── Body (existing)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ── Auth-specific additions ──────────────────────────────────────

  // Headline kecil untuk brand name di header auth
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Overline — pill label & tagline di atas hero image (tren 2026)
  static const TextStyle overline = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: AppColors.primaryLight,
    height: 1.4,
  );

  // Caption — teks kecil di dalam badge/pill
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // Button label
  static const TextStyle buttonLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.textOnDark,
  );
}