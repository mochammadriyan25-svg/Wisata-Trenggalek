// lib/presentation/pages/detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/providers/auth_provider.dart';
import 'package:aplikasi_wisata/providers/favorite_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/destination_model.dart';
import '../../data/services/firestore/destination_service.dart';
import '../../core/utils/auth_guard.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/review/review_section.dart';
import '../../widgets/detail/detail_recommendation_section.dart';
import '../../widgets/detail/accommodation_recommendation_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class DetailPage extends StatefulWidget {
  final DestinationModel destination;
  const DetailPage({super.key, required this.destination});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
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
      widget.destination.id,
    );

    setState(() => _isTogglingFavorite = true);

    try {
      await context.read<FavoriteProvider>().toggleFavorite(
        userId,
        widget.destination.id,
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
                        ? '${widget.destination.name} dihapus dari Favorite'
                        : '${widget.destination.name} ditambahkan ke Favorite!',
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
    final item = widget.destination;
    final isFavorite = context.watch<FavoriteProvider>().isFavorite(item.id);

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
                // ── HERO + INFO OVERLAY (all in one block, no separate card above fold)
                _HeroWithInfoSection(
                  item: item,
                  onOpenUrl: _openUrl,
                  scrollOffset: _scrollOffset,
                ),

                // ── CONTENT CARD — starts with About, nama/rating/lokasi sudah di hero
                _ContentCard(
                  item: item,
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
  final DestinationModel item;
  final Future<void> Function(String) onOpenUrl;
  final double scrollOffset;

  const _HeroWithInfoSection({
    required this.item,
    required this.onOpenUrl,
    this.scrollOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    const double heroHeight = 420;
    // Parallax: gambar bergerak 0.4x lebih lambat dari scroll
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
                // Scale sedikit agar tidak ada gap saat parallax bergerak
                scale: 1.0 + (parallaxShift / heroHeight).clamp(0, 0.12),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  height: heroHeight + 80,
                  errorBuilder:
                      (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.landscape_rounded,
                            size: 64,
                            color: AppColors.textOnDark,
                          ),
                        ),
                      ),
                ),
              ),
            ),
          ),

          // ── GRADIENT OVERLAY — dramatis di bawah (untuk teks), tipis di atas
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.3, 0.55, 0.75, 1.0],
                  colors: [
                    Color(0x33000000), // tipis di atas
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
          if (item.hasVirtualTour && item.maps360Url != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.sm,
              right: AppSpacing.md,
              child: _GlassTourButton(onTap: () => onOpenUrl(item.maps360Url!)),
            ),

          // ── INFO OVERLAY (bottom) — fade out saat di-scroll
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              // Mulai fade setelah scroll 20px, hilang total di 120px
              opacity: (1.0 - ((scrollOffset - 20) / 100)).clamp(0.0, 1.0),
              child: _HeroInfoOverlay(item: item),
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
  final DestinationModel item;
  const _HeroInfoOverlay({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nama destinasi
          Text(
            item.name,
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
                        item.location,
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
              StreamBuilder<DestinationModel?>(
                stream: DestinationService().streamById(item.id),
                builder: (context, snapshot) {
                  final rating = snapshot.data?.rating ?? item.rating;
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
    // 0 = full glass, 60+ = solid surface
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
// CONTENT CARD — mulai langsung dari About
// (Nama, rating, lokasi sudah di hero overlay)
// ─────────────────────────────────────────────

class _ContentCard extends StatelessWidget {
  final DestinationModel item;
  final bool isFavorite;
  final bool isTogglingFavorite;
  final Future<void> Function(String) onOpenUrl;
  final VoidCallback onFavorite;

  const _ContentCard({
    required this.item,
    required this.isFavorite,
    required this.isTogglingFavorite,
    required this.onOpenUrl,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      // Overlap ke atas 22px: menimpa gradient bawah hero → transisi smooth
      // Transform.translate support offset negatif, Container.margin tidak
      offset: const Offset(0, -22),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle — visual cue bahwa card bisa di-scroll
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
                  const _SectionLabel(label: "About Destination"),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    item.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.65,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Map
                  _MapSection(item: item, onOpenUrl: onOpenUrl),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Entrance Fee
                  _EntranceFeeCard(item: item),
                  const SizedBox(height: AppSpacing.lg),

                  Divider(color: AppColors.divider, thickness: 1),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Reviews
                  ReviewSection(destinationId: item.id),

                  Divider(color: AppColors.divider, thickness: 1),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Wisata Terdekat
                  RecommendationSection(
                    currentDestinationId: item.id,
                    currentCategoryId: item.categoryId,
                    currentLatitude: item.latitude,
                    currentLongitude: item.longitude,
                  ),

                  Divider(color: AppColors.divider, thickness: 1),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Akomodasi Terdekat
                  AccommodationRecommendationSection(
                    currentDestinationId: item.id,
                    currentLatitude: item.latitude,
                    currentLongitude: item.longitude,
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
      ), // Container
    ); // Transform.translate
  }
}

// ─────────────────────────────────────────────
// SUB-WIDGETS (tidak berubah dari versi asli,
// kecuali _MapSection dan _ActionButtons)
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

class _MapSection extends StatelessWidget {
  final DestinationModel item;
  final Future<void> Function(String) onOpenUrl;

  const _MapSection({required this.item, required this.onOpenUrl});

  @override
  Widget build(BuildContext context) {
    final lat = item.latitude;
    final lng = item.longitude;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionLabel(label: "Location"),
            GestureDetector(
              onTap: () => onOpenUrl(item.mapsUrl),
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

class _EntranceFeeCard extends StatelessWidget {
  final DestinationModel item;
  const _EntranceFeeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.earthSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.earthLight.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.earth, AppColors.bark],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "Entrance Fee",
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _FeeRow(label: "Adult", amount: item.priceAdult),
          const SizedBox(height: AppSpacing.sm),
          Divider(color: AppColors.earthLight.withOpacity(0.6), thickness: 1),
          const SizedBox(height: AppSpacing.sm),
          _FeeRow(label: "Child", amount: item.priceChild),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final int amount;
  const _FeeRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    final formatted =
        amount == 0
            ? 'Gratis'
            : 'IDR ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              label == 'Adult'
                  ? Icons.person_outline_rounded
                  : Icons.child_care_rounded,
              size: 16,
              color: AppColors.textEarth,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          formatted,
          style: AppTextStyles.headlineSmall.copyWith(
            fontSize: 14,
            color: amount == 0 ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

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
