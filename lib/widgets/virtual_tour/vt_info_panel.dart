// lib/widgets/virtual_tour/vt_info_panel.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';

/// Panel informasi destinasi yang slide dari bawah layar.
/// Menggunakan BackdropFilter untuk efek medium glass —
/// 80% AppColors.background agar teks tetap terbaca di semua kondisi panorama.
class VtInfoPanel extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onClose;

  const VtInfoPanel({
    super.key,
    required this.destination,
    required this.onClose,
  });

  List<String> get _tips =>
      destination.isKuliner
          ? [
            'Coba menu andalan saat pertama kali berkunjung',
            'Ramai di jam makan siang & malam — datang lebih awal',
            'Tanyakan rekomendasi menu kepada pelayan',
            'Pesan tempat lebih dulu di akhir pekan',
          ]
          : [
            'Datang pagi hari untuk menghindari keramaian',
            'Bawa sunscreen dan topi untuk perlindungan ekstra',
            'Gunakan alas kaki yang nyaman untuk medan berjalan',
            'Jaga kebersihan — buang sampah pada tempatnya',
          ];

  @override
  Widget build(BuildContext context) {
    final botPad = MediaQuery.of(context).padding.bottom;

    // ClipRRect wajib ada agar BackdropFilter terpotong sesuai
    // sudut melengkung panel — tanpa ini blur meluber ke luar panel.
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 2,
          sigmaY: 2,
        ), // blur sedang untuk efek glass yang jelas tapi tidak mengaburkan teks
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, botPad + 24),
          decoration: const BoxDecoration(
            color:
                AppColors.vtPanelGlass, // ← 80% #F7F9F9, was Color(0xF2040E0C)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle bar + tombol tutup
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(
                        0.40,
                      ), // ← was white 25%
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onClose,
                    child: const Icon(
                      Icons.close_rounded,
                      color:
                          AppColors
                              .textSecondary, // ← was Colors.white.withOpacity(0.6)
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Nama + Rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      destination.name,
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontSize: 18,
                        color: AppColors.textPrimary, // ← was Colors.white
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: 0.15,
                      ), // ← was Colors.white.withOpacity(0.10)
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: AppColors.starColor.withValues(
                            alpha: 1.0,
                          ), // ← was Color(0xFFFFD166)
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          destination.rating.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary.withValues(
                              alpha: 0.85,
                            ), // ← was Colors.white
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // ── Lokasi
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 12,
                    color:
                        AppColors
                            .textSecondary, // ← was Colors.white.withOpacity(0.55)
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      destination.location,
                      style: AppTextStyles.caption.copyWith(
                        color:
                            AppColors
                                .textSecondary, // ← was Colors.white.withOpacity(0.55)
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Deskripsi singkat
              Text(
                destination.description.length > 160
                    ? '${destination.description.substring(0, 160)}...'
                    : destination.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color:
                      AppColors
                          .textPrimary, // ← was Colors.white.withOpacity(0.78)
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Tips berkunjung
              Text(
                'Tips Berkunjung',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary, // ← was Colors.white
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._tips.map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 14,
                          color: AppColors.success, // ← was Color(0xFF66BB6A)
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          tip,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.90,
                            ), // ← was Colors.white.withOpacity(0.75)
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
