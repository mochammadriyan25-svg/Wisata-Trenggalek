// lib/presentation/admin/favorite/admin_favorite_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/favorite_stat_model.dart';
import 'package:aplikasi_wisata/data/models/favorite_model.dart';
import 'package:aplikasi_wisata/providers/admin_provider.dart';
import 'package:aplikasi_wisata/providers/destination_provider.dart';
import 'package:aplikasi_wisata/providers/accommodation_provider.dart';
import 'package:aplikasi_wisata/providers/package_provider.dart';

class AdminFavoritePage extends StatelessWidget {
  const AdminFavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Analitik Favorit'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Paling Disukai'),
              Tab(icon: Icon(Icons.history_rounded), text: 'Log Aktivitas'),
            ],
          ),
        ),
        body: const TabBarView(children: [_MostLikedTab(), _ActivityLogTab()]),
      ),
    );
  }
}

// ── Most Liked Tab ───────────────────────────────────────────────────────────

class _MostLikedTab extends StatelessWidget {
  const _MostLikedTab();

  String _resolveName(
    FavoriteStatModel stat,
    DestinationProvider dests,
    AccommodationProvider accoms,
    PackageProvider pkgs,
  ) {
    return switch (stat.itemType) {
      FavoriteItemType.destination =>
        dests.allDestinations
                .where((d) => d.id == stat.itemId)
                .firstOrNull
                ?.name ??
            'ID: ${stat.itemId.substring(0, stat.itemId.length.clamp(0, 8))}',
      FavoriteItemType.accommodation =>
        accoms.allAccommodations
                .where((a) => a.id == stat.itemId)
                .firstOrNull
                ?.name ??
            'ID: ${stat.itemId.substring(0, stat.itemId.length.clamp(0, 8))}',
      FavoriteItemType.package =>
        pkgs.allPackages.where((p) => p.id == stat.itemId).firstOrNull?.name ??
            'ID: ${stat.itemId.substring(0, stat.itemId.length.clamp(0, 8))}',
    };
  }

  String? _resolveImage(
    FavoriteStatModel stat,
    DestinationProvider dests,
    AccommodationProvider accoms,
    PackageProvider pkgs,
  ) {
    return switch (stat.itemType) {
      FavoriteItemType.destination =>
        dests.allDestinations
            .where((d) => d.id == stat.itemId)
            .firstOrNull
            ?.imageUrl,
      FavoriteItemType.accommodation =>
        accoms.allAccommodations
            .where((a) => a.id == stat.itemId)
            .firstOrNull
            ?.imageUrl,
      FavoriteItemType.package =>
        pkgs.allPackages
            .where((p) => p.id == stat.itemId)
            .firstOrNull
            ?.imageUrl,
    };
  }

  Color _typeColor(FavoriteItemType type) => switch (type) {
    FavoriteItemType.destination => AppColors.primary,
    FavoriteItemType.accommodation => AppColors.starColor,
    FavoriteItemType.package => AppColors.textHint,
  };

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final dests = context.watch<DestinationProvider>();
    final accoms = context.watch<AccommodationProvider>();
    final pkgs = context.watch<PackageProvider>();
    final stats = admin.favoriteStats;

    if (admin.statsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (stats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Belum ada data favorit',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Muncul secara otomatis saat pengguna pertama\nmenambahkan item ke favorit',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final maxCount = stats.first.count;

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: stats.length,
      itemBuilder: (context, i) {
        final stat = stats[i];
        final name = _resolveName(stat, dests, accoms, pkgs);
        final imageUrl = _resolveImage(stat, dests, accoms, pkgs);
        final color = _typeColor(stat.itemType);
        final progress = maxCount > 0 ? stat.count / maxCount : 0.0;

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
            child: Row(
              children: [
                // Rank badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        i < 3
                            ? AppColors.starColor.withValues(alpha: 0.15)
                            : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: i < 3 ? AppColors.starColor : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Thumbnail
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: Image.network(
                      imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallback(color),
                    ),
                  )
                else
                  _fallback(color),
                const SizedBox(width: AppSpacing.sm),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull,
                              ),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                backgroundColor: color.withValues(alpha: 0.12),
                                valueColor: AlwaysStoppedAnimation(color),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                            ),
                            child: Text(
                              '❤ ${stat.count}',
                              style: AppTextStyles.caption.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(stat.typeLabel, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _fallback(Color color) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
    ),
    child: Icon(Icons.favorite_rounded, color: color, size: 24),
  );
}

// ── Activity Log Tab ──────────────────────────────────────────────────────────
// Menampilkan log terpadu: admin deletions + user self-removals

class _ActivityLogTab extends StatelessWidget {
  const _ActivityLogTab();

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<AdminProvider>().mergedActivityLogs;

    if (logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Belum ada riwayat aktivitas',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Log muncul saat:\n'
                '• Admin menghapus favorit pengguna\n'
                '• Pengguna menghapus favoritnya sendiri',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Legend
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: Row(
            children: [
              _LegendDot(color: AppColors.error, label: 'Admin menghapus'),
              const SizedBox(width: AppSpacing.md),
              _LegendDot(
                color: AppColors.starColor,
                label: 'User menghapus sendiri',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: logs.length,
            itemBuilder: (context, i) => _ActivityLogCard(log: logs[i]),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

// ── _ActivityLogCard ─────────────────────────────────────────────────────────

class _ActivityLogCard extends StatelessWidget {
  final FavoriteLogEntry log;
  const _ActivityLogCard({required this.log});

  bool get _isAdminAction => log.source == FavoriteLogSource.adminDeleted;

  Color get _accentColor =>
      _isAdminAction ? AppColors.error : AppColors.starColor;

  Color get _typeColor => switch (log.itemType) {
    FavoriteItemType.destination => AppColors.primary,
    FavoriteItemType.accommodation => AppColors.starColor,
    FavoriteItemType.package => AppColors.textHint,
  };

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(log.activityAt.toDate());

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: AppColors.divider),
        // Left accent border via stack trick
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar — merah untuk admin, kuning untuk user sendiri
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusMd),
                  bottomLeft: Radius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source badge + item type badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isAdminAction
                                    ? Icons.admin_panel_settings_rounded
                                    : Icons.person_rounded,
                                size: 11,
                                color: _accentColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                log.sourceLabel,
                                style: AppTextStyles.caption.copyWith(
                                  color: _accentColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _typeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                          ),
                          child: Text(
                            log.typeLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: _typeColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Item name
                    Text(
                      log.itemName.isNotEmpty
                          ? log.itemName
                          : 'Item ID: ${log.itemId.length > 10 ? log.itemId.substring(0, 10) : log.itemId}...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Who did it
                    Row(
                      children: [
                        Icon(
                          _isAdminAction
                              ? Icons.admin_panel_settings_outlined
                              : Icons.person_outline_rounded,
                          size: 13,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isAdminAction
                              ? 'Admin: ${log.performedByName}'
                              : 'Pengguna: ${log.performedByName.isNotEmpty ? log.performedByName : log.userId}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Whose favorite
                    if (_isAdminAction)
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 13,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Favorit milik: ${log.userName.isNotEmpty ? log.userName : log.userId}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    const SizedBox(height: 2),

                    // Timestamp
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(date, style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
