// lib/widgets/detail/detail_recommendation_section.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';
import 'package:aplikasi_wisata/presentation/pages/detail_page.dart';
import 'package:aplikasi_wisata/providers/destination_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class RecommendationSection extends StatefulWidget {
  final String currentDestinationId;
  final double currentLatitude;
  final double currentLongitude;

  const RecommendationSection({
    super.key,
    required this.currentDestinationId,
    required this.currentLatitude,
    required this.currentLongitude,
  });

  @override
  State<RecommendationSection> createState() => _RecommendationSectionState();
}

class _RecommendationSectionState extends State<RecommendationSection> {
  bool _isExpanded = false;
  static const int _initialCount = 4;

  // ── Validasi Koordinat ───────────────────────────────────────────────────
  bool get _hasValidCoordinates {
    final lat = widget.currentLatitude;
    final lon = widget.currentLongitude;

    final isLatValid = lat >= -90.0 && lat <= 90.0;
    final isLonValid = lon >= -180.0 && lon <= 180.0;
    final isNotNullIsland = !(lat == 0.0 && lon == 0.0);

    return isLatValid && isLonValid && isNotNullIsland;
  }

  // ── Haversine ─────────────────────────────────────────────────────────────
  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  String _formatDistance(double km) {
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)} m';
    return '${km.toStringAsFixed(1)} km';
  }

  // ── Build Rekomendasi: HANYA dalam 5 km, sort jarak ───────────────────────
  List<({DestinationModel destination, double distance})> _buildRecommendations(
    List<DestinationModel> allDestinations,
  ) {
    if (!_hasValidCoordinates) return [];

    final others =
        allDestinations
            .where((d) => d.id != widget.currentDestinationId)
            .toList();

    final nearbyList =
        others
            .map((d) {
              final dist = _haversineDistance(
                widget.currentLatitude,
                widget.currentLongitude,
                d.latitude,
                d.longitude,
              );
              return (destination: d, distance: dist);
            })
            .where((e) => e.distance <= 5.0)
            .toList()
          ..sort((a, b) => a.distance.compareTo(b.distance));

    return nearbyList;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DestinationProvider>();

    if (provider.isLoading) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    final recommendations = _buildRecommendations(provider.allDestinations);
    final total = recommendations.length;

    final indexed =
        recommendations
            .asMap()
            .entries
            .map(
              (e) => (
                destination: e.value.destination,
                distance: e.value.distance,
                index: e.key,
              ),
            )
            .toList();

    final initialItems = indexed.take(_initialCount).toList();
    final extraItems = indexed.skip(_initialCount).toList();
    final hasMore = extraItems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Rekomendasi Wisata Terdekat',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Empty state
        if (recommendations.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_off_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    !_hasValidCoordinates
                        ? 'Lokasi tidak tersedia untuk pencarian sekitar.'
                        : 'Tidak ada wisata lain dalam radius 5 km.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              ...initialItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                  child: _RecommendationCard(
                    item: item.destination,
                    distance: item.distance,
                    formatDistance: _formatDistance,
                    isClosest: item.index == 0,
                  ),
                ),
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child:
                    _isExpanded
                        ? Column(
                          children:
                              extraItems
                                  .map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.sm + 2,
                                      ),
                                      child: _RecommendationCard(
                                        item: item.destination,
                                        distance: item.distance,
                                        formatDistance: _formatDistance,
                                        isClosest: false,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        )
                        : const SizedBox.shrink(),
              ),

              if (hasMore)
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _isExpanded
                              ? 'Sembunyikan'
                              : 'Lihat Semua ($total destinasi)',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

// ── RECOMMENDATION CARD ───────────────────────────────────────────────────
class _RecommendationCard extends StatelessWidget {
  final DestinationModel item;
  final double distance;
  final String Function(double) formatDistance;
  final bool isClosest;

  const _RecommendationCard({
    required this.item,
    required this.distance,
    required this.formatDistance,
    required this.isClosest,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailPage(destination: item)),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowNeutral.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppSpacing.radiusLg),
              ),
              child: Stack(
                children: [
                  Image.network(
                    item.imageUrl,
                    height: 105,
                    width: 105,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          height: 105,
                          width: 105,
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              color: AppColors.textOnDark,
                              size: 24,
                            ),
                          ),
                        ),
                  ),

                  if (isClosest)
                    Positioned(
                      top: AppSpacing.xs,
                      left: AppSpacing.xs,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs + 2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Text(
                          'Terdekat',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textOnDark,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs + 2),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs + 2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentSurface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusFull,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 11,
                                color: Color(0xFFE8A020),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                item.rating.toStringAsFixed(1),
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs + 2),

                        Row(
                          children: [
                            Icon(
                              Icons.near_me_rounded,
                              size: 11,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              formatDistance(distance),
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      item.priceRangeFormatted,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
