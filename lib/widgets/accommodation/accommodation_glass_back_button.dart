// lib/widgets/accommodation/accommodation_glass_back_button.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AccommodationGlassBackButton extends StatelessWidget {
  final double scrollOffset;

  const AccommodationGlassBackButton({super.key, this.scrollOffset = 0});

  @override
  Widget build(BuildContext context) {
    final double solidRatio = (scrollOffset / 60).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Color.lerp(
            Colors.white.withValues(alpha: 0.18),
            AppColors.surface.withValues(alpha: 0.96),
            solidRatio,
          ),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color:
                Color.lerp(
                  Colors.white.withValues(alpha: 0.28),
                  AppColors.divider,
                  solidRatio,
                )!,
            width: 1,
          ),
          boxShadow:
              solidRatio > 0.5
                  ? [
                    BoxShadow(
                      color: AppColors.shadowDeep.withValues(
                        alpha: 0.12 * solidRatio,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : [],
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 14,
          color: Color.lerp(Colors.white, AppColors.textPrimary, solidRatio),
        ),
      ),
    );
  }
}
