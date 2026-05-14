// lib/widgets/review/review_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/providers/review_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class ReviewForm extends StatefulWidget {
  final ReviewTarget target;
  final String targetId;
  final VoidCallback onClose;

  const ReviewForm({
    super.key,
    required this.target,
    required this.targetId,
    required this.onClose,
  });

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

  Future<void> _handleSubmit() async {
    // Ambil provider via read — tidak perlu listen/rebuild untuk action
    final provider = context.read<ReviewProvider>();

    await provider.submitReview(
      target: widget.target,
      targetId: widget.targetId,
      comment: _commentController.text,
    );

    if (!mounted) return;

    final state = provider.submitState;

    if (state == ReviewSubmitState.success) {
      _commentController.clear();
      widget.onClose();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.textOnDark,
                size: 18,
              ),
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
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textOnDark,
            ),
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
    // ── Container utama TIDAK lagi dibungkus Consumer.
    // Consumer hanya diletakkan pada bagian kecil yang benar-benar
    // perlu re-render: rating picker dan tombol kirim.
    // TextField sama sekali tidak tersentuh saat provider berubah.
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
          // ── Header — tidak perlu rebuild, tidak ada state di sini
          _buildHeader(),
          const SizedBox(height: AppSpacing.md),

          // ── Rating picker: Selector hanya rebuild saat selectedRating berubah
          Selector<ReviewProvider, double>(
            selector: (_, p) => p.selectedRating,
            builder: (context, selectedRating, _) {
              return _buildRatingPicker(context, selectedRating);
            },
          ),

          const SizedBox(height: AppSpacing.sm + 4),

          // ── TextField: TIDAK di dalam Consumer/Selector
          // sehingga tidak pernah di-rebuild oleh provider
          _buildCommentField(),

          const SizedBox(height: AppSpacing.sm + 4),

          // ── Tombol: Selector hanya rebuild saat isLoading berubah
          Selector<ReviewProvider, bool>(
            selector: (_, p) => p.isLoading,
            builder: (context, isLoading, _) {
              return _buildActionButtons(context, isLoading);
            },
          ),
        ],
      ),
    );
  }

  // ── Header statis, tidak perlu parameter provider
  Widget _buildHeader() {
    return Row(
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
          'Tulis Ulasan',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── Rating picker menerima nilai dari Selector, bukan dari Consumer penuh
  Widget _buildRatingPicker(BuildContext context, double selectedRating) {
    // Gunakan read() untuk action — tidak menyebabkan widget ini listen lagi
    final provider = context.read<ReviewProvider>();

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
            final filled = i < selectedRating;
            return GestureDetector(
              onTap: () => provider.setRating((i + 1).toDouble()),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: filled ? const Color(0xFFE8A020) : AppColors.divider,
                  size: 28,
                ),
              ),
            );
          }),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${selectedRating.toInt()}/5',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── TextField murni — tidak ada provider di sini
  Widget _buildCommentField() {
    return TextField(
      controller: _commentController,
      maxLines: 3,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Ceritakan pengalaman Anda...',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHint,
          fontSize: 13,
        ),
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  // ── Tombol menerima isLoading dari Selector
  Widget _buildActionButtons(BuildContext context, bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : widget.onClose,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.divider, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
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
              gradient: isLoading ? null : AppColors.primaryGradient,
              color: isLoading ? AppColors.primaryLight.withOpacity(0.3) : null,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow:
                  isLoading
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
              onPressed: isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm + 2,
                ),
              ),
              child:
                  isLoading
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
