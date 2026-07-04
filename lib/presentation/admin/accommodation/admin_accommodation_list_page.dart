// lib/presentation/admin/accommodation/admin_accommodation_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/accommodation_model.dart';
import 'package:aplikasi_wisata/providers/accommodation_provider.dart';
import 'package:aplikasi_wisata/data/services/firestore/accommodation_service.dart';
import 'admin_accommodation_form_page.dart';

class AdminAccommodationListPage extends StatefulWidget {
  const AdminAccommodationListPage({super.key});

  @override
  State<AdminAccommodationListPage> createState() =>
      _AdminAccommodationListPageState();
}

class _AdminAccommodationListPageState
    extends State<AdminAccommodationListPage> {
  final _searchController = TextEditingController();
  String _keyword = '';
  final _service = AccommodationService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AccommodationModel> _filter(List<AccommodationModel> source) {
    if (_keyword.isEmpty) return source;
    return source
        .where((a) => a.name.toLowerCase().contains(_keyword))
        .toList();
  }

  Future<void> _confirmDelete(
      BuildContext context, AccommodationModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        title: const Text('Hapus Akomodasi?'),
        content: Text(
            '"${item.name}" beserta seluruh ulasannya akan dihapus permanen.'),
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
        await _service.deleteAccommodation(item.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Akomodasi dihapus')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Gagal: $e'),
              backgroundColor: AppColors.error));
        }
      }
    }
  }

  void _openForm(BuildContext context, {AccommodationModel? existing}) {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (_) => AdminAccommodationFormPage(existing: existing)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccommodationProvider>();
    final list = _filter(provider.allAccommodations);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Akomodasi'),
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
                hintText: 'Cari akomodasi...',
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
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                    borderSide: BorderSide(color: AppColors.divider)),
              ),
            ),
          ),
        ),
      ),
      body: provider.isLoading && provider.allAccommodations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: list.length,
                  itemBuilder: (context, i) => _AccommodationCard(
                    item: list[i],
                    onEdit: () => _openForm(context, existing: list[i]),
                    onDelete: () => _confirmDelete(context, list[i]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add_rounded, color: AppColors.textOnDark),
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
              child: const Icon(Icons.hotel_rounded,
                  size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(_keyword.isNotEmpty ? 'Tidak ada hasil' : 'Belum ada akomodasi',
                style:
                    AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.xs),
            Text(
                _keyword.isNotEmpty
                    ? 'Coba kata kunci lain'
                    : 'Tekan + untuk menambah akomodasi',
                style: AppTextStyles.caption),
          ],
        ),
      );
}

class _AccommodationCard extends StatelessWidget {
  final AccommodationModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AccommodationCard(
      {required this.item, required this.onEdit, required this.onDelete});

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
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: SizedBox(
                  width: 64, height: 64,
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _fallback())
                      : _fallback(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(item.location,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: AppSpacing.xs),
                    Row(children: [
                      _Chip(
                          label: item.formattedStartingPrice,
                          color: AppColors.primary),
                      if (item.hasVirtualTour) ...[
                        const SizedBox(width: AppSpacing.xs),
                        _Chip(label: 'VT', color: AppColors.primary),
                      ],
                      if (item.isRecommended) ...[
                        const SizedBox(width: AppSpacing.xs),
                        _Chip(label: '★ Rekomendasi', color: AppColors.starColor),
                      ],
                    ]),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() => Container(
      color: AppColors.primarySurface,
      child:
          const Icon(Icons.hotel_rounded, color: AppColors.primary, size: 28));
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
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
}