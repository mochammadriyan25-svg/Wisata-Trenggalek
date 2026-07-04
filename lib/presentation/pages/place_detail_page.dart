// lib/presentation/pages/place_detail_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/core/utils/virtual_tour_guard.dart';
import 'package:aplikasi_wisata/data/models/place_model.dart';
import 'package:aplikasi_wisata/data/models/category_model.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_revisit_screen.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_tour_mode_sheet.dart';
import 'package:aplikasi_wisata/widgets/detail/detail_section_label.dart';
import 'package:aplikasi_wisata/widgets/detail/worship_recommendation_section.dart';
import 'package:aplikasi_wisata/widgets/detail/detail_recommendation_section.dart';
import 'package:aplikasi_wisata/widgets/detail/accommodation_recommendation_section.dart';
import 'place_virtual_tour_page.dart';

class PlaceDetailPage extends StatefulWidget {
  final PlaceModel place;
  const PlaceDetailPage({super.key, required this.place});

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  PlaceModel get _place => widget.place;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (mounted) {
        setState(
          () => _scrollOffset = _scrollController.offset.clamp(0.0, 300.0),
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ── VT ──
  Future<void> _handleTourTap() async {
    if (VirtualTourGuard.isLimitReached) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batas virtual tour sesi ini tercapai.'),
          backgroundColor: AppColors.vtScrimDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (VirtualTourGuard.isDebouncing) return;

    final lat = _place.latitude;
    final lng = _place.longitude;

    if (VirtualTourGuard.hasVisited(lat, lng)) {
      final confirmed = await VtRevisitScreen.show(context, _place.name);
      if (!context.mounted || !confirmed) return;
    }

    final hasExtra = _place.hasPhotoSphere || _place.hasImage360;

    void navigateTo({
      String? panoId,
      String? image360Url,
      double? heading,
      double? pitch,
    }) {
      VirtualTourGuard.markTap();
      VirtualTourGuard.recordLoad(lat, lng);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => PlaceVirtualTourPage(
                name: _place.name,
                latitude: lat,
                longitude: lng,
                panoId: panoId,
                image360Url: image360Url,
                initialHeading: heading ?? _place.streetView.heading,
                initialPitch: pitch ?? _place.streetView.pitch,
              ),
        ),
      );
    }

    if (hasExtra && mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        builder:
            (sheetCtx) => VtTourModeSheet(
              destinationName: _place.name,
              hasStreetView: true,
              hasPhotoSphere: _place.hasPhotoSphere,
              hasImage360: _place.hasImage360,
              onSelectStreetView: () {
                Navigator.pop(sheetCtx);
                navigateTo();
              },
              onSelectPhotoSphere:
                  _place.hasPhotoSphere
                      ? () {
                        Navigator.pop(sheetCtx);
                        navigateTo(panoId: _place.panoId);
                      }
                      : null,
              onSelectImage360:
                  _place.hasImage360
                      ? () {
                        Navigator.pop(sheetCtx);
                        navigateTo(
                          image360Url: _place.image360.url,
                          heading: _place.image360.heading,
                          pitch: _place.image360.pitch,
                        );
                      }
                      : null,
            ),
      );
    } else {
      navigateTo();
    }
  }

  void _navigateToPlace(PlaceModel place) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceDetailPage(place: place)),
    );
  }

  // ✅ NEW: Resolve kategori untuk badge
  CategoryModel? _resolveCategory() {
    if (_place.categoryId == null) return null;
    return context
        .read<CategoryProvider>()
        .categories
        .where((c) => c.id == _place.categoryId)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    const double heroH = 380;
    final parallax = _scrollOffset * 0.4;

    final accent =
        _place.isWorship ? const Color(0xFF8B5CF6) : const Color(0xFF10B981);

    // ✅ NEW: Resolve nama kategori untuk badge
    final category = _resolveCategory();
    final badgeLabel = category?.name ?? _place.placeTypeLabel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: heroH,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(28),
                        ),
                        child: Transform.translate(
                          offset: Offset(0, -parallax),
                          child: Transform.scale(
                            scale: 1.0 + (parallax / heroH).clamp(0, 0.12),
                            child:
                                _place.imageUrl.isNotEmpty
                                    ? Image.network(
                                      _place.imageUrl,
                                      fit: BoxFit.cover,
                                      height: heroH + 80,
                                      errorBuilder:
                                          (_, __, ___) => _heroFallback(accent),
                                    )
                                    : _heroFallback(accent),
                          ),
                        ),
                      ),
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
                      if (_place.hasVirtualTour)
                        Positioned(
                          top:
                              MediaQuery.of(context).padding.top +
                              AppSpacing.sm,
                          right: AppSpacing.md,
                          child: _VtBadge(
                            hasExtra:
                                _place.hasPhotoSphere || _place.hasImage360,
                            onTap: _handleTourTap,
                          ),
                        ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Opacity(
                          opacity: (1.0 - ((_scrollOffset - 20) / 100)).clamp(
                            0.0,
                            1.0,
                          ),
                          child: _PlaceHeroOverlay(
                            place: _place,
                            accent: accent,
                            badgeLabel: badgeLabel,
                          ), // ✅ NEW
                        ),
                      ),
                    ],
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -22),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              const DetailSectionLabel(label: 'Tentang Tempat'),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                _place.description.isNotEmpty
                                    ? _place.description
                                    : 'Informasi belum tersedia.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.65,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              _PlaceMapSection(
                                place: _place,
                                onOpenUrl: _openUrl,
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              if (_place.isWorship) ...[
                                Divider(color: AppColors.divider, thickness: 1),
                                const SizedBox(height: AppSpacing.lg),
                                WorshipRecommendationSection(
                                  currentLatitude: _place.latitude,
                                  currentLongitude: _place.longitude,
                                  excludePlaceId: _place.id,
                                  onPlaceTap: _navigateToPlace,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Divider(color: AppColors.divider, thickness: 1),
                                const SizedBox(height: AppSpacing.lg),
                                HealthRecommendationSection(
                                  currentLatitude: _place.latitude,
                                  currentLongitude: _place.longitude,
                                  onPlaceTap: _navigateToPlace,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Divider(color: AppColors.divider, thickness: 1),
                                const SizedBox(height: AppSpacing.lg),
                                RecommendationSection(
                                  currentDestinationId: '',
                                  currentLatitude: _place.latitude,
                                  currentLongitude: _place.longitude,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Divider(color: AppColors.divider, thickness: 1),
                                const SizedBox(height: AppSpacing.lg),
                                AccommodationRecommendationSection(
                                  currentLatitude: _place.latitude,
                                  currentLongitude: _place.longitude,
                                ),
                              ] else ...[
                                Divider(color: AppColors.divider, thickness: 1),
                                const SizedBox(height: AppSpacing.lg),
                                HealthRecommendationSection(
                                  currentLatitude: _place.latitude,
                                  currentLongitude: _place.longitude,
                                  excludePlaceId: _place.id,
                                  onPlaceTap: _navigateToPlace,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Divider(color: AppColors.divider, thickness: 1),
                                const SizedBox(height: AppSpacing.lg),
                                WorshipRecommendationSection(
                                  currentLatitude: _place.latitude,
                                  currentLongitude: _place.longitude,
                                  onPlaceTap: _navigateToPlace,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Divider(color: AppColors.divider, thickness: 1),
                                const SizedBox(height: AppSpacing.lg),
                                AccommodationRecommendationSection(
                                  currentLatitude: _place.latitude,
                                  currentLongitude: _place.longitude,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Divider(color: AppColors.divider, thickness: 1),
                                const SizedBox(height: AppSpacing.lg),
                                RecommendationSection(
                                  currentDestinationId: '',
                                  currentLatitude: _place.latitude,
                                  currentLongitude: _place.longitude,
                                ),
                              ],
                              const SizedBox(height: AppSpacing.xl),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: (MediaQuery.of(context).padding.bottom +
                          AppSpacing.md -
                          22)
                      .clamp(0.0, double.infinity),
                ),
              ],
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: AppSpacing.md,
            child: _PlaceBackButton(scrollOffset: _scrollOffset),
          ),
        ],
      ),
    );
  }

  Widget _heroFallback(Color accent) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [accent.withValues(alpha: 0.7), accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Icon(
        _place.isWorship ? Icons.place_rounded : Icons.local_hospital_rounded,
        size: 72,
        color: AppColors.textOnDark,
      ),
    ),
  );
}

// ── _PlaceHeroOverlay ──
class _PlaceHeroOverlay extends StatelessWidget {
  final PlaceModel place;
  final Color accent;
  final String badgeLabel; // ✅ NEW

  const _PlaceHeroOverlay({
    required this.place,
    required this.accent,
    required this.badgeLabel, // ✅ NEW
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ FIX: Gunakan badgeLabel alih-alih place.subType
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            badgeLabel,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          place.name,
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: 24,
            color: AppColors.textOnDark,
            fontWeight: FontWeight.w800,
            height: 1.2,
            shadows: const [
              Shadow(
                color: Color(0x55000000),
                blurRadius: 16,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 13,
              color: AppColors.textOnDark.withValues(alpha: 0.85),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                place.location,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textOnDark.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ── _VtBadge ──
class _VtBadge extends StatelessWidget {
  final bool hasExtra;
  final VoidCallback onTap;
  const _VtBadge({required this.hasExtra, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.vtTourBadgeFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.vtTourBadgeBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.view_in_ar_rounded,
                size: 15,
                color: AppColors.textOnDark,
              ),
              const SizedBox(width: 6),
              Text(
                '360° Tour',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textOnDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.4,
                ),
              ),
              if (hasExtra) ...[
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.vtPhotoSphereAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

// ── _PlaceBackButton ──
class _PlaceBackButton extends StatelessWidget {
  final double scrollOffset;
  const _PlaceBackButton({this.scrollOffset = 0});

  @override
  Widget build(BuildContext context) {
    final ratio = (scrollOffset / 60).clamp(0.0, 1.0);
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Color.lerp(
            Colors.white.withValues(alpha: 0.18),
            AppColors.surface.withValues(alpha: 0.96),
            ratio,
          ),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color:
                Color.lerp(
                  Colors.white.withValues(alpha: 0.28),
                  AppColors.divider,
                  ratio,
                )!,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 14,
          color: Color.lerp(Colors.white, AppColors.textPrimary, ratio),
        ),
      ),
    );
  }
}

// ── _PlaceMapSection ──
class _PlaceMapSection extends StatelessWidget {
  final PlaceModel place;
  final Future<void> Function(String) onOpenUrl;

  const _PlaceMapSection({required this.place, required this.onOpenUrl});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const DetailSectionLabel(label: 'Lokasi'),
          GestureDetector(
            onTap: () => onOpenUrl(place.mapsUrl),
            child: Row(
              children: [
                Text(
                  'Dapatkan Arah',
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
              initialCenter: LatLng(place.latitude, place.longitude),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.aplikasi_wisata.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(place.latitude, place.longitude),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
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
