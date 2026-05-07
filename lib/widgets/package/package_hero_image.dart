// lib/widgets/package/package_hero_image.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/package_model.dart';
import 'package_hero_info_overlay.dart'; // ← IMPORT BARU

/// Widget hero di bagian atas PackageDetailPage.
///
/// Skenario A: Info (judul + badge) ditampilkan di hero via [PackageHeroInfoOverlay].
class PackageHeroImage extends StatelessWidget {
  final PackageModel pkg;
  final double scrollOffset;

  const PackageHeroImage({super.key, required this.pkg, this.scrollOffset = 0});

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
                  pkg.imageUrl,
                  fit: BoxFit.cover,
                  height: heroHeight + 80,
                  errorBuilder:
                      (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.card_travel_rounded,
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
            child: const DecoratedBox(
              decoration: BoxDecoration(
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

          // ── INFO OVERLAY — pakai widget public dari file terpisah
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: (1.0 - ((scrollOffset - 20) / 100)).clamp(0.0, 1.0),
              child: PackageHeroInfoOverlay(pkg: pkg), // ← PAKAI PUBLIC WIDGET
            ),
          ),
        ],
      ),
    );
  }
}