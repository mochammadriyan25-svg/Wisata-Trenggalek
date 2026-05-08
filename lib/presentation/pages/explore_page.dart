// lib/presentation/pages/explore_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/auth_guard.dart';
import '../../providers/destination_provider.dart';
import '../../providers/accommodation_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/explore/explore_widget.dart';
import 'detail_page.dart';
import 'package:aplikasi_wisata/presentation/pages/accommodation_detail_page.dart';
import 'package:aplikasi_wisata/presentation/pages/package_detail_page.dart';
import '../../providers/package_provider.dart';

// ── ENUM tetap ada agar tidak merusak navigasi dari halaman lain
enum ExploreMode { destination, accommodation, package }

class ExplorePage extends StatefulWidget {
  final String initialCategoryId;
  final bool showBackButton;
  final String initialSearch;
  final ExploreMode initialMode;

  const ExplorePage({
    super.key,
    this.initialCategoryId = '',
    this.showBackButton = false,
    this.initialSearch = '',
    this.initialMode = ExploreMode.destination,
  });

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

// ✅ Ganti bool _isAccommodationMode dengan enum _activeMode
enum _ExploreTab { destination, accommodation, package }

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  _ExploreTab _activeTab = _ExploreTab.destination; // ✅

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late DestinationProvider _destProvider;
  late AccommodationProvider _accomProvider;
  late PackageProvider _packageProvider; // ✅
  bool _providersInitialized = false;

  @override
  void initState() {
    super.initState();

    // ✅ Sesuaikan init mode
    switch (widget.initialMode) {
      case ExploreMode.accommodation:
        _activeTab = _ExploreTab.accommodation;
        break;
      case ExploreMode.package:
        _activeTab = _ExploreTab.package;
        break;
      default:
        _activeTab = _ExploreTab.destination;
    }

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_providersInitialized) {
      _destProvider = context.read<DestinationProvider>();
      _accomProvider = context.read<AccommodationProvider>();
      _packageProvider = context.read<PackageProvider>(); // ✅
      _providersInitialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (widget.initialCategoryId.isNotEmpty) {
          _destProvider.filterByCategory(widget.initialCategoryId);
        }

        if (widget.initialSearch.isNotEmpty) {
          _searchController.text = widget.initialSearch;
          _destProvider.search(widget.initialSearch);
          _accomProvider.search(widget.initialSearch);
          _packageProvider.search(widget.initialSearch); // ✅
        }
      });
    }
  }

  @override
  void dispose() {
    _destProvider.clearFilter();
    _accomProvider.clearFilter();
    _packageProvider.clearFilter(); // ✅
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final keyword = _searchController.text;
    _destProvider.search(keyword);
    _accomProvider.search(keyword);
    _packageProvider.search(keyword); // ✅
  }

  void _switchTab(_ExploreTab tab, {String categoryId = ''}) {
    final isSameTab = _activeTab == tab;
    final isSameCategory =
        tab == _ExploreTab.destination &&
        _destProvider.selectedCategoryId == categoryId;

    if (isSameTab && isSameCategory) return;

    _fadeController.reset();
    setState(() => _activeTab = tab);
    _fadeController.forward();
    _searchController.clear();

    _destProvider.clearFilter();
    _accomProvider.clearFilter();
    _packageProvider.clearFilter();

    if (tab == _ExploreTab.destination && categoryId.isNotEmpty) {
      _destProvider.filterByCategory(categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final destProvider = context.watch<DestinationProvider>();
    final accomProvider = context.watch<AccommodationProvider>();
    final packageProvider = context.watch<PackageProvider>(); // ✅
    final catProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              context,
              destProvider,
              accomProvider,
              packageProvider, // ✅
              catProvider,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: switch (_activeTab) {
                  _ExploreTab.destination => _buildDestinationList(
                    context,
                    destProvider,
                  ),
                  _ExploreTab.accommodation => _buildAccommodationList(
                    context,
                    accomProvider,
                  ),
                  _ExploreTab.package => _buildPackageList(
                    context,
                    packageProvider,
                  ), // ✅
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER
  Widget _buildHeader(
    BuildContext context,
    DestinationProvider destProvider,
    AccommodationProvider accomProvider,
    PackageProvider packageProvider, // ✅
    CategoryProvider catProvider,
  ) {
    // ✅ Hitung total sesuai tab aktif
    final totalCount = switch (_activeTab) {
      _ExploreTab.destination => destProvider.filteredDestinations.length,
      _ExploreTab.accommodation => accomProvider.filteredAccommodations.length,
      _ExploreTab.package => packageProvider.filteredPackages.length,
    };

    final isLoading = switch (_activeTab) {
      _ExploreTab.destination => destProvider.isLoading,
      _ExploreTab.accommodation => accomProvider.isLoading,
      _ExploreTab.package => packageProvider.isLoading,
    };

    // ✅ Hint search sesuai tab
    final searchHint = switch (_activeTab) {
      _ExploreTab.destination => "Cari destinasi...",
      _ExploreTab.accommodation => "Cari akomodasi...",
      _ExploreTab.package => "Cari paket wisata...",
    };

    final selectedCategoryId = destProvider.selectedCategoryId;

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
            color: AppColors.divider.withOpacity(0.6),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNeutral.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row
          Row(
            children: [
              if (widget.showBackButton)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Back",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.showBackButton) const SizedBox(width: AppSpacing.sm),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: AppColors.textOnDark,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Text(
                "Explore",
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (!isLoading)
                Text(
                  "$totalCount tempat",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Search
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: searchHint, // ✅
              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textHint,
              ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textHint,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _destProvider.search('');
                          _accomProvider.search('');
                          _packageProvider.search(''); // ✅
                        },
                      )
                      : null,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.divider, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.divider, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Chips: Semua → Akomodasi → Paket Wisata → kategori destinasi
          SizedBox(
            height: 36,
            child:
                catProvider.isLoading
                    ? const SizedBox()
                    : ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Chip: Semua (destinasi tanpa filter)
                        ExploreCategoryChip(
                          name: 'Semua',
                          isSelected:
                              _activeTab == _ExploreTab.destination &&
                              selectedCategoryId.isEmpty,
                          onTap: () => _switchTab(_ExploreTab.destination),
                        ),

                        // ✅ Chip: Akomodasi
                        ExploreCategoryChip(
                          name: 'Akomodasi',
                          isSelected: _activeTab == _ExploreTab.accommodation,
                          onTap: () => _switchTab(_ExploreTab.accommodation),
                        ),

                        // ✅ Chip: Paket Wisata
                        ExploreCategoryChip(
                          name: 'Paket Wisata',
                          isSelected: _activeTab == _ExploreTab.package,
                          onTap: () => _switchTab(_ExploreTab.package),
                        ),

                        // Chip: kategori destinasi
                        ...catProvider.destinationCategories.map(
                          (cat) => ExploreCategoryChip(
                            name: cat.name,
                            isSelected:
                                _activeTab == _ExploreTab.destination &&
                                selectedCategoryId == cat.id,
                            onTap:
                                () => _switchTab(
                                  _ExploreTab.destination,
                                  categoryId: cat.id,
                                ),
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  // ── DESTINATION LIST
  Widget _buildDestinationList(
    BuildContext context,
    DestinationProvider destProvider,
  ) {
    if (destProvider.isLoading) return const ExploreLoadingState();
    if (destProvider.errorMessage != null) {
      return _buildError(onRetry: () => _destProvider.clearError());
    }

    final destinations = destProvider.filteredDestinations;
    if (destinations.isEmpty) {
      return ExploreEmptyState(
        message: "Tidak ada destinasi ditemukan",
        icon: Icons.landscape_rounded,
        onReset:
            destProvider.hasFilter
                ? () {
                  _searchController.clear();
                  _destProvider.clearFilter();
                }
                : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final item = destinations[index];
        return ExploreDestinationCard(
          item: item,
          onTap: () {
            // ── AUTH GUARD ──
            AuthGuard.checkAndRun(
              context: context,
              action:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(destination: item),
                    ),
                  ),
            );
          },
        );
      },
    );
  }

  // ── ACCOMMODATION LIST
  Widget _buildAccommodationList(
    BuildContext context,
    AccommodationProvider accomProvider,
  ) {
    if (accomProvider.isLoading) return const ExploreLoadingState();
    if (accomProvider.errorMessage != null) {
      return _buildError(onRetry: () => _accomProvider.clearError());
    }

    final accommodations = accomProvider.filteredAccommodations;
    if (accommodations.isEmpty) {
      return ExploreEmptyState(
        message: "Tidak ada akomodasi ditemukan",
        icon: Icons.hotel_rounded,
        onReset:
            accomProvider.hasFilter
                ? () {
                  _searchController.clear();
                  _accomProvider.clearFilter();
                }
                : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: accommodations.length,
      itemBuilder: (context, index) {
        final item = accommodations[index];
        return ExploreAccommodationCard(
          item: item,
          onTap: () {
            // ── AUTH GUARD ──
            AuthGuard.checkAndRun(
              context: context,
              action:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => AccommodationDetailPage(accommodation: item),
                    ),
                  ),
            );
          },
        );
      },
    );
  }

  // ── PACKAGE LIST
  Widget _buildPackageList(
    BuildContext context,
    PackageProvider packageProvider,
  ) {
    if (packageProvider.isLoading) return const ExploreLoadingState();
    if (packageProvider.errorMessage != null) {
      return _buildError(onRetry: () => _packageProvider.clearError());
    }

    final packages = packageProvider.filteredPackages;
    if (packages.isEmpty) {
      return ExploreEmptyState(
        message: "Tidak ada paket wisata ditemukan",
        icon: Icons.card_travel_rounded,
        onReset:
            packageProvider.hasFilter
                ? () {
                  _searchController.clear();
                  _packageProvider.clearFilter();
                }
                : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final item = packages[index];
        return ExplorePackageCard(
          item: item,
          onTap: () {
            // ── AUTH GUARD ──
            AuthGuard.checkAndRun(
              context: context,
              action:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PackageDetailPage(package: item),
                    ),
                  ),
            );
          },
        );
      },
    );
  }

  // ── ERROR STATE
  Widget _buildError({required VoidCallback onRetry}) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "Gagal memuat data",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(onPressed: onRetry, child: const Text("Coba lagi")),
      ],
    ),
  );
}
