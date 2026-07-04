// lib/presentation/admin/package/admin_package_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/package_model.dart';
import 'package:aplikasi_wisata/data/services/firestore/package_service.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';
import 'admin_package_form_page.dart';

class AdminPackageListPage extends StatefulWidget {
  const AdminPackageListPage({super.key});

  @override
  State<AdminPackageListPage> createState() => _AdminPackageListPageState();
}

class _AdminPackageListPageState extends State<AdminPackageListPage> {
  final _searchController = TextEditingController();
  final _service = PackageService();
  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PackageModel> _filter(List<PackageModel> source) {
    if (_keyword.isEmpty) return source;
    return source
        .where((p) => p.name.toLowerCase().contains(_keyword))
        .toList();
  }

  Future<void> _confirmDelete(BuildContext context, PackageModel pkg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        title: const Text('Hapus Paket?'),
        content: Text('"${pkg.name}" beserta seluruh ulasannya akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Hapus', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _service.deletePackage(pkg.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Paket dihapus')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Gagal: $e'), backgroundColor: AppColors.error));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryMap = {
      for (final c in context.watch<CategoryProvider>().categories) c.id: c.name,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Paket Wisata'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
            child: TextField(
              controller: _searchController,
              onChanged: (v) =>
                  setState(() => _keyword = v.toLowerCase().trim()),
              decoration: InputDecoration(
                hintText: 'Cari nama paket...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _keyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _keyword = '');
                        })
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    borderSide: BorderSide(color: AppColors.divider)),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<PackageModel>>(
        stream: _service.getAllPackages(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snap.data ?? [];
          final list = _filter(all);

          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg)),
                    child: const Icon(Icons.card_travel_rounded,
                        size: 36, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(_keyword.isNotEmpty ? 'Tidak ada hasil' : 'Belum ada paket',
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600)),
                ]),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final pkg = list[i];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                color: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  side: BorderSide(color: AppColors.divider),
                ),
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              AdminPackageFormPage(existing: pkg))),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        child: SizedBox(
                          width: 64, height: 64,
                          child: pkg.imageUrl.isNotEmpty
                              ? Image.network(pkg.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _imgFallback())
                              : _imgFallback(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(pkg.name,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: pkg.isActive
                                        ? AppColors.primary.withValues(alpha: 0.12)
                                        : AppColors.textHint.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm),
                                  ),
                                  child: Text(
                                      pkg.isActive ? 'Aktif' : 'Nonaktif',
                                      style: AppTextStyles.caption.copyWith(
                                          color: pkg.isActive
                                              ? AppColors.primary
                                              : AppColors.textHint,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10)),
                                ),
                              ]),
                              const SizedBox(height: 2),
                              Text(
                                  categoryMap[pkg.categoryId] ?? '—',
                                  style: AppTextStyles.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: AppSpacing.xs),
                              Row(children: [
                                _chip(pkg.formattedPrice, AppColors.primary),
                                const SizedBox(width: AppSpacing.xs),
                                _chip(pkg.durationLabel, AppColors.textHint),
                              ]),
                            ]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.error, size: 20),
                        onPressed: () => _confirmDelete(context, pkg),
                      ),
                    ]),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => const AdminPackageFormPage())),
        child: const Icon(Icons.add_rounded, color: AppColors.textOnDark),
      ),
    );
  }

  Widget _imgFallback() => Container(
      color: AppColors.primarySurface,
      child: const Icon(Icons.card_travel_rounded,
          color: AppColors.primary, size: 28));

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(label,
            style: AppTextStyles.caption.copyWith(
                color: color, fontWeight: FontWeight.w600, fontSize: 10)),
      );
}