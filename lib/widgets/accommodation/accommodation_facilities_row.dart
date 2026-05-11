// lib/widgets/accommodation/accommodation_facilities_row.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class AccommodationFacilitiesRow extends StatelessWidget {
  final List<String> facilities;

  const AccommodationFacilitiesRow({super.key, required this.facilities});

  @override
  Widget build(BuildContext context) {
    if (facilities.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children:
          facilities.map((facility) => _FacilityChip(label: facility)).toList(),
    );
  }
}

class _FacilityChip extends StatelessWidget {
  final String label;

  const _FacilityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(label), size: 11, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String facility) {
    final f = facility.toLowerCase();
    if (f.contains('wifi') || f.contains('wi-fi')) return Icons.wifi_rounded;
    if (f.contains('ac') || f.contains('air')) return Icons.ac_unit_rounded;
    if (f.contains('tv') || f.contains('televisi')) return Icons.tv_rounded;
    if (f.contains('kamar mandi') || f.contains('shower')) {
      return Icons.shower_rounded;
    }
    if (f.contains('parkir')) return Icons.local_parking_rounded;
    if (f.contains('kolam') || f.contains('pool')) return Icons.pool_rounded;
    if (f.contains('sarapan') || f.contains('makan')) {
      return Icons.restaurant_rounded;
    }
    if (f.contains('kulkas') || f.contains('fridge')) {
      return Icons.kitchen_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }
}
