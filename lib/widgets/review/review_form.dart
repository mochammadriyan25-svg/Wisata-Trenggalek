// lib/widgets/review/review_form.dart
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/providers/review_provider.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class ReviewForm extends StatefulWidget {
  final String destinationId;
  const ReviewForm({super.key, required this.destinationId});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(ReviewProvider provider) async {
    await provider.submitReview(
      destinationId: widget.destinationId,
      comment: _commentController.text,
    );

    if (!mounted) return;

    final state = provider.submitState;

    if (state == ReviewSubmitState.success) {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.textOnDark, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Ulasan berhasil ditambahkan!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textOnDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
    } else if (state == ReviewSubmitState.alreadyReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Anda sudah memberikan ulasan sebelumnya.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.textSecondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
    } else if (state == ReviewSubmitState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
    }

    provider.resetSubmitState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Tulis Ulasan',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _buildRatingPicker(provider),
              const SizedBox(height: AppSpacing.sm + 4),
              _buildCommentField(),
              const SizedBox(height: AppSpacing.sm + 4),
              _buildActionButtons(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingPicker(ReviewProvider provider) {
    return Row(
      children: [
        Text(
          'Rating: ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Row(
          children: List.generate(5, (i) {
            final filled = i < provider.selectedRating;
            return GestureDetector(
              onTap: () => provider.setRating((i + 1).toDouble()),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Icon(
                  filled
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: filled
                      ? const Color(0xFFE8A020)
                      : AppColors.divider,
                  size: 28,
                ),
              ),
            );
          }),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${provider.selectedRating.toInt()}/5',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentField() {
    return TextField(
      controller: _commentController,
      maxLines: 3,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Ceritakan pengalaman Anda di tempat ini...',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHint,
          fontSize: 13,
        ),
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.divider,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.8,
          ),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  Widget _buildActionButtons(ReviewProvider provider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: provider.isLoading ? null : provider.hideForm,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.divider, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm + 2),
            ),
            child: Text(
              'Batal',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: provider.isLoading ? null : AppColors.primaryGradient,
              color: provider.isLoading
                  ? AppColors.primaryLight.withOpacity(0.3)
                  : null,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: provider.isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () => _handleSubmit(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm + 2),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnDark,
                      ),
                    )
                  : Text(
                      'Kirim',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textOnDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}