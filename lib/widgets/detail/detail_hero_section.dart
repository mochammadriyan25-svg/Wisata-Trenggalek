import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';
import 'package:aplikasi_wisata/data/services/firestore/destination_service.dart';

class DetailHeroSection extends StatelessWidget {
  final DestinationModel item;
  final Future<void> Function(String) onOpenUrl;
  final double scrollOffset;

  const DetailHeroSection({
    super.key,
    required this.item,
    required this.onOpenUrl,
    this.scrollOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    const double heroHeight = 420;
    final double parallaxShift = scrollOffset * 0.4;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── GAMBAR dengan parallax transform
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
            child: Transform.translate(
              offset: Offset(0, -parallaxShift),
              child: Transform.scale(
                scale: 1.0 + (parallaxShift / heroHeight).clamp(0, 0.12),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  height: heroHeight + 80,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.landscape_rounded,
                        size: 64,
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── GRADIENT OVERLAY
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.3, 0.55, 0.75, 1.0],
                  colors: [
                    Color(0x33000000),
                    Color(0x08000000),
                    Color(0x55051914),
                    Color(0xCC051410),
                    Color(0xF5040E0C),
                  ],
                ),
              ),
            ),
          ),

          // ── VIRTUAL TOUR BUTTON
          if (item.hasVirtualTour && item.maps360Url != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.sm,
              right: AppSpacing.md,
              child: DetailGlassTourButton(
                onTap: () => onOpenUrl(item.maps360Url!),
              ),
            ),

          // ── INFO OVERLAY
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: (1.0 - ((scrollOffset - 20) / 100)).clamp(0.0, 1.0),
              child: DetailHeroInfoOverlay(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailGlassTourButton extends StatelessWidget {
  final VoidCallback onTap;
  const DetailGlassTourButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.view_in_ar_rounded, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              '360° Tour',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailHeroInfoOverlay extends StatelessWidget {
  final DestinationModel item;
  const DetailHeroInfoOverlay({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.name,
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.15,
              shadows: [
                const Shadow(
                  color: Color(0x55000000),
                  blurRadius: 16,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        item.location,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StreamBuilder<DestinationModel?>(
                stream: DestinationService().streamById(item.id),
                builder: (context, snapshot) {
                  final rating = snapshot.data?.rating ?? item.rating;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Color(0xFFFFD166),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}