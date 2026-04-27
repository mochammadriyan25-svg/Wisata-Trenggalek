// lib/core/theme/app_spacing.dart
abstract final class AppSpacing {
  // ── Base unit: 4px
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 16.0;
  static const double lg   = 24.0;
  static const double xl   = 32.0;
  static const double xxl  = 48.0;
  static const double xxxl = 64.0;

  // ── Border Radius (existing)
  static const double radiusSm   = 8.0;
  static const double radiusMd   = 16.0;
  static const double radiusLg   = 24.0;
  static const double radiusXl   = 36.0;
  static const double radiusFull = 999.0;

  // ── Border Radius tambahan untuk auth widgets
  static const double radiusXs   = 4.0;  // Checkbox corner

  // ── Icon & Logo sizing (existing)
  static const double iconSm     = 20.0;
  static const double iconMd     = 24.0;
  static const double iconLg     = 32.0;
  static const double iconXl     = 48.0;
  static const double logoSize   = 130.0;
  static const double logoIcon   = 64.0;
}