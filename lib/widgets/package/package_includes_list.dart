// lib/widgets/package/package_includes_list.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

/// Menampilkan fasilitas umum paket dalam bentuk chip/badge berlayout Wrap.
/// Setiap item memiliki ikon centang dan teks fasilitas.
/// Layout Wrap memastikan chip otomatis pindah baris jika layar penuh.
///
/// [includes] : daftar string fasilitas umum dari PackageModel.includes
class PackageIncludesList extends StatelessWidget {
  final List<String> includes;
  const PackageIncludesList({super.key, required this.includes});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children:
          includes
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.earthSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: AppColors.earthLight.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 13,
                        color: AppColors.earth,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}
