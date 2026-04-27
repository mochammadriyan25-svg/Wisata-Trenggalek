// lib/widgets/destinations/destination_card.dart
//
// Dua varian card:
//   • FeaturedDestinationCard  — hero full-width, glassmorphism overlay
//   • HorizontalDestinationCard — list item kompak, gambar kiri

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/destination_model.dart';
import 'destination_tag.dart';

// ══════════════════════════════════════════════════════════════════════════════
// FEATURED CARD — hero full-width, efek "Wow"
// ══════════════════════════════════════════════════════════════════════════════

class FeaturedDestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onTap;

  const FeaturedDestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.lg,
          top: AppSpacing.xs,
        ),
        height: 340,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl - 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDeep,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.shadowPrimary.withOpacity(0.12),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl - 4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _FeaturedImage(imageUrl: destination.imageUrl),
              const _FeaturedGradientOverlay(),
              const Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: _FeaturedBadge(),
              ),
              const Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: _GlassFavoriteButton(),
              ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: _FeaturedInfoGlass(destination: destination),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedImage extends StatelessWidget {
  final String imageUrl;
  const _FeaturedImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.primarySurface,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.primarySurface,
        child: const Center(
          child: Icon(Icons.image_not_supported_rounded, color: AppColors.textHint, size: 40),
        ),
      ),
    );
  }
}

class _FeaturedGradientOverlay extends StatelessWidget {
  const _FeaturedGradientOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.42, 1.0],
          colors: [
            Colors.transparent,
            Colors.transparent,
            AppColors.textPrimary.withOpacity(0.72),
          ],
        ),
      ),
    );
  }
}

class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 4,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.75),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(color: AppColors.primaryLight.withOpacity(0.4), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 11, color: AppColors.textOnDark),
              const SizedBox(width: 4),
              Text(
                'PILIHAN UTAMA',
                style: AppTextStyles.labelSpacedOnDark.copyWith(fontSize: 9, letterSpacing: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassFavoriteButton extends StatelessWidget {
  const _GlassFavoriteButton();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
          ),
          child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _FeaturedInfoGlass extends StatelessWidget {
  final DestinationModel destination;
  const _FeaturedInfoGlass({required this.destination});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd + 4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd + 4),
            border: Border.all(color: Colors.white.withOpacity(0.28), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                destination.name,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 13, color: AppColors.accentLight),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      destination.location,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.88),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _GlassRatingPill(rating: destination.rating),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              DestinationTag.category(label: destination.categoryId),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassRatingPill extends StatelessWidget {
  final num rating;
  const _GlassRatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 12, color: AppColors.warning),
              const SizedBox(width: 3),
              Text(
                rating.toStringAsFixed(1),
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HORIZONTAL CARD — list item kompak
// ══════════════════════════════════════════════════════════════════════════════

class HorizontalDestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onTap;

  const HorizontalDestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowNeutral,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _HorizontalThumbnail(imageUrl: destination.imageUrl),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 4,
                  vertical: AppSpacing.sm + 4,
                ),
                child: _HorizontalInfo(destination: destination),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm + 4),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalThumbnail extends StatelessWidget {
  final String imageUrl;
  const _HorizontalThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(
        left: Radius.circular(AppSpacing.radiusMd),
      ),
      child: Image.network(
        imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 100,
            height: 100,
            color: AppColors.primarySurface,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          width: 100,
          height: 100,
          color: AppColors.primarySurface,
          child: const Icon(Icons.image_not_supported_rounded, color: AppColors.textHint),
        ),
      ),
    );
  }
}

class _HorizontalInfo extends StatelessWidget {
  final DestinationModel destination;
  const _HorizontalInfo({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          destination.name,
          style: AppTextStyles.headlineMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(Icons.location_on_rounded, size: 12, color: AppColors.accent),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                destination.location,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 13, color: AppColors.warning),
            const SizedBox(width: 3),
            Text(
              destination.rating.toStringAsFixed(1),
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(child: DestinationTag.category(label: destination. categoryId)),
          ],
        ),
      ],
    );
  }
}