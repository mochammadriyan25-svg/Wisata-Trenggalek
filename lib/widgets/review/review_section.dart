// lib/widgets/review/review_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/review_model.dart';
import '../../data/services/firestore/review_service.dart';
import '../../core/utils/auth_guard.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/widgets/review/review_item.dart';

class ReviewSection extends StatefulWidget {
  final String destinationId;
  const ReviewSection({super.key, required this.destinationId});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  double _selectedRating = 5.0;
  bool _isSubmitting = false;
  bool _showForm = false;

  String get _userId =>
      context.read<app_auth.AuthProvider>().user?.id ?? '';

  String get _userName {
    final authUser = context.read<app_auth.AuthProvider>().user;
    final name = authUser?.name;
    if (name != null && name.isNotEmpty && name != 'User') return name;
    final email = authUser?.email;
    if (email != null && email.isNotEmpty) return email;
    return 'Anonymous';
  }

  String get _userAvatar =>
      context.read<app_auth.AuthProvider>().user?.photoUrl ?? '';

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);

    final alreadyReviewed = await _reviewService.hasUserReviewed(
      _userId,
      widget.destinationId,
    );

    if (!mounted) return;

    if (alreadyReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Anda sudah memberikan ulasan sebelumnya',
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
      setState(() => _isSubmitting = false);
      return;
    }

    final review = ReviewModel(
      id: '',
      destinationId: widget.destinationId,
      userId: _userId,
      userName: _userName,
      userAvatar: _userAvatar,
      rating: _selectedRating,
      comment: _commentController.text.trim(),
      createdAt: Timestamp.now(),
    );

    await _reviewService.addReview(review);

    if (!mounted) return;

    _commentController.clear();
    setState(() {
      _selectedRating = 5.0;
      _isSubmitting = false;
      _showForm = false;
    });

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
  }

  Widget _buildAddReviewForm() {
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
          // Header form
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

          // Rating picker
          Row(
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
                  final filled = i < _selectedRating;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedRating = (i + 1).toDouble()),
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
                '${_selectedRating.toInt()}/5',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 4),

          // Comment field
          TextField(
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
          ),
          const SizedBox(height: AppSpacing.sm + 4),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _showForm = false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(
                        color: AppColors.divider, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
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
                    gradient: _isSubmitting
                        ? null
                        : AppColors.primaryGradient,
                    color: _isSubmitting
                        ? AppColors.primaryLight.withOpacity(0.3)
                        : null,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    boxShadow: _isSubmitting
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
                    onPressed:
                        _isSubmitting ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm + 2),
                    ),
                    child: _isSubmitting
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
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
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
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

        // Form
        if (_showForm) ...[
          _buildAddReviewForm(),
          const SizedBox(height: AppSpacing.md),
        ],

        // List ulasan
        StreamBuilder<List<ReviewModel>>(
          stream: _reviewService.getReviews(widget.destinationId),
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
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
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

            final reviews = snapshot.data!;
            return Column(
              children:
                  reviews.map((r) => ReviewItem(review: r)).toList(),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}