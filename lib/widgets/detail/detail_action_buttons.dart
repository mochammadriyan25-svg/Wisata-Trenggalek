//lib/widgets/detail/detail_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';

class DetailActionButtons extends StatelessWidget {
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback onFavorite;

  const DetailActionButtons({
    super.key,
    required this.isFavorite,
    required this.isLoading,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: isLoading ? null : onFavorite,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 52,
              decoration: BoxDecoration(
                gradient: isFavorite ? null : AppColors.primaryGradient,
                color: isFavorite ? AppColors.primarySurface : null,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border:
                    isFavorite
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                boxShadow:
                    isFavorite
                        ? []
                        : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
              ),
              child: Center(
                child:
                    isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                isFavorite
                                    ? AppColors.primary
                                    : AppColors.textOnDark,
                          ),
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color:
                                  isFavorite
                                      ? AppColors.primary
                                      : AppColors.textOnDark,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              isFavorite
                                  ? "Hapus Dari Favorites"
                                  : "Tambahkan ke Favorites",
                              style: AppTextStyles.buttonLabel.copyWith(
                                fontSize: 14,
                                color:
                                    isFavorite
                                        ? AppColors.primary
                                        : AppColors.textOnDark,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
