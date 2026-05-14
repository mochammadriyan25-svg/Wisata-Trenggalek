// lib/widgets/detail/detail_content_card.dart
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';
import 'package:aplikasi_wisata/widgets/detail/detail_section_label.dart';
import 'package:aplikasi_wisata/widgets/detail/detail_map_section.dart';
import 'package:aplikasi_wisata/widgets/detail/detail_entrance_fee_card.dart';
import 'package:aplikasi_wisata/widgets/detail/detail_action_buttons.dart';
import 'package:aplikasi_wisata/widgets/review/review_section.dart';
import 'package:aplikasi_wisata/widgets/detail/detail_recommendation_section.dart';
import 'package:aplikasi_wisata/widgets/detail/accommodation_recommendation_section.dart';
import 'package:aplikasi_wisata/data/services/firestore/review_service.dart';

class DetailContentCard extends StatelessWidget {
  final DestinationModel item;
  final bool isFavorite;
  final bool isTogglingFavorite;
  final Future<void> Function(String) onOpenUrl;
  final VoidCallback onFavorite;

  const DetailContentCard({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.isTogglingFavorite,
    required this.onOpenUrl,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                const DetailSectionLabel(label: "Tentang Destinasi"),
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
                DetailMapSection(item: item, onOpenUrl: onOpenUrl),
                const SizedBox(height: AppSpacing.lg),
                DetailEntranceFeeCard(item: item),
                const SizedBox(height: AppSpacing.lg),
                Divider(color: AppColors.divider, thickness: 1),
                const SizedBox(height: AppSpacing.lg),
                ReviewSection(
                  target: ReviewTarget.destination,
                  targetId: item.id,
                ),
                Divider(color: AppColors.divider, thickness: 1),
                const SizedBox(height: AppSpacing.lg),
                RecommendationSection(
                  currentDestinationId: item.id,
                  currentLatitude: item.latitude,
                  currentLongitude: item.longitude,
                ),
                Divider(color: AppColors.divider, thickness: 1),
                const SizedBox(height: AppSpacing.lg),
                AccommodationRecommendationSection(
                  currentLatitude: item.latitude,
                  currentLongitude: item.longitude,
                ),
                const SizedBox(height: AppSpacing.xl),
                DetailActionButtons(
                  isFavorite: isFavorite,
                  isLoading: isTogglingFavorite,
                  onFavorite: onFavorite,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
