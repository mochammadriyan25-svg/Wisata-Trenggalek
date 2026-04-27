// lib/presentation/pages/explore_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/destination_provider.dart';
import '../../providers/accommodation_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/explore/explore_widget.dart';
import 'detail_page.dart';

// ── ENUM: jenis konten yang ditampilkan
enum ExploreMode { destination, accommodation }

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

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late ExploreMode _currentMode;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ── Referensi provider disimpan di sini agar aman dipakai
  //    di dispose() dan listener tanpa menyentuh context
  late DestinationProvider _destProvider;
  late AccommodationProvider _accomProvider;
  bool _providersInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Listener memakai _destProvider & _accomProvider (field instance),
    // bukan context.read — sehingga aman meski widget sudah dilepas
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Simpan referensi provider sekali di sini.
    // didChangeDependencies dipanggil setelah initState dan setiap kali
    // dependency (Provider) berubah, tapi selalu saat widget masih aktif.
    if (!_providersInitialized) {
      _destProvider = context.read<DestinationProvider>();
      _accomProvider = context.read<AccommodationProvider>();
      _providersInitialized = true;

      // Inisialisasi filter & search awal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (widget.initialCategoryId.isNotEmpty) {
          _destProvider.filterByCategory(widget.initialCategoryId);
          // Akomodasi tidak perlu filter kategori awal
        }

        if (widget.initialSearch.isNotEmpty) {
          _searchController.text = widget.initialSearch;
          _destProvider.search(widget.initialSearch);
          _accomProvider.search(widget.initialSearch);
        }
      });
    }
  }

  @override
  void dispose() {
    // Aman: memakai field instance, bukan context.read
    _destProvider.clearFilter();
    _accomProvider.clearFilter();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Aman: memakai field instance, bukan context.read
    final keyword = _searchController.text;
    _destProvider.search(keyword);
    _accomProvider.search(keyword);
  }

  void _switchMode(ExploreMode mode) {
    if (_currentMode == mode) return;
    _fadeController.reset();
    setState(() => _currentMode = mode);
    _fadeController.forward();

    // Aman: memakai field instance
    _searchController.clear();
    _destProvider.clearFilter();
    _accomProvider.clearFilter();
  }

  @override
  Widget build(BuildContext context) {
    final destProvider = context.watch<DestinationProvider>();
    final accomProvider = context.watch<AccommodationProvider>();
    final catProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, destProvider, accomProvider, catProvider),
            const SizedBox(height: 8),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child:
                    _currentMode == ExploreMode.destination
                        ? _buildDestinationList(context, destProvider)
                        : _buildAccommodationList(context, accomProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    DestinationProvider destProvider,
    AccommodationProvider accomProvider,
    CategoryProvider catProvider,
  ) {
    final totalCount =
        _currentMode == ExploreMode.destination
            ? destProvider.filteredDestinations.length
            : accomProvider.filteredAccommodations.length;

    final isLoading =
        _currentMode == ExploreMode.destination
            ? destProvider.isLoading
            : accomProvider.isLoading;

    final selectedCategoryId = destProvider.selectedCategoryId;

    // Category chips hanya tampil di mode destinasi
    final showCategoryChips = _currentMode == ExploreMode.destination;

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

          // ── MODE TOGGLE: Destinasi | Akomodasi
          _buildModeToggle(),

          const SizedBox(height: AppSpacing.md),

          // ── Search
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText:
                  _currentMode == ExploreMode.destination
                      ? "Cari destinasi..."
                      : "Cari akomodasi...",
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
                          // Aman: memakai field instance
                          _destProvider.search('');
                          _accomProvider.search('');
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

          // ── Category chips — hanya tampil di mode Destinasi
          if (showCategoryChips) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 36,
              child:
                  catProvider.isLoading
                      ? const SizedBox()
                      : ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ExploreCategoryChip(
                            name: 'Semua',
                            isSelected: selectedCategoryId.isEmpty,
                            onTap: () => _destProvider.filterByCategory(''),
                          ),
                          ...catProvider.destinationCategories.map(
                            (cat) => ExploreCategoryChip(
                              name: cat.name,
                              isSelected: selectedCategoryId == cat.id,
                              onTap:
                                  () => _destProvider.filterByCategory(cat.id),
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ],
      ),
    );
  }

  // ── MODE TOGGLE ──────────────────────────────────────────────────────────
  Widget _buildModeToggle() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          _buildToggleOption(
            mode: ExploreMode.destination,
            icon: Icons.landscape_rounded,
            label: "Destinasi",
          ),
          _buildToggleOption(
            mode: ExploreMode.accommodation,
            icon: Icons.hotel_rounded,
            label: "Akomodasi",
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required ExploreMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color:
                    isSelected ? AppColors.textOnDark : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected
                          ? AppColors.textOnDark
                          : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DESTINATION LIST ─────────────────────────────────────────────────────
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
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPage(destination: item),
                ),
              ),
        );
      },
    );
  }

  // ── ACCOMMODATION LIST ───────────────────────────────────────────────────
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
            // TODO: Ganti dengan halaman detail akomodasi kamu
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Buka detail: ${item.name}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }

  // ── ERROR STATE ──────────────────────────────────────────────────────────
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
