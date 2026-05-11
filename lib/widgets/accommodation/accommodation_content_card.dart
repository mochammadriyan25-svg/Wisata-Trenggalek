// lib/widgets/accommodation/accommodation_content_card.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/accommodation_model.dart';
import '../../widgets/review/review_section.dart';
import '../../widgets/detail/detail_recommendation_section.dart';
import 'accommodation_section_label.dart';
import 'accommodation_map_section.dart';
import 'accommodation_room_type_section.dart';
import 'accommodation_action_buttons.dart';
import '../../data/services/firestore/review_service.dart'; // ← TAMBAHKAN INI



class AccommodationContentCard extends StatelessWidget {
  final AccommodationModel item;
  final bool isFavorite;
  final bool isTogglingFavorite;
  final Future<void> Function(String) onOpenUrl;
  final VoidCallback onFavorite;

  const AccommodationContentCard({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.isTogglingFavorite,
    required this.onOpenUrl,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -22),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 14, bottom: 10),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tentang Akomodasi
                  const AccommodationSectionLabel(label: 'Tentang Akomodasi'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    item.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.65,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  Divider(color: AppColors.divider, thickness: 1),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Tipe Kamar (BARU)
                  AccommodationRoomTypeSection(item: item),

                  const SizedBox(height: AppSpacing.lg),
                  Divider(color: AppColors.divider, thickness: 1),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Lokasi
                  AccommodationMapSection(item: item, onOpenUrl: onOpenUrl),

                  const SizedBox(height: AppSpacing.lg),
                  Divider(color: AppColors.divider, thickness: 1),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Review
                  ReviewSection(
                    target: ReviewTarget.destination,
                    targetId: item.id,
                  ),

                  Divider(color: AppColors.divider, thickness: 1),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Rekomendasi
                  RecommendationSection(
                    currentDestinationId: item.id,
                    currentCategoryId: '',
                    currentLatitude: item.latitude,
                    currentLongitude: item.longitude,
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  Divider(color: AppColors.divider, thickness: 1),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Action buttons
                  AccommodationActionButtons(
                    isFavorite: isFavorite,
                    isLoading: isTogglingFavorite,
                    onFavorite: onFavorite,
                    mapsUrl: item.mapsUrl,
                    onOpenUrl: onOpenUrl,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}