// lib/presentation/pages/package_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/data/models/package_model.dart';
import 'package:aplikasi_wisata/providers/auth_provider.dart';
import 'package:aplikasi_wisata/providers/review_provider.dart';
import 'package:aplikasi_wisata/widgets/review/review_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/package/package_hero_image.dart';
import '../../widgets/package/package_back_button.dart';
import '../../widgets/package/package_section_label.dart';
import '../../widgets/package/package_tier_selector.dart';
import '../../widgets/package/package_tier_detail.dart';
import '../../widgets/package/package_includes_list.dart';
import '../../widgets/package/package_destination_list.dart';
import '../../widgets/package/package_bottom_bar.dart';

class PackageDetailPage extends StatefulWidget {
  final PackageModel package;
  const PackageDetailPage({super.key, required this.package});

  @override
  State<PackageDetailPage> createState() => _PackageDetailPageState();
}

class _PackageDetailPageState extends State<PackageDetailPage> {
  int _selectedTierIndex = 0;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  late final ReviewProvider _reviewProvider;

  PackageTier? get _selectedTier =>
      widget.package.hasTiers ? widget.package.tiers[_selectedTierIndex] : null;

  @override
  void initState() {
    super.initState();

    final authProvider = context.read<AuthProvider>();
    _reviewProvider = ReviewProvider(currentUser: authProvider.user);

    if (widget.package.hasTiers) {
      final popularIndex = widget.package.tiers.indexWhere((t) => t.isPopular);
      if (popularIndex != -1) _selectedTierIndex = popularIndex;
    }

    _scrollController.addListener(() {
      if (mounted) {
        setState(() => _scrollOffset = _scrollController.offset.clamp(0, 300));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _reviewProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pkg = widget.package;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 100;

    return ChangeNotifierProvider<ReviewProvider>.value(
      value: _reviewProvider,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  PackageHeroImage(pkg: pkg, scrollOffset: _scrollOffset),

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
                              margin: const EdgeInsets.only(
                                top: 14,
                                bottom: 10,
                              ),
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
                                const PackageSectionLabel(
                                  label: 'Tentang Paket',
                                ),
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

                                if (pkg.hasTiers) ...[
                                  const PackageSectionLabel(
                                    label: 'Pilih Paket',
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  PackageTierSelector(
                                    tiers: pkg.tiers,
                                    selectedIndex: _selectedTierIndex,
                                    onSelect:
                                        (i) => setState(
                                          () => _selectedTierIndex = i,
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  if (_selectedTier != null) ...[
                                    PackageTierDetail(tier: _selectedTier!),
                                    const SizedBox(height: AppSpacing.lg),
                                  ],
                                ],

                                if (pkg.includes.isNotEmpty) ...[
                                  const PackageSectionLabel(
                                    label: 'Fasilitas Umum',
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  PackageIncludesList(includes: pkg.includes),
                                  const SizedBox(height: AppSpacing.lg),
                                ],

                                if (pkg.hasDestinations) ...[
                                  const PackageSectionLabel(
                                    label: 'Destinasi dalam Paket',
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  PackageDestinationList(
                                    destinationIds: pkg.destinationIds,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                ],

                                ReviewSection(
                                  target: ReviewTarget.package,
                                  targetId: pkg.id,
                                ),
                                const SizedBox(height: AppSpacing.md),

                                const SizedBox(height: 130),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.sm,
              left: AppSpacing.md,
              child: PackageBackButton(scrollOffset: _scrollOffset),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              bottom: keyboardVisible ? -200 : 0,
              child: PackageBottomBar(
                tier: _selectedTier,
                fallbackPrice: pkg.formattedPrice,
                packageId: pkg.id,
                // FIX: Guest = null → PackageBottomBar handle sendiri
                userId: context.read<AuthProvider>().user?.id,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
