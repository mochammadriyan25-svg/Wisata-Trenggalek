// lib/widgets/detail/accommodation_recommendation_section.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/data/models/accommodation_model.dart';
import 'package:aplikasi_wisata/providers/accommodation_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/presentation/pages/accommodation_detail_page.dart';

class AccommodationRecommendationSection extends StatefulWidget {
  final double currentLatitude;
  final double currentLongitude;
  final String currentDestinationId;

  const AccommodationRecommendationSection({
    super.key,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.currentDestinationId,
  });

  @override
  State<AccommodationRecommendationSection> createState() =>
      _AccommodationRecommendationSectionState();
}

class _AccommodationRecommendationSectionState
    extends State<AccommodationRecommendationSection> {
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
  // Sort berdasarkan jarak terdekat dalam radius 5 km
  List<({AccommodationModel accommodation, double distance})>
  _buildRecommendations(List<AccommodationModel> allAccommodations) {
    final nearby =
        allAccommodations
            .map((a) {
              final dist = _haversineDistance(
                widget.currentLatitude,
                widget.currentLongitude,
                a.latitude,
                a.longitude,
              );
              return (accommodation: a, distance: dist);
            })
            .where((e) => e.distance <= 5)
            .toList()
          ..sort((a, b) => a.distance.compareTo(b.distance));

    return nearby;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccommodationProvider>();

    // Loading
    if (provider.isLoading) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.earth,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    final recommendations = _buildRecommendations(provider.allAccommodations);
    final total = recommendations.length;

    // Beri index global pada setiap item
    final indexed =
        recommendations
            .asMap()
            .entries
            .map(
              (e) => (
                accommodation: e.value.accommodation,
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
        Divider(color: AppColors.divider, thickness: 1),
        const SizedBox(height: AppSpacing.lg),

        // ── Header
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.earth, AppColors.bark],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Akomodasi Terdekat',
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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.earthLight.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.hotel_outlined, color: AppColors.earth, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Tidak ada akomodasi dalam radius 5 km.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        // ── List akomodasi
        else
          Column(
            children: [
              // 4 card pertama — selalu tampil
              ...initialItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                  child: _AccommodationCard(
                    item: item.accommodation,
                    distance: item.distance,
                    formatDistance: _formatDistance,
                    isClosest: item.index == 0,
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
                                      child: _AccommodationCard(
                                        item: item.accommodation,
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
                      color: AppColors.earthLight.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: AppColors.earth.withOpacity(0.3),
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
                          color: AppColors.earth,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _isExpanded
                              ? 'Sembunyikan'
                              : 'Lihat Semua ($total akomodasi)',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.earth,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

// ── ACCOMMODATION CARD — horizontal (gambar kiri, info kanan) ─────────────
class _AccommodationCard extends StatelessWidget {
  final AccommodationModel item;
  final double distance;
  final String Function(double) formatDistance;
  final bool isClosest; // badge "Terdekat" — hanya index 0

  const _AccommodationCard({
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
          MaterialPageRoute(
            builder: (_) => AccommodationDetailPage(accommodation: item),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.earthLight.withOpacity(0.6),
            width: 1,
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
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.earth, AppColors.bark],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.hotel_rounded,
                              color: AppColors.textOnDark,
                              size: 24,
                            ),
                          ),
                        ),
                  ),

                  // Badge "Terdekat" — hanya card index 0
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
                          color: AppColors.earth,
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

                    // Lokasi / Alamat
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
                              color: AppColors.earth,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              formatDistance(distance),
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.earth,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Harga per malam
                    Text(
                      item.formattedPricePerNight,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 12,
                        color: AppColors.earth,
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
