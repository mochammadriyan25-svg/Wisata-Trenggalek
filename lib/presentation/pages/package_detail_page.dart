// lib/presentation/pages/package_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:aplikasi_wisata/data/models/package_model.dart';
import 'package:aplikasi_wisata/data/services/firestore/package_service.dart';
import 'package:aplikasi_wisata/providers/auth_provider.dart';
import 'package:aplikasi_wisata/providers/favorite_provider.dart';
import 'package:aplikasi_wisata/widgets/review/review_section.dart';
import 'package:aplikasi_wisata/data/services/firestore/review_service.dart';
import 'package:aplikasi_wisata/core/utils/auth_guard.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/detail/detail_recommendation_section.dart';
import '../../widgets/detail/accommodation_recommendation_section.dart';
import '../../data/models/favorite_model.dart';

class PackageDetailPage extends StatefulWidget {
  final PackageModel package;
  const PackageDetailPage({super.key, required this.package});

  @override
  State<PackageDetailPage> createState() => _PackageDetailPageState();
}

class _PackageDetailPageState extends State<PackageDetailPage> {
  bool _isTogglingFavorite = false;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (mounted) {
        setState(() => _scrollOffset = _scrollController.offset.clamp(0, 300));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String? get _userId => context.read<AuthProvider>().userId;

  Future<void> _toggleFavorite() async {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'User ID tidak ditemukan. Silakan login ulang.',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
      return;
    }

    if (_isTogglingFavorite) return;

    final wasFavorite = context.read<FavoriteProvider>().isFavorite(
      widget.package.id,
      FavoriteItemType.package,
    );

    setState(() => _isTogglingFavorite = true);

    try {
      await context.read<FavoriteProvider>().toggleFavorite(
        userId,
        widget.package.id,
        FavoriteItemType.package,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  wasFavorite ? Icons.favorite_border : Icons.favorite,
                  color: AppColors.textOnDark,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    wasFavorite
                        ? '${widget.package.name} dihapus dari Favorite'
                        : '${widget.package.name} ditambahkan ke Favorite!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor:
                wasFavorite ? AppColors.textSecondary : AppColors.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingFavorite = false);
    }
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final pkg = widget.package;
    final isFavorite = context.watch<FavoriteProvider>().isFavorite(
      pkg.id,
      FavoriteItemType.package,
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── SCROLLABLE CONTENT
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ── HERO + INFO OVERLAY
                _HeroWithInfoSection(
                  pkg: pkg,
                  onOpenUrl: _openUrl,
                  scrollOffset: _scrollOffset,
                ),

                // ── CONTENT CARD
                _ContentCard(
                  pkg: pkg,
                  isFavorite: isFavorite,
                  isTogglingFavorite: _isTogglingFavorite,
                  onOpenUrl: _openUrl,
                  onFavorite:
                      () => AuthGuard.checkAndRun(
                        context: context,
                        action: _toggleFavorite,
                        redirectBackRoute: '/home_screen',
                      ),
                ),
              ],
            ),
          ),

          // ── BACK BUTTON (floating, glassmorphism → solid saat scroll)
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: AppSpacing.md,
            child: _GlassBackButton(scrollOffset: _scrollOffset),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HERO WITH INFO OVERLAY
// ─────────────────────────────────────────────

class _HeroWithInfoSection extends StatelessWidget {
  final PackageModel pkg;
  final Future<void> Function(String) onOpenUrl;
  final double scrollOffset;

  const _HeroWithInfoSection({
    required this.pkg,
    required this.onOpenUrl,
    this.scrollOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    const double heroHeight = 420;
    final double parallaxShift = scrollOffset * 0.4;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── GAMBAR dengan parallax transform
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
            child: Transform.translate(
              offset: Offset(0, -parallaxShift),
              child: Transform.scale(
                scale: 1.0 + (parallaxShift / heroHeight).clamp(0, 0.12),
                child: Image.network(
                  pkg.imageUrl,
                  fit: BoxFit.cover,
                  height: heroHeight + 80,
                  errorBuilder:
                      (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.card_travel_rounded,
                            size: 64,
                            color: AppColors.textOnDark,
                          ),
                        ),
                      ),
                ),
              ),
            ),
          ),

          // ── GRADIENT OVERLAY
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.3, 0.55, 0.75, 1.0],
                  colors: [
                    Color(0x33000000),
                    Color(0x08000000),
                    Color(0x55051914),
                    Color(0xCC051410),
                    Color(0xF5040E0C),
                  ],
                ),
              ),
            ),
          ),

          // ── VIRTUAL TOUR BUTTON (top-right)
          if (pkg.hasVirtualTour && pkg.maps360Url != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.sm,
              right: AppSpacing.md,
              child: _GlassTourButton(onTap: () => onOpenUrl(pkg.maps360Url!)),
            ),

          // ── INFO OVERLAY (bottom) — fade out saat di-scroll
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: (1.0 - ((scrollOffset - 20) / 100)).clamp(0.0, 1.0),
              child: _HeroInfoOverlay(pkg: pkg),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassTourButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GlassTourButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.view_in_ar_rounded, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              '360° Tour',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroInfoOverlay extends StatelessWidget {
  final PackageModel pkg;
  const _HeroInfoOverlay({required this.pkg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nama paket
          Text(
            pkg.name,
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.15,
              shadows: [
                const Shadow(
                  color: Color(0x55000000),
                  blurRadius: 16,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Baris bawah: lokasi + rating
          Row(
            children: [
              // Lokasi
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        pkg.location,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Rating badge (realtime)
              StreamBuilder<PackageModel?>(
                stream: PackageService().streamById(pkg.id),
                builder: (context, snapshot) {
                  final rating = snapshot.data?.rating ?? pkg.rating;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Color(0xFFFFD166),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GLASS BACK BUTTON
// ─────────────────────────────────────────────

class _GlassBackButton extends StatelessWidget {
  final double scrollOffset;
  const _GlassBackButton({this.scrollOffset = 0});

  @override
  Widget build(BuildContext context) {
    final double solidRatio = (scrollOffset / 60).clamp(0.0, 1.0);
    final Color bgGlass = Colors.white.withOpacity(0.18);
    final Color bgSolid = AppColors.surface.withOpacity(0.96);
    final Color iconGlass = Colors.white;
    final Color iconSolid = AppColors.textPrimary;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Color.lerp(bgGlass, bgSolid, solidRatio),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color:
                Color.lerp(
                  Colors.white.withOpacity(0.28),
                  AppColors.divider,
                  solidRatio,
                )!,
            width: 1,
          ),
          boxShadow:
              solidRatio > 0.5
                  ? [
                    BoxShadow(
                      color: AppColors.shadowDeep.withOpacity(
                        0.12 * solidRatio,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : [],
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 14,
          color: Color.lerp(iconGlass, iconSolid, solidRatio),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CONTENT CARD
// ─────────────────────────────────────────────

class _ContentCard extends StatelessWidget {
  final PackageModel pkg;
  final bool isFavorite;
  final bool isTogglingFavorite;
  final Future<void> Function(String) onOpenUrl;
  final VoidCallback onFavorite;

  const _ContentCard({
    required this.pkg,
    required this.isFavorite,
    required this.isTogglingFavorite,
    required this.onOpenUrl,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -22),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 14, bottom: 10),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── About
                  const _SectionLabel(label: "Tentang Paket"),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    pkg.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.65,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Galeri
                  if (pkg.hasGallery) ...[
                    const _SectionLabel(label: "Galeri"),
                    const SizedBox(height: AppSpacing.sm),
                    _GalleryRow(images: pkg.images),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // ── Map
                  _MapSection(pkg: pkg, onOpenUrl: onOpenUrl),
                  const SizedBox(height: AppSpacing.lg),

                  Divider(color: AppColors.divider, thickness: 1),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Reviews
                  ReviewSection(target: ReviewTarget.package, targetId: pkg.id),

                  Divider(color: AppColors.divider, thickness: 1),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Rekomendasi Paket
                  RecommendationSection(
                    currentDestinationId: pkg.id,
                    currentCategoryId: pkg.categoryId,
                    currentLatitude: pkg.latitude,
                    currentLongitude: pkg.longitude,
                  ),

                  Divider(color: AppColors.divider, thickness: 1),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Akomodasi Terdekat
                  AccommodationRecommendationSection(
                    currentDestinationId: pkg.id,
                    currentLatitude: pkg.latitude,
                    currentLongitude: pkg.longitude,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Action buttons
                  _ActionButtons(
                    isFavorite: isFavorite,
                    isLoading: isTogglingFavorite,
                    onFavorite: onFavorite,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// MAP SECTION
// ─────────────────────────────────────────────

class _MapSection extends StatelessWidget {
  final PackageModel pkg;
  final Future<void> Function(String) onOpenUrl;

  const _MapSection({required this.pkg, required this.onOpenUrl});

  @override
  Widget build(BuildContext context) {
    final lat = pkg.latitude;
    final lng = pkg.longitude;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionLabel(label: "Lokasi"),
            GestureDetector(
              onTap: () => onOpenUrl(pkg.mapsUrl),
              child: Row(
                children: [
                  Text(
                    "Get Directions",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, lng),
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.aplikasi_wisata.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: LatLng(lat, lng),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.textOnDark,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// GALLERY ROW
// ─────────────────────────────────────────────

class _GalleryRow extends StatelessWidget {
  final List<String> images;
  const _GalleryRow({required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder:
            (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Image.network(
                images[i],
                width: 130,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      width: 130,
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(
                        Icons.image_not_supported_rounded,
                        color: AppColors.textOnDark,
                      ),
                    ),
              ),
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ACTION BUTTONS (Favorite + Share)
// ─────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback onFavorite;

  const _ActionButtons({
    required this.isFavorite,
    required this.isLoading,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: isLoading ? null : onFavorite,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 52,
              decoration: BoxDecoration(
                gradient: isFavorite ? null : AppColors.primaryGradient,
                color: isFavorite ? AppColors.primarySurface : null,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border:
                    isFavorite
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                boxShadow:
                    isFavorite
                        ? []
                        : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
              ),
              child: Center(
                child:
                    isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                isFavorite
                                    ? AppColors.primary
                                    : AppColors.textOnDark,
                          ),
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color:
                                  isFavorite
                                      ? AppColors.primary
                                      : AppColors.textOnDark,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              isFavorite
                                  ? "Saved to Favorites"
                                  : "Add to Favorites",
                              style: AppTextStyles.buttonLabel.copyWith(
                                fontSize: 14,
                                color:
                                    isFavorite
                                        ? AppColors.primary
                                        : AppColors.textOnDark,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: AppColors.earthSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.earthLight, width: 1.2),
          ),
          child: const Icon(
            Icons.share_rounded,
            color: AppColors.bark,
            size: 20,
          ),
        ),
      ],
    );
  }
}
