// lib/widgets/detail/accommodation_recommendation_section.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/data/models/accommodation_model.dart';
import 'package:aplikasi_wisata/providers/accommodation_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class AccommodationRecommendationSection extends StatelessWidget {
  final double currentLatitude;
  final double currentLongitude;
  final String currentDestinationId;

  const AccommodationRecommendationSection({
    super.key,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.currentDestinationId,
  });

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

  @override
  Widget build(BuildContext context) {
    final accommodationProvider = context.watch<AccommodationProvider>();
    final allAccommodations = accommodationProvider.allAccommodations;

    // Loading state
    if (accommodationProvider.isLoading) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // ── Filter & hitung jarak dari koordinat destinasi saat ini
    final nearby =
        allAccommodations
            .map((a) {
              final distance = _haversineDistance(
                currentLatitude,
                currentLongitude,
                a.latitude,
                a.longitude,
              );
              return (accommodation: a, distance: distance);
            })
            .where((e) => e.distance <= 5) // radius 5 km
            .toList()
          ..sort((a, b) => a.distance.compareTo(b.distance));

    final result = nearby.take(5).toList();

    // ── Tampilkan section (selalu tampil, termasuk empty state)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.divider, thickness: 1),
        const SizedBox(height: AppSpacing.lg),

        // Header
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

        // ── Konten: list atau empty state
        result.isEmpty
            ? _EmptyAccommodationState()
            : SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: result.length,
                itemBuilder: (context, index) {
                  final item = result[index];
                  return _AccommodationCard(
                    item: item.accommodation,
                    distance: item.distance,
                    formatDistance: _formatDistance,
                  );
                },
              ),
            ),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

// ── EMPTY STATE ───────────────────────────────────────────────────────────
class _EmptyAccommodationState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg + 4,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.earthLight.withOpacity(0.5),
          width: 1.5,
          // Dashed border effect via custom painter tidak diperlukan,
          // solid border sudah cukup informatif
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ikon ilustrasi
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.earthLight.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hotel_outlined,
              size: 26,
              color: AppColors.earth.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),

          // Judul
          Text(
            'Tidak Ada Akomodasi Terdekat',
            style: AppTextStyles.headlineSmall.copyWith(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Deskripsi
          Text(
            'Belum ada akomodasi yang tersedia\ndalam radius 5 km dari lokasi ini.',
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── ACCOMMODATION CARD ────────────────────────────────────────────────────
class _AccommodationCard extends StatelessWidget {
  final AccommodationModel item;
  final double distance;
  final String Function(double) formatDistance;

  const _AccommodationCard({
    required this.item,
    required this.distance,
    required this.formatDistance,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: arahkan ke halaman detail accommodation
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (_) => AccommodationDetailPage(accommodation: item),
        // ));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: AppSpacing.sm + 4),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
              child: Stack(
                children: [
                  Image.network(
                    item.imageUrl,
                    height: 115,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          height: 115,
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
                              size: 28,
                            ),
                          ),
                        ),
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
                            AppColors.primaryDark.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Badge jarak
                  Positioned(
                    bottom: AppSpacing.xs,
                    left: AppSpacing.xs,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs + 2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.near_me_rounded,
                            size: 10,
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
                    ),
                  ),
                  // Badge Akomodasi
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.hotel_rounded,
                            size: 9,
                            color: AppColors.textOnDark,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Akomodasi',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textOnDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Text(
                        item.formattedPricePerNight,
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.earth,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
