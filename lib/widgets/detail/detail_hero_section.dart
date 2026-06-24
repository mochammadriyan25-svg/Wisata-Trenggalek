// lib/widgets/detail/detail_hero_section.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/utils/virtual_tour_guard.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';
import 'package:aplikasi_wisata/data/services/firestore/destination_service.dart';
import 'package:aplikasi_wisata/presentation/pages/virtual_tour_page.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_revisit_screen.dart'; // ← tambah
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_tour_mode_sheet.dart';

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

  /// Menangani tap tombol VT — async karena bisa menampilkan dialog revisit
  /// yang menimpa halaman detail (bukan navigasi ke screen baru).
  Future<void> _handleTourTap(BuildContext context) async {
    // ── 1. Cek limit sesi
    if (VirtualTourGuard.isLimitReached) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Batas virtual tour sesi ini tercapai.'),
          backgroundColor: AppColors.vtScrimDark, // ← was Colors.black87
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppSpacing.radiusMd,
            ), // ← was 12
          ),
        ),
      );
      return;
    }

    if (VirtualTourGuard.isDebouncing) return;

    final lat = item.latitude;
    final lng = item.longitude;

    // ── 2. Cek revisit — dialog menimpa halaman saat ini, bukan screen baru
    if (VirtualTourGuard.hasVisited(lat, lng)) {
      final confirmed = await VtRevisitScreen.show(context, item.name);
      if (!context.mounted) return;
      if (!confirmed) return;
    }

    if (!context.mounted) return;

    final hasExtra = item.hasPhotoSphere || item.hasImage360;

    // ── 3. Helper navigasi — recordLoad dipanggil hanya saat tour benar-benar dibuka
    void navigateTo(VtTourMode mode) {
      VirtualTourGuard.markTap();
      VirtualTourGuard.recordLoad(lat, lng);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VirtualTourPage(destination: item, tourMode: mode),
        ),
      );
    }

    // ── 4. Pilih mode
    if (hasExtra) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        builder:
            (sheetCtx) => VtTourModeSheet(
              destinationName: item.name,
              hasStreetView: true,
              hasPhotoSphere: item.hasPhotoSphere,
              hasImage360: item.hasImage360,
              onSelectStreetView: () {
                Navigator.pop(sheetCtx);
                navigateTo(VtTourMode.streetView);
              },
              onSelectPhotoSphere:
                  item.hasPhotoSphere
                      ? () {
                        Navigator.pop(sheetCtx);
                        navigateTo(VtTourMode.photoSphere);
                      }
                      : null,
              onSelectImage360:
                  item.hasImage360
                      ? () {
                        Navigator.pop(sheetCtx);
                        navigateTo(VtTourMode.image360);
                      }
                      : null,
            ),
      );
    } else {
      navigateTo(VtTourMode.streetView);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double heroHeight = 420;
    final double parallaxShift = scrollOffset * 0.4;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
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
                  errorBuilder:
                      (_, __, ___) => Container(
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

          // Overlay gradient — dibiarkan sebagai literal (nilai spesifik visual)
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

          if (item.hasVirtualTour)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.sm,
              right: AppSpacing.md,
              child: DetailGlassTourButton(
                hasExtra: item.hasPhotoSphere || item.hasImage360,
                onTap: () => _handleTourTap(context),
              ),
            ),

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

// ── DetailGlassTourButton ─────────────────────────────────────────────────────

class DetailGlassTourButton extends StatelessWidget {
  final bool hasExtra;
  final VoidCallback onTap;

  const DetailGlassTourButton({
    super.key,
    required this.hasExtra,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    // ── FIX: dibungkus ClipRRect + BackdropFilter agar jadi frosted glass
    // sungguhan (blur foto di belakangnya), bukan cuma warna tipis di atas
    // foto. Tanpa blur, fill 15% putih lama gampang "hilang" kalau foto
    // latar terang — makanya kelihatan terlalu transparan.
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            // ← was AppColors.vtDialogAction (15% putih, terlalu transparan).
            // Token baru khusus badge ini, supaya badge rating di
            // DetailHeroInfoOverlay (masih pakai vtDialogAction) tidak ikut
            // berubah.
            color: AppColors.vtTourBadgeFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.vtTourBadgeBorder, // ← was AppColors.vtDialogRim
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.view_in_ar_rounded,
                size: 15,
                color: AppColors.textOnDark, // ← was Colors.white
              ),
              const SizedBox(width: 6),
              Text(
                '360° Tour',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textOnDark, // ← was Colors.white
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.4,
                ),
              ),
              if (hasExtra) ...[
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color:
                        AppColors
                            .vtPhotoSphereAccent, // ← was Color(0xFF81C784)
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

// ── DetailHeroInfoOverlay ─────────────────────────────────────────────────────

class DetailHeroInfoOverlay extends StatelessWidget {
  final DestinationModel item;
  const DetailHeroInfoOverlay({super.key, required this.item});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.name,
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: 26,
            color: AppColors.textOnDark, // ← was Colors.white
            fontWeight: FontWeight.w800,
            height: 1.15,
            shadows: const [
              Shadow(
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
                    color:
                        AppColors
                            .vtTextStrong, // ← was Colors.white.withOpacity(0.8)
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      item.location,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            AppColors
                                .vtTextStrong, // ← was Colors.white.withOpacity(0.8)
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
                    color:
                        AppColors
                            .vtDialogAction, // ← was Colors.white.withOpacity(0.15)
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          AppColors
                              .vtDialogRim, // ← was Colors.white.withOpacity(0.3)
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: AppColors.starColor, // ← was Color(0xFFFFD166)
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textOnDark, // ← was Colors.white
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
