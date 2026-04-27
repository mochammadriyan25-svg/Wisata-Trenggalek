// lib/presentation/widgets/home/home_banner.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  static const List<String> _banners = [
    "assets/1.png",
    "assets/2.png",
  ];

  static const Duration _autoScrollInterval = Duration(seconds: 4);
  static const Duration _animationDuration  = Duration(milliseconds: 450);

  final PageController _pageController =
      PageController(viewportFraction: 0.92);

  int _currentIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _bannerTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (!_pageController.hasClients) return;
      final nextIndex = (_currentIndex + 1) % _banners.length;
      _pageController.animateToPage(
        nextIndex,
        duration: _animationDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BannerPageView(
          banners: _banners,
          controller: _pageController,
          onPageChanged: _onPageChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        _BannerIndicator(
          count: _banners.length,
          currentIndex: _currentIndex,
        ),
      ],
    );
  }
}

class _BannerPageView extends StatelessWidget {
  const _BannerPageView({
    required this.banners,
    required this.controller,
    required this.onPageChanged,
  });

  final List<String>     banners;
  final PageController   controller;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: PageView.builder(
        controller: controller,
        onPageChanged: onPageChanged,
        itemCount: banners.length,
        itemBuilder: (context, index) => _BannerItem(
          imagePath: banners[index],
          isFirst: index == 0,
          isLast:  index == banners.length - 1,
        ),
      ),
    );
  }
}

class _BannerItem extends StatelessWidget {
  const _BannerItem({
    required this.imagePath,
    required this.isFirst,
    required this.isLast,
  });

  final String imagePath;
  final bool   isFirst;
  final bool   isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left:  isFirst ? AppSpacing.md : AppSpacing.sm,
        right: isLast  ? AppSpacing.md : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        // Fallback earthy gradient jika asset belum ada
        gradient: AppColors.primaryGradient,
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDeep.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }
}

// Indicator — teal pill aktif, bulat kecil tidak aktif
class _BannerIndicator extends StatelessWidget {
  const _BannerIndicator({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width:  isActive ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            // Aktif: teal primary | Tidak aktif: divider warm
            color: isActive ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        );
      }),
    );
  }
}