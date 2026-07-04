// lib/presentation/admin/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/core/constants/app_route.dart';
import 'package:aplikasi_wisata/providers/auth_provider.dart';
import 'package:aplikasi_wisata/providers/destination_provider.dart';
import 'package:aplikasi_wisata/providers/accommodation_provider.dart';
import 'package:aplikasi_wisata/providers/package_provider.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';
import 'package:aplikasi_wisata/providers/admin_provider.dart';
import 'package:aplikasi_wisata/providers/place_provider.dart';
import 'category/admin_category_list_page.dart';
import 'destination/admin_destination_list_page.dart';
import 'accommodation/admin_accommodation_list_page.dart';
import 'package/admin_package_list_page.dart';
import 'user/admin_user_list_page.dart';
import 'review/admin_review_page.dart';
import 'favorite/admin_favorite_page.dart';
import 'place/admin_place_list_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _adminInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_adminInitialized) {
      _adminInitialized = true;
      context.read<AdminProvider>().init();
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            title: const Text('Konfirmasi Logout'),
            content: const Text('Yakin ingin keluar dari dashboard admin?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Logout', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AuthProvider>().logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinationCount =
        context.watch<DestinationProvider>().allDestinations.length;
    final categoryCount = context.watch<CategoryProvider>().categories.length;
    final accommodationCount =
        context.watch<AccommodationProvider>().allAccommodations.length;
    final packageCount = context.watch<PackageProvider>().allPackages.length;
    final userCount = context.watch<AdminProvider>().allUsers.length;
    final placeCount = context.watch<PlaceProvider>().allPlaces.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.textOnDark,
                ),
                tooltip: 'Logout',
                onPressed: () => _logout(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Admin',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Wisata Trenggalek',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textOnDark.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatCard(
                          icon: Icons.landscape_rounded,
                          label: 'Destinasi',
                          value: '$destinationCount',
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _StatCard(
                          icon: Icons.hotel_rounded,
                          label: 'Akomodasi',
                          value: '$accommodationCount',
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _StatCard(
                          icon: Icons.card_travel_rounded,
                          label: 'Paket',
                          value: '$packageCount',
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _StatCard(
                          icon: Icons.place_rounded,
                          label: 'Tempat',
                          value: '$placeCount',
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _StatCard(
                          icon: Icons.people_rounded,
                          label: 'Pengguna',
                          value: '$userCount',
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _StatCard(
                          icon: Icons.category_rounded,
                          label: 'Kategori',
                          value: '$categoryCount',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  _SectionHeader('KONTEN WISATA'),
                  _Tile(
                    icon: Icons.landscape_rounded,
                    title: 'Kelola Destinasi',
                    subtitle: 'Lokasi wisata & virtual tour 360°',
                    badge: destinationCount,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminDestinationListPage(),
                          ),
                        ),
                  ),
                  _Tile(
                    icon: Icons.hotel_rounded,
                    title: 'Kelola Akomodasi',
                    subtitle: 'Hotel, villa, penginapan, tipe kamar',
                    badge: accommodationCount,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminAccommodationListPage(),
                          ),
                        ),
                  ),
                  _Tile(
                    icon: Icons.card_travel_rounded,
                    title: 'Kelola Paket Wisata',
                    subtitle: 'Paket tur dengan tier & destinasi pilihan',
                    badge: packageCount,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminPackageListPage(),
                          ),
                        ),
                  ),
                  _Tile(
                    icon: Icons.category_rounded,
                    title: 'Kelola Kategori',
                    subtitle: 'Kategori destinasi, paket, akomodasi',
                    badge: categoryCount,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminCategoryListPage(),
                          ),
                        ),
                  ),

                  const SizedBox(height: AppSpacing.sm),
                  _SectionHeader('FASILITAS PUBLIK'),
                  _Tile(
                    icon: Icons.place_rounded,
                    title: 'Kelola Tempat',
                    subtitle: 'Tempat ibadah & fasilitas kesehatan',
                    badge: placeCount,
                    badgeColor: placeCount > 0 ? const Color(0xFF8B5CF6) : null,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminPlaceListPage(),
                          ),
                        ),
                  ),

                  const SizedBox(height: AppSpacing.sm),
                  _SectionHeader('PENGGUNA'),
                  _Tile(
                    icon: Icons.people_rounded,
                    title: 'Kelola Pengguna',
                    subtitle: 'Daftar user & manajemen favorit',
                    badge: userCount,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminUserListPage(),
                          ),
                        ),
                  ),

                  const SizedBox(height: AppSpacing.sm),
                  _SectionHeader('MODERASI & ANALITIK'),
                  _Tile(
                    icon: Icons.rate_review_rounded,
                    title: 'Moderasi Ulasan',
                    subtitle: 'Pantau & hapus ulasan dari semua konten',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminReviewPage(),
                          ),
                        ),
                  ),
                  _Tile(
                    icon: Icons.favorite_rounded,
                    title: 'Analitik Favorit',
                    subtitle: 'Item paling disukai & log aktivitas',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminFavoritePage(),
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs, left: AppSpacing.xs),
    child: Text(
      text,
      style: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textHint,
        letterSpacing: 1.0,
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 110,
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });

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
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppColors.primary).withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '$badge',
                  style: AppTextStyles.caption.copyWith(
                    color: badgeColor ?? AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}
