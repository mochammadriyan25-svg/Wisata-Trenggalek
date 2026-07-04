// lib/presentation/admin/place/admin_place_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/place_model.dart';
import 'package:aplikasi_wisata/data/models/category_model.dart';
import 'package:aplikasi_wisata/data/services/firestore/place_service.dart';
import 'package:aplikasi_wisata/providers/place_provider.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';
import 'admin_place_form_page.dart';

class AdminPlaceListPage extends StatefulWidget {
  const AdminPlaceListPage({super.key});

  @override
  State<AdminPlaceListPage> createState() => _AdminPlaceListPageState();
}

class _AdminPlaceListPageState extends State<AdminPlaceListPage> {
  final _searchController = TextEditingController();
  final _service = PlaceService();
  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlaceModel> _filter(List<PlaceModel> source) {
    if (_keyword.isEmpty) return source;
    return source
        .where((p) => p.name.toLowerCase().contains(_keyword))
        .toList();
  }

  Future<void> _confirmDelete(BuildContext context, PlaceModel place) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            title: const Text('Hapus Tempat?'),
            content: Text('"${place.name}" akan dihapus permanen.'),
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
        await _service.deletePlace(place.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Tempat dihapus')));
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

  CategoryModel? _resolveCategory(PlaceModel place) {
    if (place.categoryId == null) return null;
    return context
        .read<CategoryProvider>()
        .categories
        .where((c) => c.id == place.categoryId)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaceProvider>();
    final all = _filter(provider.allPlaces);

    final worship = all.where((p) => p.placeType == PlaceType.worship).toList();
    final health = all.where((p) => p.placeType == PlaceType.health).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Tempat'),
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
                hintText: 'Cari nama tempat...',
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
      body:
          provider.isLoading && provider.allPlaces.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : all.isEmpty
              ? _buildEmpty()
              : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                children: [
                  if (worship.isNotEmpty) ...[
                    _SectionHeader(
                      label: 'Tempat Ibadah',
                      count: worship.length,
                      color: const Color(0xFF8B5CF6),
                    ),
                    ...worship.map(
                      (p) => _PlaceCard(
                        place: p,
                        category: _resolveCategory(p),
                        onEdit:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminPlaceFormPage(existing: p),
                              ),
                            ),
                        onDelete: () => _confirmDelete(context, p),
                      ),
                    ),
                  ],
                  if (health.isNotEmpty) ...[
                    _SectionHeader(
                      label: 'Fasilitas Kesehatan',
                      count: health.length,
                      color: const Color(0xFF10B981),
                    ),
                    ...health.map(
                      (p) => _PlaceCard(
                        place: p,
                        category: _resolveCategory(p),
                        onEdit:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminPlaceFormPage(existing: p),
                              ),
                            ),
                        onDelete: () => _confirmDelete(context, p),
                      ),
                    ),
                  ],
                ],
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminPlaceFormPage()),
            ),
        child: const Icon(Icons.add_rounded, color: AppColors.textOnDark),
      ),
    );
  }

  Widget _buildEmpty() => Center(
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
              Icons.place_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _keyword.isNotEmpty ? 'Tidak ada hasil' : 'Belum ada data tempat',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_keyword.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'Tekan + untuk menambah tempat ibadah atau kesehatan',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
    child: Row(
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
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
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            '$count item',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final CategoryModel? category; // ✅ NEW
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlaceCard({
    required this.place,
    this.category, // ✅ NEW
    required this.onEdit,
    required this.onDelete,
  });

  Color get _accent =>
      place.isWorship ? const Color(0xFF8B5CF6) : const Color(0xFF10B981);

  @override
  Widget build(BuildContext context) => Card(
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
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: SizedBox(
                width: 60,
                height: 60,
                child:
                    place.imageUrl.isNotEmpty
                        ? Image.network(
                          place.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _fallback(),
                        )
                        : _fallback(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    place.location,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Text(
                          category?.name ?? place.placeTypeLabel, // ✅ NEW
                          style: AppTextStyles.caption.copyWith(
                            color: _accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (place.hasVirtualTour) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                          ),
                          child: Text(
                            'VT',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _fallback() => Container(
    color: _accent.withValues(alpha: 0.12),
    child: Icon(
      place.isWorship ? Icons.place_rounded : Icons.local_hospital_rounded,
      color: _accent,
      size: 28,
    ),
  );
}
