// lib/presentation/pages/accommodation_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/auth_guard.dart';
import '../../data/models/accommodation_model.dart';
import '../../data/models/favorite_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/accommodation/accommodation_hero_section.dart';
import '../../widgets/accommodation/accommodation_glass_back_button.dart';
import '../../widgets/accommodation/accommodation_content_card.dart';

class AccommodationDetailPage extends StatefulWidget {
  final AccommodationModel accommodation;

  const AccommodationDetailPage({super.key, required this.accommodation});

  @override
  State<AccommodationDetailPage> createState() =>
      _AccommodationDetailPageState();
}

class _AccommodationDetailPageState extends State<AccommodationDetailPage> {
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

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

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
      widget.accommodation.id,
      FavoriteItemType.accommodation,
    );

    setState(() => _isTogglingFavorite = true);

    try {
      // [CHANGED] Tambah userName agar log admin mencatat nama pengguna.
      await context.read<FavoriteProvider>().toggleFavorite(
        userId,
        widget.accommodation.id,
        FavoriteItemType.accommodation,
        userName: context.read<AuthProvider>().user?.name ?? '',
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
                        ? '${widget.accommodation.name} dihapus dari Favorite'
                        : '${widget.accommodation.name} ditambahkan ke Favorite!',
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

  @override
  Widget build(BuildContext context) {
    final item = widget.accommodation;

    final isFavorite = context.watch<FavoriteProvider>().isFavorite(
      item.id,
      FavoriteItemType.accommodation,
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
          ScrollConfiguration(
            behavior: _VerticalOnlyScrollBehavior(),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  AccommodationHeroSection(
                    item: item,
                    onOpenUrl: _openUrl,
                    scrollOffset: _scrollOffset,
                  ),
                  AccommodationContentCard(
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
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: AppSpacing.md,
            child: AccommodationGlassBackButton(scrollOffset: _scrollOffset),
          ),
        ],
      ),
    );
  }
}

class _VerticalOnlyScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics();
}
