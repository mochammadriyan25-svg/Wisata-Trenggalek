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

  Future<void> _confirmDelete(BuildContext context, CategoryModel category) async {
    final provider = context.read<CategoryProvider>();

    final inUse = await provider.isCategoryInUse(category);
    if (!context.mounted) return;

    if (inUse) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Tidak Bisa Dihapus'),
          content: Text(
            'Kategori "${category.name}" masih digunakan oleh data lain. '
            'Pindahkan/ubah kategori data terkait dulu sebelum menghapus.',
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mengerti'))],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: Text('Kategori "${category.name}" akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.deleteCategory(category);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori dihapus')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: AppColors.error),
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
            return Center(child: Text('Belum ada kategori', style: AppTextStyles.bodyMedium));
          }

          // Responsif: jumlah kolom dihitung dari lebar layar tersedia —
          // otomatis menyesuaikan saat rotasi & beda ukuran HP.
          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = (constraints.maxWidth / 220).floor().clamp(2, 6);
              return GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                ),
                itemCount: provider.categories.length,
                itemBuilder: (context, index) {
                  final category = provider.categories[index];
                  return _CategoryCard(
                    category: category,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminCategoryFormPage(existing: category)),
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminCategoryFormPage()),
        ),
        child: const Icon(Icons.add_rounded, color: AppColors.textOnDark),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _CategoryCard({required this.category, required this.onTap, required this.onDelete});

  String get _typeLabel => switch (category.type) {
    CategoryType.destination => 'Destinasi',
    CategoryType.package => 'Paket',
    CategoryType.accommodation => 'Akomodasi',
    _ => '-',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: category.imageUrl.isNotEmpty
                  ? Image.network(category.imageUrl, fit: BoxFit.cover, width: double.infinity,
                      errorBuilder: (_, __, ___) => _iconFallback())
                  : _iconFallback(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                  Row(
                    children: [
                      Expanded(child: Text(_typeLabel, style: AppTextStyles.caption)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
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
    child: Icon(getCategoryIcon(category.icon), size: 40, color: AppColors.primary),
  );
}