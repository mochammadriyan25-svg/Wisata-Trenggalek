// lib/widgets/virtual_tour/vt_revisit_screen.dart
import 'dart:ui'; // ← tambah
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';

/// Glass dialog konfirmasi ketika user mencoba membuka kembali virtual tour
/// untuk destinasi yang sudah dikunjungi di sesi yang sama.
///
/// Ditampilkan via [VtRevisitScreen.show] sebagai overlay [showDialog] —
/// tidak membuka route baru, halaman pemanggil tetap terlihat di belakang barrier.
class VtRevisitScreen extends StatelessWidget {
  final String destinationName;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  const VtRevisitScreen({
    super.key,
    required this.destinationName,
    required this.onBack,
    required this.onConfirm,
  });

  static Future<bool> show(BuildContext context, String destinationName) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          barrierColor: const Color(0xCC000000),
          builder:
              (ctx) => Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xxl,
                ),
                child: VtRevisitScreen(
                  destinationName: destinationName,
                  onBack: () => Navigator.of(ctx).pop(false),
                  onConfirm: () => Navigator.of(ctx).pop(true),
                ),
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    // ClipRRect menangani sudut melengkung sekaligus
    // membatasi blur BackdropFilter ke area dialog saja.
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 2,
          sigmaY: 2,
        ), // ← sama dengan vt_info_panel
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.vtPanelGlass.withValues(
              alpha: 0.70,
            ), // ← 80% #F7F9F9, was vtDialogSurface 10%
            // borderRadius tidak di sini — ClipRRect sudah menanganinya
            border: Border.all(
              color: AppColors.primary.withOpacity(
                0.15,
              ), // ← was vtDialogBorder (20% white)
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon circle
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface.withValues(
                    alpha: 0.12,
                  ), // ← was vtDialogIconBg (12% white)
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(
                      alpha: 0.25,
                    ), // ← was vtDialogRim (25% white)
                  ),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.primary, // ← was textOnDark (white)
                  size: 24,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Judul
              Text(
                'Sudah Pernah Dijelajahi',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.textPrimary, // ← was textOnDark (white)
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Body
              Text(
                'Destinasi $destinationName sudah kamu jelajahi '
                'di sesi ini. Ingin membukanya lagi?',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color:
                      AppColors.textSecondary, // ← was vtTextMuted (50% white)
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Tombol aksi
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: onBack,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          side: BorderSide(
                            color: AppColors.primary.withOpacity(
                              0.2,
                            ), // ← was vtDialogBorder
                          ),
                        ),
                      ),
                      child: Text(
                        'Kembali',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color:
                              AppColors
                                  .textSecondary, // ← was vtTextDim (35% white)
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // tetap solid teal
                        foregroundColor: AppColors.textOnDark,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                      ),
                      child: Text(
                        'Buka Lagi',
                        style: AppTextStyles.vtSwitchLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
