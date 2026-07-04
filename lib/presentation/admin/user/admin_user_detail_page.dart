// lib/presentation/admin/user/admin_user_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/user_model.dart';
import 'package:aplikasi_wisata/data/models/favorite_model.dart';
import 'package:aplikasi_wisata/providers/admin_provider.dart';
import 'package:aplikasi_wisata/providers/auth_provider.dart';
import 'package:aplikasi_wisata/providers/destination_provider.dart';
import 'package:aplikasi_wisata/providers/accommodation_provider.dart';
import 'package:aplikasi_wisata/providers/package_provider.dart';

class AdminUserDetailPage extends StatefulWidget {
  final UserModel user;
  const AdminUserDetailPage({super.key, required this.user});

  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().watchUserFavorites(widget.user.id);
    });
  }

  @override
  void dispose() {
    // Bersihkan listener favorit user setelah halaman ditutup
    context.read<AdminProvider>().clearSelectedUserFavorites();
    super.dispose();
  }

  String _resolveItemName(FavoriteModel fav) {
    final dests = context.read<DestinationProvider>().allDestinations;
    final accoms = context.read<AccommodationProvider>().allAccommodations;
    final pkgs = context.read<PackageProvider>().allPackages;

    return switch (fav.itemType) {
      FavoriteItemType.destination =>
        dests.where((d) => d.id == fav.itemId).firstOrNull?.name ??
            'Destinasi (${fav.itemId.length > 8 ? fav.itemId.substring(0, 8) : fav.itemId}...)',
      FavoriteItemType.accommodation =>
        accoms.where((a) => a.id == fav.itemId).firstOrNull?.name ??
            'Akomodasi (${fav.itemId.length > 8 ? fav.itemId.substring(0, 8) : fav.itemId}...)',
      FavoriteItemType.package =>
        pkgs.where((p) => p.id == fav.itemId).firstOrNull?.name ??
            'Paket (${fav.itemId.length > 8 ? fav.itemId.substring(0, 8) : fav.itemId}...)',
    };
  }

  String? _resolveItemImage(FavoriteModel fav) {
    final dests = context.read<DestinationProvider>().allDestinations;
    final accoms = context.read<AccommodationProvider>().allAccommodations;
    final pkgs = context.read<PackageProvider>().allPackages;

    return switch (fav.itemType) {
      FavoriteItemType.destination =>
        dests.where((d) => d.id == fav.itemId).firstOrNull?.imageUrl,
      FavoriteItemType.accommodation =>
        accoms.where((a) => a.id == fav.itemId).firstOrNull?.imageUrl,
      FavoriteItemType.package =>
        pkgs.where((p) => p.id == fav.itemId).firstOrNull?.imageUrl,
    };
  }

  Future<void> _confirmDeleteFavorite(
      BuildContext context, FavoriteModel fav, String itemName) async {
    final admin = context.read<AdminProvider>();
    final authUser = context.read<AuthProvider>().user;
    if (authUser == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        title: const Text('Hapus Favorit?'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Hapus "$itemName" dari daftar favorit ${widget.user.name}?'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                    'Penghapusan ini akan dicatat di log admin.',
                    style: AppTextStyles.caption),
              ),
            ]),
          ),
        ]),
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
        await admin.adminDeleteFavorite(
          adminUid: authUser.id,
          adminName: authUser.name,
          userId: widget.user.id,
          userName: widget.user.name,
          itemId: fav.itemId,
          itemType: fav.itemType,
          itemName: itemName,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Favorit "$itemName" dihapus dan dicatat di log'),
              behavior: SnackBarBehavior.floating,
            ),
          );
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
    final admin = context.watch<AdminProvider>();
    final favorites = admin.selectedUserFavorites;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Detail: ${widget.user.name}')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ── User Info Card ───────────────────────────────────────
          Card(
            color: AppColors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              side: BorderSide(color: AppColors.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primarySurface,
                  backgroundImage: widget.user.photoUrl.isNotEmpty
                      ? NetworkImage(widget.user.photoUrl)
                      : null,
                  child: widget.user.photoUrl.isEmpty
                      ? Text(
                          widget.user.name.isNotEmpty
                              ? widget.user.name[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.headlineSmall
                              .copyWith(color: AppColors.primary))
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.user.name,
                            style: AppTextStyles.bodyLarge
                                .copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(widget.user.email, style: AppTextStyles.caption),
                        const SizedBox(height: AppSpacing.xs),
                        if (widget.user.isAdmin)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.starColor.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text('Administrator',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.starColor,
                                    fontWeight: FontWeight.w700)),
                          ),
                      ]),
                ),
              ]),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Favorites ────────────────────────────────────────────
          Row(children: [
            Container(width: 3, height: 16,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text('Daftar Favorit',
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: AppColors.primary)),
            ),
            if (favorites.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                child: Text('${favorites.length} item',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
          ]),
          const SizedBox(height: AppSpacing.sm),

          if (admin.userFavoritesLoading)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(),
            ))
          else if (favorites.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.divider),
              ),
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.favorite_border_rounded,
                      size: 36, color: AppColors.textHint),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Belum ada favorit', style: AppTextStyles.caption),
                ]),
              ),
            )
          else
            ...favorites.map((fav) {
              final itemName = _resolveItemName(fav);
              final imageUrl = _resolveItemImage(fav);
              return _FavoriteItem(
                fav: fav,
                itemName: itemName,
                imageUrl: imageUrl,
                onDelete: () =>
                    _confirmDeleteFavorite(context, fav, itemName),
              );
            }),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _FavoriteItem extends StatelessWidget {
  final FavoriteModel fav;
  final String itemName;
  final String? imageUrl;
  final VoidCallback onDelete;

  const _FavoriteItem({
    required this.fav,
    required this.itemName,
    required this.imageUrl,
    required this.onDelete,
  });

  Color get _typeColor => switch (fav.itemType) {
        FavoriteItemType.destination => AppColors.primary,
        FavoriteItemType.accommodation =>
          AppColors.starColor,
        FavoriteItemType.package => AppColors.textHint,
      };

  String get _typeLabel => switch (fav.itemType) {
        FavoriteItemType.destination => 'Destinasi',
        FavoriteItemType.accommodation => 'Akomodasi',
        FavoriteItemType.package => 'Paket',
      };

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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Image.network(imageUrl!,
                  width: 52, height: 52, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback()),
            )
          else
            _fallback(),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(itemName,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(_typeLabel,
                        style: AppTextStyles.caption.copyWith(
                            color: _typeColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10)),
                  ),
                ]),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error, size: 20),
            onPressed: onDelete,
            tooltip: 'Hapus favorit ini',
          ),
        ]),
      ),
    );
  }

  Widget _fallback() => Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(Icons.favorite_rounded, color: _typeColor, size: 24),
      );
}