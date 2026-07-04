// lib/widgets/package/package_tier_selector.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/package_model.dart';

/// Selector paket bergaya Traveloka: menampilkan semua tier dalam satu baris.
/// Tier yang dipilih ditandai dengan gradient primary + shadow.
/// Tier dengan [PackageTier.isPopular] = true menampilkan badge "⭐ Terlaris".
///
/// [tiers]         : daftar tier dari PackageModel
/// [selectedIndex] : index tier yang sedang aktif
/// [onSelect]      : callback saat user mengetuk tier lain
class PackageTierSelector extends StatelessWidget {
  final List<PackageTier> tiers;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const PackageTierSelector({
    super.key,
    required this.tiers,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tiers.length, (i) {
        final tier = tiers[i];
        final isSelected = i == selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < tiers.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm + 2,
                horizontal: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [],
              ),
              child: Column(
                children: [
                  if (tier.isPopular)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.surface.withValues(alpha: 0.25)
                                : AppColors.accentSurface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
                      ),
                      child: Text(
                        '⭐ Terlaris',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color:
                              isSelected
                                  ? AppColors.textOnDark
                                  : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  Text(
                    tier.name,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontSize: 13,
                      color:
                          isSelected
                              ? AppColors.textOnDark
                              : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tier.formattedPrice,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color:
                          isSelected
                              ? AppColors.textOnDark.withValues(alpha: 0.85)
                              : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Min. ${tier.minPerson} orang',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 9,
                      color:
                          isSelected
                              ? AppColors.textOnDark.withValues(alpha: 0.7)
                              : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
