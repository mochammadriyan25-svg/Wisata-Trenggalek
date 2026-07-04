// lib/presentation/admin/review/admin_review_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/providers/admin_provider.dart';
import 'package:aplikasi_wisata/providers/destination_provider.dart';
import 'package:aplikasi_wisata/providers/accommodation_provider.dart';
import 'package:aplikasi_wisata/providers/package_provider.dart';
import 'package:aplikasi_wisata/data/services/firestore/review_service.dart';

class AdminReviewPage extends StatefulWidget {
  const AdminReviewPage({super.key});

  @override
  State<AdminReviewPage> createState() => _AdminReviewPageState();
}

class _AdminReviewPageState extends State<AdminReviewPage> {
  ReviewTarget? _filterTarget; // null = semua

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAllReviews();
    });
  }

  String _resolveName(AdminReviewItem item) {
    final dests = context.read<DestinationProvider>().allDestinations;
    final accoms = context.read<AccommodationProvider>().allAccommodations;
    final pkgs = context.read<PackageProvider>().allPackages;

    return switch (item.target) {
      ReviewTarget.destination =>
        dests.where((d) => d.id == item.targetId).firstOrNull?.name ??
            item.targetId,
      ReviewTarget.accommodation =>
        accoms.where((a) => a.id == item.targetId).firstOrNull?.name ??
            item.targetId,
      ReviewTarget.package =>
        pkgs.where((p) => p.id == item.targetId).firstOrNull?.name ??
            item.targetId,
    };
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AdminReviewItem item,
  ) async {
    final name = _resolveName(item);
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            title: const Text('Hapus Ulasan?'),
            content: Text(
              'Ulasan oleh "${item.review.userName}" untuk "$name" akan dihapus permanen.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Hapus', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      try {
        await context.read<AdminProvider>().adminDeleteReview(
          item.target,
          item.targetId,
          item.review.id,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Ulasan dihapus')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    final filtered =
        _filterTarget == null
            ? admin.allReviews
            : admin.allReviews.where((r) => r.target == _filterTarget).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Moderasi Ulasan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat ulang',
            onPressed: () => context.read<AdminProvider>().loadAllReviews(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    selected: _filterTarget == null,
                    onTap: () => setState(() => _filterTarget = null),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _FilterChip(
                    label: 'Destinasi',
                    selected: _filterTarget == ReviewTarget.destination,
                    onTap:
                        () => setState(
                          () => _filterTarget = ReviewTarget.destination,
                        ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _FilterChip(
                    label: 'Akomodasi',
                    selected: _filterTarget == ReviewTarget.accommodation,
                    onTap:
                        () => setState(
                          () => _filterTarget = ReviewTarget.accommodation,
                        ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _FilterChip(
                    label: 'Paket',
                    selected: _filterTarget == ReviewTarget.package,
                    onTap:
                        () => setState(
                          () => _filterTarget = ReviewTarget.package,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          if (admin.reviewsLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (filtered.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                      ),
                      child: const Icon(
                        Icons.rate_review_rounded,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      admin.allReviews.isEmpty
                          ? 'Belum ada ulasan dimuat'
                          : 'Tidak ada ulasan untuk filter ini',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (admin.allReviews.isEmpty)
                      TextButton.icon(
                        onPressed:
                            () =>
                                context.read<AdminProvider>().loadAllReviews(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Muat Ulasan'),
                      ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final item = filtered[i];
                  final name = _resolveName(item);
                  return _ReviewCard(
                    item: item,
                    targetName: name,
                    onDelete: () => _confirmDelete(context, item),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── _FilterChip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: selected ? AppColors.textOnDark : AppColors.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── _ReviewCard ──────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final AdminReviewItem item;
  final String targetName;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.item,
    required this.targetName,
    required this.onDelete,
  });

  Color get _targetColor => switch (item.target) {
    ReviewTarget.destination => AppColors.primary,
    ReviewTarget.accommodation => AppColors.starColor,
    ReviewTarget.package => AppColors.textHint,
  };

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'dd MMM yyyy, HH:mm',
      'id_ID',
    ).format(item.review.createdAt.toDate());

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: reviewer + target info
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySurface,
                  backgroundImage:
                      item.review.userAvatar.isNotEmpty
                          ? NetworkImage(item.review.userAvatar)
                          : null,
                  child:
                      item.review.userAvatar.isEmpty
                          ? Text(
                            item.review.userName.isNotEmpty
                                ? item.review.userName[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.review.userName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(date, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                // Target badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _targetColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    item.targetTypeLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: _targetColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                  onPressed: onDelete,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Target name
            Text(
              targetName,
              style: AppTextStyles.caption.copyWith(
                color: _targetColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Rating stars
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < item.review.rating.round()
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 16,
                  color: AppColors.starColor,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Comment
            Text(
              item.review.comment,
              style: AppTextStyles.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
