// lib/widgets/virtual_tour/vt_guide_narration.dart
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_tour_step.dart';

/// Kartu narasi guided tour yang tampil di bagian atas layar
/// saat mode Tur Otomatis aktif.
///
/// Berpindah antar [VtTourStep] dengan animasi fade menggunakan
/// [AnimatedSwitcher]. Indikator dot di atas menunjukkan posisi
/// langkah saat ini dari total langkah.
class VtGuideNarration extends StatelessWidget {
  final VtTourStep step;
  final int currentIndex;
  final int totalSteps;

  const VtGuideNarration({
    super.key,
    required this.step,
    required this.currentIndex,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder:
          (child, animation) =>
              FadeTransition(opacity: animation, child: child),
      child: Container(
        key: ValueKey(currentIndex),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color:
              AppColors
                  .primaryDark, // ← was Colors.black.withValues(alpha: 0.62)
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd), // ← was 16
          border: Border.all(
            color: AppColors.vtGlassBorder,
          ), // ← was Colors.white.withValues(alpha: 0.15)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Indikator langkah
            Row(
              children: [
                ...List.generate(
                  totalSteps,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(
                      right: AppSpacing.xs,
                    ), // ← was 4
                    width: i == currentIndex ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color:
                          i == currentIndex
                              ? AppColors
                                  .textOnDark // ← was Colors.white
                              : Colors.white.withValues(alpha: 0.30,
                              ), // dibiarkan inline — 6px dot
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${currentIndex + 1}/$totalSteps',
                  style: AppTextStyles.caption.copyWith(
                    color:
                        AppColors
                            .vtTextMuted, // ← was Colors.white.withValues(alpha: 0.55)
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Judul langkah
            Text(
              step.title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textOnDark, // ← was Colors.white
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),

            // ── Teks narasi
            Text(
              step.narration,
              style: AppTextStyles.caption.copyWith(
                color:
                    AppColors
                        .vtTextStrong, // ← was Colors.white.withValues(alpha: 0.82)
                fontSize: 12,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
