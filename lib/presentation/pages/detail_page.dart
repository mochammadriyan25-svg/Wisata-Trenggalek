// lib/presentation/pages/detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/core/utils/auth_guard.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';
import 'package:aplikasi_wisata/data/models/favorite_model.dart';
import 'package:aplikasi_wisata/providers/auth_provider.dart';
import 'package:aplikasi_wisata/providers/favorite_provider.dart';
import 'package:aplikasi_wisata/widgets/detail/detail_hero_section.dart';
import 'package:aplikasi_wisata/widgets/detail/detail_back_button.dart';
import 'package:aplikasi_wisata/widgets/detail/detail_content_card.dart';

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
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted) return;
    final newOffset = _scrollController.offset.clamp(0.0, 300.0);
    if (newOffset != _scrollOffset) {
      setState(() => _scrollOffset = newOffset);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
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
      FavoriteItemType.destination,
    );

    setState(() => _isTogglingFavorite = true);

    try {
      // [CHANGED] Tambah userName agar log admin bisa menampilkan
      // nama pengguna yang menghapus favorit.
      await context.read<FavoriteProvider>().toggleFavorite(
        userId,
        widget.destination.id,
        FavoriteItemType.destination,
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isFavorite = context.watch<FavoriteProvider>().isFavorite(
      item.id,
      FavoriteItemType.destination,
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
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              decelerationRate: ScrollDecelerationRate.fast,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DetailHeroSection(
                  item: item,
                  onOpenUrl: _openUrl,
                  scrollOffset: _scrollOffset,
                ),
                Transform.translate(
                  offset: const Offset(0, -22),
                  child: DetailContentCard(
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
                ),
                SizedBox(
                  height: (bottomPadding + AppSpacing.md - 22).clamp(
                    0.0,
                    double.infinity,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: AppSpacing.md,
            child: DetailGlassBackButton(scrollOffset: _scrollOffset),
          ),
        ],
      ),
    );
  }
}
