// lib/widgets/home/home_recommendation_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/utils/auth_guard.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';
import 'package:aplikasi_wisata/presentation/pages/detail_page.dart';
import 'package:aplikasi_wisata/providers/destination_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class HomeRecommendationSection extends StatelessWidget {
  const HomeRecommendationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DestinationProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Recommended',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        if (provider.isLoading)
          const SizedBox(
            height: 260,
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
              child: Text(
                'Gagal memuat rekomendasi.',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          )
        else if (provider.recommendedDestinations.isEmpty)
          SizedBox(
            height: 80,
            child: Center(
              child: Text(
                'Belum ada destinasi yang direkomendasikan.',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          )
        else
          _RecommendationList(destinations: provider.recommendedDestinations),
      ],
    );
  }
}

class _RecommendationList extends StatelessWidget {
  const _RecommendationList({required this.destinations});
  final List<DestinationModel> destinations;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 268,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: destinations.length,
        itemBuilder:
            (context, index) =>
                _RecommendationCard(destination: destinations[index]),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.destination});
  final DestinationModel destination;

  void _navigateToDetail(BuildContext context) {
    // ── AUTH GUARD: Cek login sebelum navigasi ──
    AuthGuard.checkAndRun(
      context: context,
      action: () {
        // Hanya dijalankan jika user SUDAH login
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(destination: destination),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: AppSpacing.md),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardImage(imageUrl: destination.imageUrl),
            _CardInfo(destination: destination),
          ],
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
      child: Stack(
        children: [
          Image.network(
            imageUrl,
            height: 145,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  height: 145,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      color: AppColors.textOnDark,
                      size: 32,
                    ),
                  ),
                ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 145,
                color: AppColors.primarySurface,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                ),
              );
            },
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.6, 1.0],
                  colors: [
                    Colors.transparent,
                    AppColors.primaryDark.withOpacity(0.25),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  const _CardInfo({required this.destination});
  final DestinationModel destination;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            destination.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headlineSmall.copyWith(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 12,
                color: AppColors.primary,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  destination.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: AppColors.accentLight.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Color(0xFFE8A020),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      destination.rating.toStringAsFixed(1),
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                destination.formattedPriceAdult,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
