// lib/widgets/review/review_section.dart
import 'package:flutter/material.dart';
import '../../data/models/review_model.dart';
import '../../data/services/firestore/review_service.dart';
import '../../core/utils/auth_guard.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/widgets/review/review_item.dart';
import 'package:aplikasi_wisata/widgets/review/review_form.dart';

class ReviewSection extends StatefulWidget {
  final ReviewTarget target;
  final String targetId;

  const ReviewSection({
    super.key,
    required this.target,
    required this.targetId,
  });

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final ReviewService _reviewService = ReviewService();
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Ulasan',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (!AuthGuard.isGuest(context) && !_showForm)
              GestureDetector(
                onTap: () => setState(() => _showForm = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.xs + 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tulis Ulasan',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm + 4),

        // ── FORM
        if (_showForm) ...[
          ReviewForm(
            target: widget.target,
            targetId: widget.targetId,
            onClose: () => setState(() => _showForm = false),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ── LIST ULASAN
        StreamBuilder<List<ReviewModel>>(
          stream: _reviewService.getReviews(widget.target, widget.targetId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.divider.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Belum ada ulasan. Jadilah yang pertama!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children:
                  snapshot.data!.map((r) => ReviewItem(review: r)).toList(),
            );
          },
        ),
      ],
    );
  }
}
