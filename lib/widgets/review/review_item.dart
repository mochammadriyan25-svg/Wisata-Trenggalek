// lib/widgets/review/review_item.dart
import 'package:flutter/material.dart';
import '../../data/models/review_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

// ReviewItem adalah StatelessWidget murni tanpa state apapun.
// Dengan constructor const dan penggunaan ValueKey(r.id) dari parent,
// Flutter dapat skip rebuild item yang datanya tidak berubah saat scroll.
class ReviewItem extends StatelessWidget {
  final ReviewModel review;

  const ReviewItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNeutral.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.sm),
          _buildComment(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userName,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              _buildStars(),
            ],
          ),
        ),
        _buildDate(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: review.userAvatar.isEmpty ? AppColors.primaryGradient : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        image:
            review.userAvatar.isNotEmpty
                ? DecorationImage(
                  image: NetworkImage(review.userAvatar),
                  fit: BoxFit.cover,
                )
                : null,
      ),
      child:
          review.userAvatar.isEmpty
              ? Center(
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'A',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textOnDark,
                    fontSize: 16,
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildStars() {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < review.rating.floor();
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 13,
          color: filled ? const Color(0xFFE8A020) : AppColors.divider,
        );
      }),
    );
  }

  Widget _buildDate() {
    final date = review.createdAt.toDate();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        '${date.day}/${date.month}/${date.year}',
        style: AppTextStyles.caption.copyWith(
          fontSize: 10,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildComment() {
    return Text(
      review.comment,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        fontSize: 13,
        height: 1.55,
      ),
    );
  }
}
