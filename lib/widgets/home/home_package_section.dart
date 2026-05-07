// lib/widgets/home/home_package_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/data/models/package_model.dart';
import 'package:aplikasi_wisata/providers/package_provider.dart';
import 'package:aplikasi_wisata/presentation/pages/package_detail_page.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class HomePackageSection extends StatelessWidget {
  const HomePackageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PackageProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.earth, AppColors.bark],
                      ),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Paket Wisata',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // TODO: navigasi ke halaman semua paket
                },
                child: Text(
                  'Lihat Semua',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── STATE HANDLING
        if (provider.isLoading)
          const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            ),
          )
        else if (provider.errorMessage != null)
          SizedBox(
            height: 80,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  'Gagal memuat paket wisata.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else if (provider.allPackages.isEmpty)
          SizedBox(
            height: 80,
            child: Center(
              child: Text(
                'Belum ada paket wisata tersedia.',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children:
                  provider.allPackages
                      .map((package) => _PackageCard(package: package))
                      .toList(),
            ),
          ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PackageModel package;
  const _PackageCard({required this.package});

  void _goToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PackageDetailPage(package: package)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _goToDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowNeutral.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── GAMBAR di kiri
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppSpacing.radiusLg),
              ),
              child: Image.network(
                package.imageUrl,
                height: 90,
                width: 90,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      height: 90,
                      width: 90,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.card_travel_rounded,
                          color: AppColors.textOnDark,
                          size: 28,
                        ),
                      ),
                    ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 90,
                    width: 90,
                    color: AppColors.primarySurface,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── INFO di tengah
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama paket
                    Text(
                      package.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // ── RATING BINTANG
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final filled = index < package.rating.floor();
                          final isHalf = !filled && index < package.rating;
                          return Icon(
                            isHalf
                                ? Icons.star_half_rounded
                                : filled
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 14,
                            color: AppColors.earth,
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          package.rating > 0
                              ? package.rating.toStringAsFixed(1)
                              : 'Belum ada ulasan',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs + 2),

                    // Harga
                    Text(
                      package.formattedPrice,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 13,
                        color:
                            package.price == 0
                                ? AppColors.success
                                : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── ARROW di kanan
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
