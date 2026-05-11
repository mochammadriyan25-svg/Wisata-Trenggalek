// lib/widgets/accommodation/accommodation_price_badge.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/accommodation_model.dart';

class AccommodationPriceBadge extends StatelessWidget {
  final AccommodationModel item;
  const AccommodationPriceBadge({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: item.isFree ? null : AppColors.primaryGradient,
        color: item.isFree ? Colors.green.shade600 : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        item.isFree ? 'Gratis' : item.formattedStartingPrice,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}