// lib/widgets/package/package_bottom_bar.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/package_model.dart';

/// Bottom bar sticky di bagian bawah PackageDetailPage.
/// Menampilkan info harga (dari tier aktif atau fallback) beserta tombol "Pilih".
/// Padding bawah otomatis menyesuaikan safe area (notch, gesture bar).
///
/// [tier]          : tier yang sedang dipilih; null jika paket tanpa tier
/// [fallbackPrice] : harga default dari PackageModel jika tier null
class PackageBottomBar extends StatelessWidget {
  final PackageTier? tier;
  final String fallbackPrice;

  const PackageBottomBar({
    super.key,
    required this.tier,
    required this.fallbackPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider.withOpacity(0.6), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNeutral.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Kolom harga
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Harga per orang',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
              Text(
                tier?.formattedPrice ?? fallbackPrice,
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              if (tier != null)
                Text(
                  'Paket ${tier!.name} · Maks. ${tier!.maxPerson} orang',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          // Tombol Pilih
          Expanded(
            child: GestureDetector(
              onTap: () {
                // TODO: navigasi ke halaman booking
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Memesan paket ${tier?.name ?? ''} — segera hadir!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textOnDark,
                      ),
                    ),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                );
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.textOnDark,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Pilih',
                        style: AppTextStyles.buttonLabel.copyWith(
                          fontSize: 15,
                          color: AppColors.textOnDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
