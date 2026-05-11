// lib/widgets/accommodation/accommodation_hero_section.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/accommodation_model.dart';
import 'accommodation_price_badge.dart';
import 'accommodation_glass_tour_button.dart';
import 'accommodation_hero_info_overlay.dart';

class AccommodationHeroSection extends StatefulWidget {
  final AccommodationModel item;
  final Future<void> Function(String) onOpenUrl;
  final double scrollOffset;

  const AccommodationHeroSection({
    super.key,
    required this.item,
    required this.onOpenUrl,
    this.scrollOffset = 0,
  });

  @override
  State<AccommodationHeroSection> createState() =>
      _AccommodationHeroSectionState();
}

class _AccommodationHeroSectionState extends State<AccommodationHeroSection> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isDragging = false;

  List<String> get _allImages {
    final main = widget.item.imageUrl;
    final gallery = widget.item.images;
    final result = <String>[];
    if (main.isNotEmpty) result.add(main);
    for (final img in gallery) {
      if (img.isNotEmpty && img != main) result.add(img);
    }
    return result;
  }

  bool get _hasMultiple => _allImages.length > 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _isDragging = true;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0;

    if (velocity < -300) {
      if (_currentPage < _allImages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (velocity > 300) {
      if (_currentPage > 0) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double heroHeight = 420;
    final double parallaxShift = widget.scrollOffset * 0.4;
    final images = _allImages;

    return SizedBox(
      height: heroHeight,
      child: GestureDetector(
        onHorizontalDragStart: _hasMultiple ? _onHorizontalDragStart : null,
        onHorizontalDragEnd: _hasMultiple ? _onHorizontalDragEnd : null,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Carousel / Gambar tunggal
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              child:
                  _hasMultiple
                      ? PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemCount: images.length,
                        itemBuilder:
                            (context, index) => _ParallaxImage(
                              url: images[index],
                              parallaxShift:
                                  index == _currentPage ? parallaxShift : 0,
                              heroHeight: heroHeight,
                            ),
                      )
                      : _ParallaxImage(
                        url: images.isNotEmpty ? images[0] : '',
                        parallaxShift: parallaxShift,
                        heroHeight: heroHeight,
                      ),
            ),

            // ── Gradient overlay
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

            // ── Badge harga (top-right)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.sm,
              right: AppSpacing.md,
              child: AccommodationPriceBadge(item: widget.item),
            ),

            // ── Tombol 360 Virtual Tour (jika tersedia)
            if (widget.item.hasVirtualTour && widget.item.maps360Url != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSpacing.sm + 44,
                right: AppSpacing.md,
                child: AccommodationGlassTourButton(
                  onTap: () => widget.onOpenUrl(widget.item.maps360Url!),
                ),
              ),

            // ── Info overlay (fade saat scroll)
            Positioned(
              left: 0,
              right: 0,
              bottom: _hasMultiple ? 52 : 0,
              child: Opacity(
                opacity: (1.0 - ((widget.scrollOffset - 20) / 100)).clamp(
                  0.0,
                  1.0,
                ),
                child: AccommodationHeroInfoOverlay(item: widget.item),
              ),
            ),

            // ── Dot indicator (tidak ikut fade)
            if (_hasMultiple)
              Positioned(
                left: 0,
                right: 0,
                bottom: 23, // ← naik dari AppSpacing.md
                child: SizedBox(
                  height: 16,
                  child: _DotIndicator(
                    count: images.length,
                    current: _currentPage,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Parallax Image ─────────────────────────────────────────────────────────

class _ParallaxImage extends StatelessWidget {
  final String url;
  final double parallaxShift;
  final double heroHeight;

  const _ParallaxImage({
    required this.url,
    required this.parallaxShift,
    required this.heroHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -parallaxShift),
      child: Transform.scale(
        scale: 1.0 + (parallaxShift / heroHeight).clamp(0, 0.12),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          height: heroHeight + 80,
          errorBuilder:
              (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(
                  child: Icon(
                    Icons.hotel_rounded,
                    size: 64,
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppColors.primaryDark,
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  color: AppColors.textOnDark,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Dot Indicator ──────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _DotIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        );
      }),
    );
  }
}
