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
import 'package:aplikasi_wisata/widgets/home/login_prompt_sheet.dart';

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
  late final Stream<List<ReviewModel>> _reviewStream;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _reviewStream = _reviewService.getReviews(widget.target, widget.targetId);
  }

  void _handleTapTulis(BuildContext context) {
    if (AuthGuard.isGuest(context)) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (_) => LoginPromptSheet(
              redirectBackRoute: ModalRoute.of(context)?.settings.name ?? '/',
            ),
      );
      return;
    }
    setState(() => _showForm = true);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── HEADER
        _ReviewHeader(
          showForm: _showForm,
          onTapTulis: () => _handleTapTulis(context),
        ),
        const SizedBox(height: AppSpacing.sm + 4),

        // ── FORM
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder:
              (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
              ),
          child:
              _showForm
                  ? Column(
                    key: const ValueKey('review-form'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReviewForm(
                        target: widget.target,
                        targetId: widget.targetId,
                        onClose: () => setState(() => _showForm = false),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        height: isKeyboardVisible ? 16 : AppSpacing.md,
                      ),
                    ],
                  )
                  : const SizedBox.shrink(key: ValueKey('review-form-hidden')),
        ),

        // ── LIST ULASAN
        _ReviewList(stream: _reviewStream),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header dipisah agar tidak rebuild _ReviewList
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewHeader extends StatelessWidget {
  final bool showForm;
  final VoidCallback onTapTulis;

  const _ReviewHeader({required this.showForm, required this.onTapTulis});

  @override
  Widget build(BuildContext context) {
    return Row(
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
              'Ulasan Pengunjung',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        // Tombol selalu muncul untuk semua user (Guest maupun login)
        if (!showForm)
          GestureDetector(
            onTap: onTapTulis,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List ulasan dipisah agar StreamBuilder tidak ikut rebuild
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewList extends StatelessWidget {
  final Stream<List<ReviewModel>> stream;

  const _ReviewList({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReviewModel>>(
      stream: stream,
      initialData: const [],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            (snapshot.data == null || snapshot.data!.isEmpty)) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
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
                'Gagal memuat ulasan.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ),
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
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
              reviews
                  .map((r) => ReviewItem(key: ValueKey(r.id), review: r))
                  .toList(),
        );
      },
    );
  }
}
