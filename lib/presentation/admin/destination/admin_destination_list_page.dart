// lib/presentation/admin/destination/admin_destination_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/category_model.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';
import 'package:aplikasi_wisata/providers/destination_provider.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';
import 'admin_destination_form_page.dart';

class AdminDestinationListPage extends StatefulWidget {
  const AdminDestinationListPage({super.key});

  @override
  State<AdminDestinationListPage> createState() =>
      _AdminDestinationListPageState();
}

class _AdminDestinationListPageState extends State<AdminDestinationListPage> {
  final _searchController = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DestinationModel> _applyLocalFilter(List<DestinationModel> source) {
    if (_keyword.isEmpty) return source;
    return source
        .where((d) => d.name.toLowerCase().contains(_keyword))
        .toList();
  }

  /// Groups filtered destinations by category order from CategoryProvider.
  /// Uncategorized destinations land in a trailing null-key section.
  List<({CategoryModel? category, List<DestinationModel> destinations})>
  _buildSections(
    List<CategoryModel> categories,
    List<DestinationModel> filtered,
  ) {
    final grouped = <String, List<DestinationModel>>{};
    for (final d in filtered) {
      grouped.putIfAbsent(d.categoryId, () => []).add(d);
    }

    final sections =
        <({CategoryModel? category, List<DestinationModel> destinations})>[];
    for (final cat in categories) {
      if (grouped.containsKey(cat.id)) {
        sections.add((category: cat, destinations: grouped.remove(cat.id)!));
      }
    }
    // Remaining = uncategorized
    if (grouped.isNotEmpty) {
      final uncategorized = grouped.values.expand((l) => l).toList();
      sections.add((category: null, destinations: uncategorized));
    }
    return sections;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DestinationModel destination,
  ) async {
    final provider = context.read<DestinationProvider>();
    final inPackage = await provider.isDestinationInAnyPackage(destination.id);
    if (!context.mounted) return;

    if (inPackage) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              title: const Text('Tidak Bisa Dihapus'),
              content: Text(
                '"${destination.name}" masih termasuk dalam salah satu Paket Wisata. '
                'Hapus dari daftar paket terkait terlebih dahulu.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mengerti'),
                ),
              ],
            ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            title: const Text('Hapus Destinasi?'),
            content: Text(
              '"${destination.name}" beserta seluruh ulasannya akan dihapus permanen.',
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
      try {
        await provider.deleteDestination(destination.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Destinasi dihapus')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _openForm(BuildContext context, {DestinationModel? existing}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDestinationFormPage(existing: existing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().destinationCategories;
    final provider = context.watch<DestinationProvider>();

    if (provider.isLoading && provider.allDestinations.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filtered = _applyLocalFilter(provider.allDestinations);
    final sections = _buildSections(categories, filtered);

    return Scaffold(
      backgroundColor: AppColors.background,
      // ── AppBar + Search ────────────────────────────────────────────
      appBar: AppBar(
        title: const Text('Kelola Destinasi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged:
                  (v) => setState(() => _keyword = v.toLowerCase().trim()),
              decoration: InputDecoration(
                hintText: 'Cari nama destinasi...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon:
                    _keyword.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _keyword = '');
                          },
                        )
                        : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
              ),
            ),
          ),
        ),
      ),

      // ── Body ──────────────────────────────────────────────────────
      body:
          filtered.isEmpty
              ? _EmptyState(isSearching: _keyword.isNotEmpty)
              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                itemCount: _countItems(sections),
                itemBuilder:
                    (context, index) => _buildItem(context, sections, index),
              ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add_rounded, color: AppColors.textOnDark),
      ),
    );
  }

  /// Calculates total item count: 1 header + N destinations per section.
  int _countItems(
    List<({CategoryModel? category, List<DestinationModel> destinations})>
    sections,
  ) {
    return sections.fold(0, (sum, s) => sum + 1 + s.destinations.length);
  }

  /// Maps flat list index to either a section header or a destination card.
  Widget _buildItem(
    BuildContext context,
    List<({CategoryModel? category, List<DestinationModel> destinations})>
    sections,
    int index,
  ) {
    int cursor = 0;
    for (final section in sections) {
      if (index == cursor) {
        return _CategorySectionHeader(
          categoryName: section.category?.name ?? 'Tanpa Kategori',
          count: section.destinations.length,
        );
      }
      cursor++;
      final localIndex = index - cursor;
      if (localIndex < section.destinations.length) {
        final d = section.destinations[localIndex];
        return _DestinationCard(
          destination: d,
          onEdit: () => _openForm(context, existing: d),
          onDelete: () => _confirmDelete(context, d),
        );
      }
      cursor += section.destinations.length;
    }
    return const SizedBox.shrink();
  }
}

// ── _CategorySectionHeader ───────────────────────────────────────────────────

class _CategorySectionHeader extends StatelessWidget {
  final String categoryName;
  final int count;

  const _CategorySectionHeader({
    required this.categoryName,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            categoryName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Divider(color: AppColors.divider, height: 1)),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              '$count item',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _DestinationCard ─────────────────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DestinationCard({
    required this.destination,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child:
                      destination.imageUrl.isNotEmpty
                          ? Image.network(
                            destination.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imageFallback(),
                          )
                          : _imageFallback(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destination.location.isNotEmpty
                          ? destination.location
                          : '—',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Badges
                    Row(
                      children: [
                        if (destination.hasVirtualTour)
                          _Badge(
                            icon: Icons.threed_rotation_rounded,
                            label: 'VT',
                            color: AppColors.primary,
                          ),
                        if (destination.isRecommended) ...[
                          if (destination.hasVirtualTour)
                            const SizedBox(width: AppSpacing.xs),
                          _Badge(
                            icon: Icons.star_rounded,
                            label: 'Rekomendasi',
                            color: AppColors.starColor,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Delete action
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: onDelete,
                tooltip: 'Hapus',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageFallback() => Container(
    color: AppColors.primarySurface,
    child: const Icon(
      Icons.landscape_rounded,
      color: AppColors.primary,
      size: 28,
    ),
  );
}

// ── _Badge ───────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── _EmptyState ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isSearching;

  const _EmptyState({required this.isSearching});

  @override
  Widget build(BuildContext context) {
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
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.landscape_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isSearching ? 'Tidak ada hasil' : 'Belum ada destinasi',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isSearching
                  ? 'Coba kata kunci yang berbeda'
                  : 'Tekan + untuk menambah destinasi baru',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
