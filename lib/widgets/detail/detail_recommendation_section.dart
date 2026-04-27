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
  final String currentCategoryId;
  final double currentLatitude;
  final double currentLongitude;

  const RecommendationSection({
    super.key,
    required this.currentDestinationId,
    required this.currentCategoryId,
    required this.currentLatitude,
    required this.currentLongitude,
  });

  @override
  State<RecommendationSection> createState() => _RecommendationSectionState();
}

class _RecommendationSectionState extends State<RecommendationSection> {
  bool _isExpanded = false;
  static const int _initialCount = 4;

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

  // ── Bangun daftar rekomendasi ─────────────────────────────────────────────
  // Prioritas 1 : dalam radius 5 km, sort jarak terdekat
  // Prioritas 2 : jika < 4, isi dari kategori sama sort rating tertinggi
  List<({DestinationModel destination, double distance, bool isNearby})>
  _buildRecommendations(List<DestinationModel> allDestinations) {
    final others =
        allDestinations
            .where((d) => d.id != widget.currentDestinationId)
            .toList();

    // Grup 1 — nearby ≤ 5 km
    final nearbyList =
        others
            .map((d) {
              final dist = _haversineDistance(
                widget.currentLatitude,
                widget.currentLongitude,
                d.latitude,
                d.longitude,
              );
              return (destination: d, distance: dist, isNearby: true);
            })
            .where((e) => e.distance <= 5)
            .toList()
          ..sort((a, b) => a.distance.compareTo(b.distance));

    // Sudah cukup — tidak perlu filler
    if (nearbyList.length >= _initialCount) return nearbyList;

    // Grup 2 — filler: kategori sama, di luar radius, sort rating tertinggi
    final nearbyIds = nearbyList.map((e) => e.destination.id).toSet();
    final fillerList =
        others
            .where(
              (d) =>
                  d.categoryId == widget.currentCategoryId &&
                  !nearbyIds.contains(d.id),
            )
            .map((d) {
              final dist = _haversineDistance(
                widget.currentLatitude,
                widget.currentLongitude,
                d.latitude,
                d.longitude,
              );
              return (destination: d, distance: dist, isNearby: false);
            })
            .toList()
          ..sort(
            (a, b) => b.destination.rating.compareTo(a.destination.rating),
          );

    return [...nearbyList, ...fillerList];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DestinationProvider>();

    // Loading
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

    // Beri index global pada setiap item
    final indexed =
        recommendations
            .asMap()
            .entries
            .map(
              (e) => (
                destination: e.value.destination,
                distance: e.value.distance,
                isNearby: e.value.isNearby,
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
              'Wisata Terdekat',
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
              border: Border.all(color: AppColors.divider.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_off_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Tidak ada wisata lain dalam radius 5 km.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        // ── List destinasi
        else
          Column(
            children: [
              // 4 card pertama — selalu tampil
              ...initialItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                  child: _RecommendationCard(
                    item: item.destination,
                    distance: item.distance,
                    formatDistance: _formatDistance,
                    isClosest: item.index == 0 && item.isNearby,
                    isNearby: item.isNearby,
                  ),
                ),
              ),

              // ── Card tambahan dengan animasi expand/collapse
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
                                        isNearby: item.isNearby,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        )
                        : const SizedBox.shrink(),
              ),

              // ── Tombol expand / collapse
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
                        color: AppColors.primary.withOpacity(0.3),
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

// ── RECOMMENDATION CARD — horizontal (gambar kiri, info kanan) ────────────
class _RecommendationCard extends StatelessWidget {
  final DestinationModel item;
  final double distance;
  final String Function(double) formatDistance;
  final bool isClosest; // badge "Terdekat" — hanya index 0 dari nearby
  final bool isNearby; // border berbeda untuk filler kategori

  const _RecommendationCard({
    required this.item,
    required this.distance,
    required this.formatDistance,
    required this.isClosest,
    required this.isNearby,
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
            color:
                isNearby
                    ? AppColors.primary.withOpacity(0.35)
                    : AppColors.divider.withOpacity(0.7),
            width: isNearby ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowNeutral.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Gambar kiri
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

                  // Badge "Terdekat" — hanya card index 0 dari nearby
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

                  // Badge "Rekomendasi" — filler kategori sama
                  if (!isNearby)
                    Positioned(
                      top: AppSpacing.xs,
                      left: AppSpacing.xs,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs + 2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.earth.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Text(
                          'Rekomendasi',
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

            // ── Info kanan
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
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

                    // Lokasi
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

                    // Rating + Jarak
                    Row(
                      children: [
                        // Rating
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

                        // Jarak
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

                    // Harga
                    Text(
                      item.formattedPriceAdult,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Chevron
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
