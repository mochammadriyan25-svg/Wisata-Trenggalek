// lib/widgets/package/package_tier_detail.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/package_model.dart';

/// Card detail untuk tier yang sedang dipilih di [PackageTierSelector].
/// Menampilkan deskripsi tier beserta daftar item yang sudah termasuk (includes).
/// Menggunakan [AnimatedSwitcher] agar ada transisi halus saat tier berganti.
///
/// [tier] : tier yang sedang aktif/dipilih
class PackageTierDetail extends StatelessWidget {
  final PackageTier tier;
  const PackageTierDetail({super.key, required this.tier});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(tier.name),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tier.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(color: AppColors.primary.withOpacity(0.15), thickness: 1),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Yang Sudah Termasuk:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...tier.includes.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 10,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
