// lib/widgets/accommodation/accommodation_room_type_card.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/accommodation_model.dart';
import 'accommodation_facilities_row.dart';

class AccommodationRoomTypeCard extends StatelessWidget {
  final RoomType room;
  final bool isSelected;
  final VoidCallback onTap;

  const AccommodationRoomTypeCard({
    super.key,
    required this.room,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: room.isAvailable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: nama kamar + badge + harga
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ikon kamar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border:
                        isSelected
                            ? null
                            : Border.all(color: AppColors.divider, width: 1),
                  ),
                  child: Icon(
                    Icons.bed_rounded,
                    size: 20,
                    color:
                        isSelected
                            ? AppColors.textOnDark
                            : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Nama + badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              room.name,
                              style: AppTextStyles.headlineSmall.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // Badge "Terpopuler"
                          if (room.isPopular)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusFull,
                                ),
                              ),
                              child: Text(
                                '🔥 Terpopuler',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          // Badge "Tidak Tersedia"
                          if (!room.isAvailable)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusFull,
                                ),
                              ),
                              child: Text(
                                'Tidak Tersedia',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Kapasitas tamu
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 12,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Maks. ${room.guestLabel}',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Deskripsi kamar
            if (room.description.isNotEmpty) ...[
              Text(
                room.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // ── Fasilitas
            if (room.hasFacilities) ...[
              AccommodationFacilitiesRow(facilities: room.facilities),
              const SizedBox(height: AppSpacing.sm),
            ],

            // ── Divider tipis
            Divider(
              color:
                  isSelected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.divider,
              thickness: 1,
              height: 16,
            ),

            // ── Harga + indikator selected
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harga per malam',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      room.formattedPrice,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color:
                            room.isFree
                                ? Colors.green.shade600
                                : AppColors.primary,
                      ),
                    ),
                  ],
                ),

                // Indikator pilihan
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : Colors.transparent,
                    border: Border.all(
                      color:
                          isSelected ? Colors.transparent : AppColors.divider,
                      width: 1.5,
                    ),
                  ),
                  child:
                      isSelected
                          ? const Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: Colors.white,
                          )
                          : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
