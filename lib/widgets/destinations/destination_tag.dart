// lib/widgets/destinations/destination_tag.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class DestinationTag extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  // ── Category tag — teal surface
  const DestinationTag.category({super.key, required this.label})
    : backgroundColor = AppColors.primarySurface,
      textColor = AppColors.primary,
      icon = Icons.category_rounded;

  // ── Popular tag — accent surface
  const DestinationTag.popular({super.key})
    : label = 'Populer',
      backgroundColor = AppColors.accentSurface,
      textColor = AppColors.accent,
      icon = Icons.local_fire_department_rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
