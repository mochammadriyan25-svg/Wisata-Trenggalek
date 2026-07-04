// lib/presentation/admin/category/admin_category_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/core/utils/icon_mapper.dart';
import 'package:aplikasi_wisata/data/models/category_model.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';
import 'admin_category_form_page.dart';

class AdminCategoryListPage extends StatelessWidget {
  const AdminCategoryListPage({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    CategoryModel category,
  ) async {
    final provider = context.read<CategoryProvider>();

    final inUse = await provider.isCategoryInUse(category);
    if (!context.mounted) return;

    if (inUse) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              title: const Text('Tidak Bisa Dihapus'),
              content: Text(
                '"${category.name}" masih digunakan oleh data lain. '
                'Pindahkan data terkait ke kategori lain terlebih dahulu.',
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
            title: const Text('Hapus Kategori?'),
            content: Text('"${category.name}" akan dihapus permanen.'),
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
        await provider.deleteCategory(category);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Kategori dihapus')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Kelola Kategori')),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.categories.isEmpty) {
            return _EmptyState(
              onAdd:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminCategoryFormPage(),
                    ),
                  ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = (constraints.maxWidth / 200).floor().clamp(
                2,
                6,
              );
              return GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                ),
                itemCount: provider.categories.length,
                itemBuilder: (context, index) {
                  final category = provider.categories[index];
                  return _CategoryCard(
                    category: category,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    AdminCategoryFormPage(existing: category),
                          ),
                        ),
                    onDelete: () => _confirmDelete(context, category),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminCategoryFormPage()),
            ),
        child: const Icon(Icons.add_rounded, color: AppColors.textOnDark),
      ),
    );
  }
}

// ── _CategoryCard ────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  String get _typeLabel => switch (category.type) {
    CategoryType.destination => 'Destinasi',
    CategoryType.package => 'Paket',
    CategoryType.accommodation => 'Akomodasi',
    CategoryType.placeWorship => 'Tempat Ibadah', // ✅ NEW
    CategoryType.placeHealth => 'Fasilitas Kesehatan',
    _ => category.type,
  };

  Color get _typeColor => switch (category.type) {
    CategoryType.destination => AppColors.primary,
    CategoryType.package => AppColors.starColor,
    CategoryType.placeWorship => const Color(0xFF8B5CF6), // ✅ NEW
    CategoryType.placeHealth => const Color(0xFF10B981), // ✅ NEW
    _ => AppColors.textHint,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  category.imageUrl.isNotEmpty
                      ? Image.network(
                        category.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _iconFallback(),
                      )
                      : _iconFallback(),
                  // Type badge
                  Positioned(
                    top: AppSpacing.xs,
                    left: AppSpacing.xs,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Text(
                        _typeLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textOnDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color:
                                    kValidCategoryIconKeys.contains(
                                          category.icon.toLowerCase(),
                                        )
                                        ? AppColors.primary
                                        : AppColors.textHint,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              category.icon,
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconFallback() => Container(
    color: AppColors.primarySurface,
    child: Icon(
      getCategoryIcon(category.icon),
      size: 40,
      color: AppColors.primary,
    ),
  );
}

// ── _EmptyState ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

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
              child: const Icon(
                Icons.category_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Belum ada kategori',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tekan + untuk menambah kategori baru',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
