// lib/widgets/accommodation/accommodation_hero_info_overlay.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/accommodation_model.dart';
import '../../data/services/firestore/accommodation_service.dart';

class AccommodationHeroInfoOverlay extends StatelessWidget {
  final AccommodationModel item;

  const AccommodationHeroInfoOverlay({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // bottom dikurangi dari 32 → 12 karena dot indicator sekarang
      // ada di bawah widget ini, bukan overlap
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Type badge
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hotel_rounded, size: 11, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  'Akomodasi',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Name
          Text(
            item.name,
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.15,
              shadows: const [
                Shadow(
                  color: Color(0x55000000),
                  blurRadius: 16,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Location + Rating
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        item.location,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StreamBuilder<AccommodationModel?>(
                stream: AccommodationService().streamById(item.id),
                builder: (context, snapshot) {
                  final rating = snapshot.data?.rating ?? item.rating;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Color(0xFFFFD166),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
