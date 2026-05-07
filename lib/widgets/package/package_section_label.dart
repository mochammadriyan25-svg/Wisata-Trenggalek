// lib/widgets/package/package_section_label.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

/// Label judul section dengan aksen garis vertikal gradient di sebelah kiri.
/// Dipakai berulang sebagai pemisah antar section di PackageDetailPage
/// (contoh: "Tentang Paket", "Pilih Paket", "Fasilitas Umum", dll.).
class PackageSectionLabel extends StatelessWidget {
  final String label;
  const PackageSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
