// lib/widgets/explore/explore_widget.dart
// Widget-widget internal untuk ExplorePage.
// Dipisah agar explore_page.dart tidak "fat".

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/destination_model.dart';
import '../../data/models/accommodation_model.dart';
// tambah import di bagian atas
import '../../data/models/package_model.dart';
// ── CATEGORY CHIP ─────────────────────────────────────────────────────────────

class ExploreCategoryChip extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const ExploreCategoryChip({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1.2,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.shadowPrimary,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          name,
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textOnDark : AppColors.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESTINATION CARD — layout horizontal
// ═══════════════════════════════════════════════════════════════════════════════

class ExploreDestinationCard extends StatelessWidget {
  final DestinationModel item;
  final VoidCallback onTap;

  const ExploreDestinationCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowNeutral.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Image.network(
                    item.imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 90,
                        height: 90,
                        color: AppColors.primarySurface,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder:
                        (_, __, ___) => Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Icon(
                            Icons.landscape_rounded,
                            color: AppColors.textOnDark,
                            size: 28,
                          ),
                        ),
                  ),
                ),
                if (item.isRecommended)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: const Text(
                        "⭐ Top",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: AppSpacing.sm + 4),

            // ── Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
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
                      const Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.confirmation_number_outlined,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        item.formattedPriceAdult,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      ExploreRatingBadge(rating: item.rating),
                      const SizedBox(width: AppSpacing.sm),
                      if (item.hasVirtualTour) const ExploreVirtualTourBadge(),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACCOMMODATION CARD — layout horizontal (seragam dengan destination card)
// ═══════════════════════════════════════════════════════════════════════════════

class ExploreAccommodationCard extends StatelessWidget {
  final AccommodationModel item;
  final VoidCallback onTap;

  const ExploreAccommodationCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowNeutral.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Image.network(
                    item.imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 90,
                        height: 90,
                        color: AppColors.primarySurface,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder:
                        (_, __, ___) => Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Icon(
                            Icons.hotel_rounded,
                            color: AppColors.textOnDark,
                            size: 28,
                          ),
                        ),
                  ),
                ),
                if (item.isRecommended)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: const Text(
                        "⭐ Top",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: AppSpacing.sm + 4),

            // ── Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
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
                      const Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.king_bed_outlined,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        item.formattedPricePerNight,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      ExploreRatingBadge(rating: item.rating),
                      if (item.hasVirtualTour) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const ExploreVirtualTourBadge(),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PACKAGE CARD — layout horizontal (seragam dengan card lainnya)
// ═══════════════════════════════════════════════════════════════════════════════

class ExplorePackageCard extends StatelessWidget {
  final PackageModel item;
  final VoidCallback onTap;

  const ExplorePackageCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowNeutral.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Image.network(
                    item.imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 90,
                        height: 90,
                        color: AppColors.primarySurface,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder:
                        (_, __, ___) => Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Icon(
                            Icons.card_travel_rounded,
                            color: AppColors.textOnDark,
                            size: 28,
                          ),
                        ),
                  ),
                ),
                // Badge "Top" jika isActive
                if (item.isActive)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: const Text(
                        "✓ Aktif",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: AppSpacing.sm + 4),

            // ── Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
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
                      const Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.card_travel_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        item.formattedPrice,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      ExploreRatingBadge(rating: item.rating),
                      if (item.hasVirtualTour) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const ExploreVirtualTourBadge(),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

/// Row info generik (icon + teks)
class ExploreInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final FontWeight fontWeight;

  const ExploreInfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.color = AppColors.textSecondary,
    this.fontWeight = FontWeight.w400,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              color: color,
              fontWeight: fontWeight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Badge rating bintang
class ExploreRatingBadge extends StatelessWidget {
  final double rating;
  const ExploreRatingBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: AppColors.accentLight.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFE8A020)),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge virtual tour 360°
class ExploreVirtualTourBadge extends StatelessWidget {
  const ExploreVirtualTourBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.vrpano_rounded, size: 11, color: AppColors.primary),
          const SizedBox(width: 3),
          Text(
            "360°",
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LOADING STATE (Skeleton) — horizontal sesuai card layout
// ═══════════════════════════════════════════════════════════════════════════════

class ExploreLoadingState extends StatelessWidget {
  const ExploreLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowNeutral,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _bone(height: 90, width: 90, radius: AppSpacing.radiusMd),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bone(height: 14, width: double.infinity, radius: 6),
                  const SizedBox(height: AppSpacing.xs + 2),
                  _bone(height: 11, width: 120, radius: 6),
                  const SizedBox(height: AppSpacing.xs + 2),
                  _bone(height: 11, width: 100, radius: 6),
                  const SizedBox(height: AppSpacing.xs + 4),
                  Row(
                    children: [
                      _bone(height: 20, width: 52, radius: 20),
                      const SizedBox(width: AppSpacing.sm),
                      _bone(height: 20, width: 40, radius: 20),
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

  Widget _bone({
    required double height,
    required double width,
    required double radius,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════════════════════════

class ExploreEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onReset;

  const ExploreEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.travel_explore_rounded,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "Coba kata kunci yang berbeda",
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
            if (onReset != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(onPressed: onReset, child: const Text("Reset filter")),
            ],
          ],
        ),
      ),
    );
  }
}
