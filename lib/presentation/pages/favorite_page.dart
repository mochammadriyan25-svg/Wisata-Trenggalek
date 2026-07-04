// lib/presentation/pages/favorite_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/favorite_model.dart';
import '../../data/models/destination_model.dart';
import '../../data/models/accommodation_model.dart';
import '../../data/models/package_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import 'detail_page.dart';
import 'accommodation_detail_page.dart';
import 'package_detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

enum _FavoriteTab { all, destination, accommodation, package }

class _FavoritePageState extends State<FavoritePage> {
  _FavoriteTab _selectedTab = _FavoriteTab.all;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _FavoriteHeader(),
            const SizedBox(height: AppSpacing.sm),
            _FilterTabRow(
              selected: _selectedTab,
              onSelect: (tab) => setState(() => _selectedTab = tab),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: _buildContent(authProvider, favoriteProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    AuthProvider authProvider,
    FavoriteProvider favoriteProvider,
  ) {
    if (authProvider.isGuest) return _GuestPrompt();
    if (favoriteProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      );
    }
    switch (_selectedTab) {
      case _FavoriteTab.all:
        return _buildAllList(favoriteProvider, authProvider.userId!);
      case _FavoriteTab.destination:
        return _buildDestinationList(favoriteProvider, authProvider.userId!);
      case _FavoriteTab.accommodation:
        return _buildAccommodationList(favoriteProvider, authProvider.userId!);
      case _FavoriteTab.package:
        return _buildPackageList(favoriteProvider, authProvider.userId!);
    }
  }

  Widget _buildAllList(FavoriteProvider prov, String userId) {
    final destinations = prov.favoriteDestinations;
    final accommodations = prov.favoriteAccommodations;
    final packages = prov.favoritePackages;
    final totalCount =
        destinations.length + accommodations.length + packages.length;

    if (totalCount == 0) return _EmptyState(tab: _FavoriteTab.all);

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        if (destinations.isNotEmpty) ...[
          _SectionLabel(label: 'Destinasi', count: destinations.length),
          ...destinations.map(
            (item) => _DestinationCard(item: item, userId: userId),
          ),
        ],
        if (accommodations.isNotEmpty) ...[
          _SectionLabel(label: 'Akomodasi', count: accommodations.length),
          ...accommodations.map(
            (item) => _AccommodationCard(item: item, userId: userId),
          ),
        ],
        if (packages.isNotEmpty) ...[
          _SectionLabel(label: 'Paket Wisata', count: packages.length),
          ...packages.map((item) => _PackageCard(item: item, userId: userId)),
        ],
      ],
    );
  }

  Widget _buildDestinationList(FavoriteProvider prov, String userId) {
    final items = prov.favoriteDestinations;
    if (items.isEmpty) return _EmptyState(tab: _FavoriteTab.destination);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, i) => _DestinationCard(item: items[i], userId: userId),
    );
  }

  Widget _buildAccommodationList(FavoriteProvider prov, String userId) {
    final items = prov.favoriteAccommodations;
    if (items.isEmpty) return _EmptyState(tab: _FavoriteTab.accommodation);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, i) => _AccommodationCard(item: items[i], userId: userId),
    );
  }

  Widget _buildPackageList(FavoriteProvider prov, String userId) {
    final items = prov.favoritePackages;
    if (items.isEmpty) return _EmptyState(tab: _FavoriteTab.package);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, i) => _PackageCard(item: items[i], userId: userId),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _FavoriteHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNeutral.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.textOnDark,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Text(
            'Favorit Saya',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Tabs ───────────────────────────────────────────────────────────────

class _FilterTabRow extends StatelessWidget {
  final _FavoriteTab selected;
  final ValueChanged<_FavoriteTab> onSelect;

  const _FilterTabRow({required this.selected, required this.onSelect});

  static const _tabs = [
    (_FavoriteTab.all, 'All'),
    (_FavoriteTab.destination, 'Destinasi'),
    (_FavoriteTab.accommodation, 'Akomodasi'),
    (_FavoriteTab.package, 'Paket Wisata'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              _tabs
                  .map(
                    (t) => _FilterChip(
                      label: t.$2,
                      isSelected: selected == t.$1,
                      onTap: () => onSelect(t.$1),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1.2,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : [],
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.textOnDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;
  const _SectionLabel({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xs + 2,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.headlineSmall.copyWith(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Base Card ─────────────────────────────────────────────────────────────────

class _BaseCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String subtitle;
  final double rating;
  final String categoryId;
  final String badgeLabel;
  final String priceLabel;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _BaseCard({
    required this.imageUrl,
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.categoryId,
    required this.badgeLabel,
    required this.priceLabel,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowNeutral.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Image.network(
                imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(
                        Icons.landscape_rounded,
                        color: AppColors.textOnDark,
                        size: 28,
                      ),
                    ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F0),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.redAccent,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentSurface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                          border: Border.all(
                            color: AppColors.accentLight.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 11,
                              color: Color(0xFFE8A020),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              rating.toStringAsFixed(1),
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                        ),
                        child: Text(
                          badgeLabel,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        priceLabel,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
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
}

// ── Specific Cards ────────────────────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  final DestinationModel item;
  final String userId;
  const _DestinationCard({required this.item, required this.userId});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      imageUrl: item.imageUrl,
      name: item.name,
      subtitle: item.location,
      rating: item.rating,
      categoryId: item.categoryId,
      badgeLabel: 'Destinasi',
      priceLabel: item.priceRangeFormatted,
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailPage(destination: item)),
          ),
      // [CHANGED] Tambah userName agar log admin mencatat nama pengguna
      onRemove:
          () => context.read<FavoriteProvider>().toggleFavorite(
            userId,
            item.id,
            FavoriteItemType.destination,
            userName: context.read<AuthProvider>().user?.name ?? '',
          ),
    );
  }
}

class _AccommodationCard extends StatelessWidget {
  final AccommodationModel item;
  final String userId;
  const _AccommodationCard({required this.item, required this.userId});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      imageUrl: item.imageUrl,
      name: item.name,
      subtitle: item.location,
      rating: item.rating,
      categoryId: item.categoryId,
      badgeLabel: 'Akomodasi',
      priceLabel: item.formattedPricePerNight,
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AccommodationDetailPage(accommodation: item),
            ),
          ),
      // [CHANGED] Tambah userName
      onRemove:
          () => context.read<FavoriteProvider>().toggleFavorite(
            userId,
            item.id,
            FavoriteItemType.accommodation,
            userName: context.read<AuthProvider>().user?.name ?? '',
          ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PackageModel item;
  final String userId;
  const _PackageCard({required this.item, required this.userId});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      imageUrl: item.imageUrl,
      name: item.name,
      subtitle: item.durationLabel,
      rating: item.rating,
      categoryId: item.categoryId,
      badgeLabel: 'Paket Wisata',
      priceLabel: item.formattedPrice,
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PackageDetailPage(package: item)),
          ),
      // [CHANGED] Tambah userName
      onRemove:
          () => context.read<FavoriteProvider>().toggleFavorite(
            userId,
            item.id,
            FavoriteItemType.package,
            userName: context.read<AuthProvider>().user?.name ?? '',
          ),
    );
  }
}

// ── Empty & Guest State ───────────────────────────────────────────────────────

class _GuestPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Login untuk melihat favorit kamu',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Simpan destinasi favoritmu\ndan akses kapan saja',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final _FavoriteTab tab;
  const _EmptyState({required this.tab});

  String get _message {
    switch (tab) {
      case _FavoriteTab.all:
        return 'Belum ada favorit apapun';
      case _FavoriteTab.destination:
        return 'Belum ada destinasi favorit';
      case _FavoriteTab.accommodation:
        return 'Belum ada akomodasi favorit';
      case _FavoriteTab.package:
        return 'Belum ada paket wisata favorit';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.earthSurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.earthLight.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 32,
              color: AppColors.earth,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            'Jelajahi dan simpan yang kamu suka!',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
