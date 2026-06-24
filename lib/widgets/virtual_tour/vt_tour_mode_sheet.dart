// lib/widgets/virtual_tour/vt_tour_mode_sheet.dart
import 'dart:ui'; // ← tambah
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';

/// Bottom sheet pilihan mode virtual tour — light glass theme.
/// Muncul ketika destinasi punya lebih dari satu mode yang tersedia.
class VtTourModeSheet extends StatelessWidget {
  final String destinationName;
  final bool hasStreetView;
  final bool hasPhotoSphere;
  final bool hasImage360;
  final VoidCallback onSelectStreetView;
  final VoidCallback? onSelectPhotoSphere;
  final VoidCallback? onSelectImage360;

  const VtTourModeSheet({
    super.key,
    required this.destinationName,
    this.hasStreetView = true,
    this.hasPhotoSphere = false,
    this.hasImage360 = false,
    required this.onSelectStreetView,
    this.onSelectPhotoSphere,
    this.onSelectImage360,
  });

  @override
  Widget build(BuildContext context) {
    final botPad = MediaQuery.of(context).padding.bottom;
    final w = MediaQuery.of(context).size.width;

    // ClipRRect + BackdropFilter untuk efek medium glass —
    // konsisten dengan vt_info_panel dan vt_revisit_screen.
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ), // ← sigma 2, sama dengan panel lain
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.vtPanelGlass, // ← was AppColors.background
            // borderRadius tidak di sini — ClipRRect sudah menanganinya
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, botPad + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Header: icon circle di kiri, judul & destinasi di kanan
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.50),
                      ),
                    ),
                    child: const Icon(
                      Icons.view_in_ar_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Mode Virtual Tour',
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          destinationName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Street View
              if (hasStreetView)
                _ModeCard(
                  icon: Icons.directions_walk_rounded,
                  iconColor: AppColors.vtStreetViewAccent,
                  badgeColor: AppColors.vtModeStreetBg,
                  title: 'Street View',
                  description:
                      'Jelajahi area sekitar destinasi\n'
                      'dengan pandangan 360° dari jalan.\n'
                      'Bisa navigasi dan berjalan mendekati lokasi.',
                  screenWidth: w,
                  onTap: onSelectStreetView,
                ),

              // ── Photo Sphere
              if (hasPhotoSphere && onSelectPhotoSphere != null) ...[
                const SizedBox(height: 12),
                _ModeCard(
                  icon: Icons.panorama_photosphere_rounded,
                  iconColor: AppColors.vtPhotoSphereAccent,
                  badgeColor: AppColors.vtModeSphereBg,
                  title: 'Photo Sphere',
                  description:
                      'Lihat foto panorama 360° yang diambil\n'
                      'langsung di lokasi ini via Google Maps.',
                  screenWidth: w,
                  onTap: onSelectPhotoSphere!,
                ),
              ],

              // ── Foto 360° UGC
              if (hasImage360 && onSelectImage360 != null) ...[
                const SizedBox(height: 12),
                _ModeCard(
                  icon: Icons.image_rounded,
                  iconColor: AppColors.vtImage360Accent,
                  badgeColor: AppColors.vtModeImageBg,
                  title: 'Foto 360° Pengunjung',
                  description:
                      'Lihat foto panorama 360° yang\n'
                      'dikontribusikan oleh pengunjung\n'
                      'destinasi ini.',
                  screenWidth: w,
                  onTap: onSelectImage360!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── _ModeCard ─────────────────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color badgeColor;
  final String title;
  final String description;
  final double screenWidth;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.iconColor,
    required this.badgeColor,
    required this.title,
    required this.description,
    required this.screenWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSpacing.radiusMd),
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.50)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withValues(alpha: 0.50)),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: screenWidth * 0.038,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: screenWidth * 0.03,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textHint,
            size: 22,
          ),
        ],
      ),
    ),
  );
}
