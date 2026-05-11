// lib/widgets/accommodation/accommodation_glass_tour_button.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class AccommodationGlassTourButton extends StatelessWidget {
  final VoidCallback onTap;

  const AccommodationGlassTourButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.view_in_ar_rounded, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              '360° Tour',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}