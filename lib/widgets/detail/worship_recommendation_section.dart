// lib/widgets/detail/worship_recommendation_section.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/place_model.dart';
import 'package:aplikasi_wisata/providers/place_provider.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';

class WorshipRecommendationSection extends StatefulWidget {
  final double currentLatitude;
  final double currentLongitude;
  final String? excludePlaceId;
  final void Function(PlaceModel place)? onPlaceTap;

  const WorshipRecommendationSection({
    super.key,
    required this.currentLatitude,
    required this.currentLongitude,
    this.excludePlaceId,
    this.onPlaceTap,
  });

  @override
  State<WorshipRecommendationSection> createState() =>
      _WorshipRecommendationSectionState();
}

class _WorshipRecommendationSectionState
    extends State<WorshipRecommendationSection> {
  bool _isExpanded = false;
  static const int _initialCount = 4;
  static const Color _accent = Color(0xFF8B5CF6);

  bool get _hasValidCoords {
    final lat = widget.currentLatitude;
    final lng = widget.currentLongitude;
    return lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180 &&
        !(lat == 0.0 && lng == 0.0);
  }

  double _dist(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  String _fmt(double km) =>
      km < 1
          ? '${(km * 1000).toStringAsFixed(0)} m'
          : '${km.toStringAsFixed(1)} km';

  List<({PlaceModel place, double distance})> _sorted(
    List<PlaceModel> worship,
  ) {
    if (!_hasValidCoords) return [];
    return worship
        .where((p) => p.id != widget.excludePlaceId)
        .map(
          (p) => (
            place: p,
            distance: _dist(
              widget.currentLatitude,
              widget.currentLongitude,
              p.latitude,
              p.longitude,
            ),
          ),
        )
        .toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
  }

  // ✅ NEW: Helper resolve nama kategori
  String _resolveCategoryName(PlaceModel place) {
    if (place.categoryId == null) return place.placeTypeLabel;
    final cat =
        context
            .read<CategoryProvider>()
            .categories
            .where((c) => c.id == place.categoryId)
            .firstOrNull;
    return cat?.name ?? place.placeTypeLabel;
  }

  @override
  Widget build(BuildContext context) {
    final items = _sorted(context.watch<PlaceProvider>().worshipPlaces);
    final initial = items.take(_initialCount).toList();
    final extra = items.skip(_initialCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(title: 'Tempat Ibadah Terdekat', color: _accent),
        const SizedBox(height: AppSpacing.md),
        if (!_hasValidCoords || items.isEmpty)
          _Empty(
            icon: Icons.place_outlined,
            color: _accent,
            message:
                !_hasValidCoords
                    ? 'Lokasi tidak tersedia.'
                    : 'Belum ada data tempat ibadah.',
          )
        else
          Column(
            children: [
              ...initial.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                  child: _PlaceCard(
                    item: e.value.place,
                    distance: e.value.distance,
                    fmt: _fmt,
                    isClosest: e.key == 0,
                    accent: _accent,
                    categoryName: _resolveCategoryName(e.value.place), // ✅ NEW
                    onTap: widget.onPlaceTap,
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
                              extra
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.sm + 2,
                                      ),
                                      child: _PlaceCard(
                                        item: e.place,
                                        distance: e.distance,
                                        fmt: _fmt,
                                        isClosest: false,
                                        accent: _accent,
                                        categoryName: _resolveCategoryName(
                                          e.place,
                                        ), // ✅ NEW
                                        onTap: widget.onPlaceTap,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        )
                        : const SizedBox.shrink(),
              ),
              if (extra.isNotEmpty)
                _ExpandButton(
                  expanded: _isExpanded,
                  totalLabel: '${items.length} tempat',
                  color: _accent,
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                ),
            ],
          ),
      ],
    );
  }
}

// ── HealthRecommendationSection ──
class HealthRecommendationSection extends StatefulWidget {
  final double currentLatitude;
  final double currentLongitude;
  final String? excludePlaceId;
  final void Function(PlaceModel place)? onPlaceTap;

  const HealthRecommendationSection({
    super.key,
    required this.currentLatitude,
    required this.currentLongitude,
    this.excludePlaceId,
    this.onPlaceTap,
  });

  @override
  State<HealthRecommendationSection> createState() =>
      _HealthRecommendationSectionState();
}

class _HealthRecommendationSectionState
    extends State<HealthRecommendationSection> {
  bool _isExpanded = false;
  static const int _initialCount = 4;
  static const Color _accent = Color(0xFF10B981);

  bool get _hasValidCoords {
    final lat = widget.currentLatitude;
    final lng = widget.currentLongitude;
    return lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180 &&
        !(lat == 0.0 && lng == 0.0);
  }

  double _dist(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  String _fmt(double km) =>
      km < 1
          ? '${(km * 1000).toStringAsFixed(0)} m'
          : '${km.toStringAsFixed(1)} km';

  List<({PlaceModel place, double distance})> _sorted(List<PlaceModel> health) {
    if (!_hasValidCoords) return [];
    return health
        .where((p) => p.id != widget.excludePlaceId)
        .map(
          (p) => (
            place: p,
            distance: _dist(
              widget.currentLatitude,
              widget.currentLongitude,
              p.latitude,
              p.longitude,
            ),
          ),
        )
        .toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
  }

  // ✅ NEW: Helper resolve nama kategori
  String _resolveCategoryName(PlaceModel place) {
    if (place.categoryId == null) return place.placeTypeLabel;
    final cat =
        context
            .read<CategoryProvider>()
            .categories
            .where((c) => c.id == place.categoryId)
            .firstOrNull;
    return cat?.name ?? place.placeTypeLabel;
  }

  @override
  Widget build(BuildContext context) {
    final items = _sorted(context.watch<PlaceProvider>().healthPlaces);
    final initial = items.take(_initialCount).toList();
    final extra = items.skip(_initialCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(title: 'Fasilitas Kesehatan Terdekat', color: _accent),
        const SizedBox(height: AppSpacing.md),
        if (!_hasValidCoords || items.isEmpty)
          _Empty(
            icon: Icons.local_hospital_outlined,
            color: _accent,
            message:
                !_hasValidCoords
                    ? 'Lokasi tidak tersedia.'
                    : 'Belum ada data fasilitas kesehatan.',
          )
        else
          Column(
            children: [
              ...initial.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                  child: _PlaceCard(
                    item: e.value.place,
                    distance: e.value.distance,
                    fmt: _fmt,
                    isClosest: e.key == 0,
                    accent: _accent,
                    categoryName: _resolveCategoryName(e.value.place), // ✅ NEW
                    onTap: widget.onPlaceTap,
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
                              extra
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.sm + 2,
                                      ),
                                      child: _PlaceCard(
                                        item: e.place,
                                        distance: e.distance,
                                        fmt: _fmt,
                                        isClosest: false,
                                        accent: _accent,
                                        categoryName: _resolveCategoryName(
                                          e.place,
                                        ), // ✅ NEW
                                        onTap: widget.onPlaceTap,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        )
                        : const SizedBox.shrink(),
              ),
              if (extra.isNotEmpty)
                _ExpandButton(
                  expanded: _isExpanded,
                  totalLabel: '${items.length} fasilitas',
                  color: _accent,
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                ),
            ],
          ),
      ],
    );
  }
}

// ── Shared sub-widgets ──
class _Header extends StatelessWidget {
  final String title;
  final Color color;
  const _Header({required this.title, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 3,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Text(
        title,
        style: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  const _Empty({
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      vertical: AppSpacing.lg,
      horizontal: AppSpacing.md,
    ),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ExpandButton extends StatelessWidget {
  final bool expanded;
  final String totalLabel;
  final Color color;
  final VoidCallback onTap;
  const _ExpandButton({
    required this.expanded,
    required this.totalLabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            expanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            expanded ? 'Sembunyikan' : 'Lihat Semua ($totalLabel)',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PlaceCard extends StatelessWidget {
  final PlaceModel item;
  final double distance;
  final String Function(double) fmt;
  final bool isClosest;
  final Color accent;
  final String categoryName; // ✅ NEW
  final void Function(PlaceModel)? onTap;

  const _PlaceCard({
    required this.item,
    required this.distance,
    required this.fmt,
    required this.isClosest,
    required this.accent,
    required this.categoryName, // ✅ NEW
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(item),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          color: AppColors.surface,
          border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
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
                  item.imageUrl.isNotEmpty
                      ? Image.network(
                        item.imageUrl,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                      )
                      : _fallback(),
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
                          color: accent,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      // ✅ FIX: Gunakan categoryName alih-alih item.subType
                      child: Text(
                        categoryName,
                        style: AppTextStyles.caption.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
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
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(Icons.near_me_rounded, size: 11, color: accent),
                        const SizedBox(width: 2),
                        Text(
                          fmt(distance),
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ],
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

  Widget _fallback() => Container(
    height: 100,
    width: 100,
    color: accent.withValues(alpha: 0.12),
    child: Icon(
      item.isWorship ? Icons.place_rounded : Icons.local_hospital_rounded,
      color: accent,
      size: 28,
    ),
  );
}
