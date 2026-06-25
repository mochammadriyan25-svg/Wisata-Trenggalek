// lib/presentation/admin/destination/admin_destination_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';
import 'package:aplikasi_wisata/providers/destination_provider.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';

class AdminDestinationListPage extends StatefulWidget {
  const AdminDestinationListPage({super.key});

  @override
  State<AdminDestinationListPage> createState() => _AdminDestinationListPageState();
}

class _AdminDestinationListPageState extends State<AdminDestinationListPage> {
  // ⚠️ Search di sini SENGAJA lokal (state widget), BUKAN provider.search().
  // Lihat catatan di atas — DestinationProvider singleton dipakai ExplorePage juga.
  final _searchController = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DestinationModel> _applyLocalFilter(List<DestinationModel> source) {
    if (_keyword.isEmpty) return source;
    return source.where((d) => d.name.toLowerCase().contains(_keyword)).toList();
  }

  Future<void> _confirmDelete(BuildContext context, DestinationModel destination) async {
    final provider = context.read<DestinationProvider>();
    final inPackage = await provider.isDestinationInAnyPackage(destination.id);
    if (!context.mounted) return;

    if (inPackage) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Tidak Bisa Dihapus'),
          content: Text(
            'Destinasi "${destination.name}" masih termasuk dalam salah satu Paket Wisata. '
            'Hapus dulu dari daftar destinasi paket terkait sebelum menghapus.',
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mengerti'))],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Destinasi?'),
        content: Text('Destinasi "${destination.name}" beserta seluruh ulasannya akan dihapus permanen.'),
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
        await provider.deleteDestination(destination.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Destinasi dihapus')));
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

  void _openForm(BuildContext context, {DestinationModel? existing}) {
    // TODO: ganti dengan AdminDestinationFormPage (dikirim di pesan berikutnya)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form Destinasi segera tersedia')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryMap = {
      for (final c in context.watch<CategoryProvider>().destinationCategories) c.id: c.name,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Destinasi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _keyword = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Cari nama destinasi...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<DestinationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.allDestinations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = _applyLocalFilter(provider.allDestinations);
          if (list.isEmpty) {
            return Center(child: Text('Tidak ada destinasi', style: AppTextStyles.bodyMedium));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final d = list[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.sm),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: d.imageUrl.isNotEmpty
                          ? Image.network(d.imageUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: AppColors.primarySurface))
                          : Container(color: AppColors.primarySurface,
                              child: const Icon(Icons.image_rounded, color: AppColors.primary)),
                    ),
                  ),
                  title: Text(d.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '${categoryMap[d.categoryId] ?? "Tanpa Kategori"} · ${d.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (d.hasVirtualTour)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.threed_rotation_rounded, size: 18, color: AppColors.primary),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        onPressed: () => _confirmDelete(context, d),
                      ),
                    ],
                  ),
                  onTap: () => _openForm(context, existing: d),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add_rounded, color: AppColors.textOnDark),
      ),
    );
  }
}