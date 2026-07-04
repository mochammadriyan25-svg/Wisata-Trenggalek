// lib/widgets/package/package_back_button.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Tombol kembali yang tampil di atas hero image.
///
/// Konsisten dengan [_GlassBackButton] pada destination detail:
/// - [scrollOffset] = 0   → glassmorphism (transparan + border putih tipis)
/// - [scrollOffset] ≥ 80  → solid (surface + shadow)
/// - Transisi smooth di antara keduanya
class PackageBackButton extends StatelessWidget {
  final double scrollOffset;
  const PackageBackButton({super.key, this.scrollOffset = 0});

  @override
  Widget build(BuildContext context) {
    // Progress transisi: 0.0 (glass) → 1.0 (solid), mulai di scroll 20px
    final double t = ((scrollOffset - 20) / 60).clamp(0.0, 1.0);

    final Color bgColor =
        Color.lerp(Colors.white.withValues(alpha: 0.18), AppColors.surface, t)!;

    final Color borderColor =
        Color.lerp(
          Colors.white.withValues(alpha: 0.35),
          Colors.transparent,
          t,
        )!;

    final Color iconColor = Color.lerp(Colors.white, AppColors.textPrimary, t)!;

    final double shadowOpacity = t * 0.15;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDeep.withValues(alpha: shadowOpacity),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 15,
          color: iconColor,
        ),
      ),
    );
  }
}
