// lib/presentation/pages/package_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/data/models/package_model.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';
import 'package:aplikasi_wisata/providers/destination_provider.dart';
import 'package:aplikasi_wisata/presentation/pages/detail_page.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class PackageDetailPage extends StatefulWidget {
  final PackageModel package;
  const PackageDetailPage({super.key, required this.package});

  @override
  State<PackageDetailPage> createState() => _PackageDetailPageState();
}

class _PackageDetailPageState extends State<PackageDetailPage> {
  int _selectedTierIndex = 0;

  PackageTier? get _selectedTier =>
      widget.package.hasTiers ? widget.package.tiers[_selectedTierIndex] : null;

  @override
  void initState() {
    super.initState();
    // Default pilih tier Standar (isPopular) kalau ada
    if (widget.package.hasTiers) {
      final popularIndex = widget.package.tiers.indexWhere((t) => t.isPopular);
      if (popularIndex != -1) _selectedTierIndex = popularIndex;
    }
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

    // ── FIX: Struktur Column (bukan Stack) agar _BottomBar
    //         tidak mengapung di atas konten scroll.
    //         Stack tetap dipakai HANYA untuk hero + back button.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── HERO + BACK BUTTON (Stack lokal, bukan full-page)
          Stack(
            children: [
              _HeroImage(imageUrl: pkg.imageUrl),
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                left: AppSpacing.md,
                child: _BackButton(),
              ),
            ],
          ),

          // ── SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                // Rounded top corners menyambung dari hero
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusXl),
                  ),
                ),
                // Geser naik sedikit agar overlap dengan hero
                transform: Matrix4.translationValues(
                  0,
                  -AppSpacing.radiusXl,
                  0,
                ),
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  // Padding bawah cukup (tidak perlu kompensasi bottom bar
                  // karena bottom bar sudah di luar scroll)
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama + Durasi
                    _PackageHeader(pkg: pkg),
                    const SizedBox(height: AppSpacing.lg),

                    // Deskripsi
                    _SectionLabel(label: 'Tentang Paket'),
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

                    // ── PILIH PAKET (Traveloka style)
                    if (pkg.hasTiers) ...[
                      _SectionLabel(label: 'Pilih Paket'),
                      const SizedBox(height: AppSpacing.sm),
                      _TierSelector(
                        tiers: pkg.tiers,
                        selectedIndex: _selectedTierIndex,
                        onSelect: (i) => setState(() => _selectedTierIndex = i),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Detail tier yang dipilih
                      if (_selectedTier != null) ...[
                        _TierDetail(tier: _selectedTier!),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ],

                    // Fasilitas umum
                    if (pkg.includes.isNotEmpty) ...[
                      _SectionLabel(label: 'Fasilitas Umum'),
                      const SizedBox(height: AppSpacing.sm),
                      _IncludesList(includes: pkg.includes),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Destinasi dalam paket
                    // FIX: widget ini sekarang fully visible karena
                    //      tidak tertutup bottom bar yang mengapung
                    if (pkg.hasDestinations) ...[
                      _SectionLabel(label: 'Destinasi dalam Paket'),
                      const SizedBox(height: AppSpacing.sm),
                      _DestinationList(destinationIds: pkg.destinationIds),
                      // Sedikit spacing tambahan di akhir list
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── BOTTOM BAR — di luar Expanded, tidak overlay konten
          _BottomBar(tier: _selectedTier, fallbackPrice: pkg.formattedPrice),
        ],
      ),
    );
  }
}

// ── SUB WIDGETS ────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  final String imageUrl;
  const _HeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    // Tinggi hero = 260 + status bar agar gambar muncul di balik status bar
    final topPadding = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 260 + topPadding,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.card_travel_rounded,
                      size: 56,
                      color: AppColors.textOnDark,
                    ),
                  ),
                ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.6, 1.0],
                colors: [
                  Colors.transparent,
                  Color(0x26064E4E),
                  Color(0xBF0D2B2B),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.92),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDeep.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 15,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _PackageHeader extends StatelessWidget {
  final PackageModel pkg;
  const _PackageHeader({required this.pkg});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pkg.name,
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    pkg.durationLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.earthSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: AppColors.earthLight.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 12,
                    color: AppColors.earth,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${pkg.destinationIds.length} Destinasi',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textEarth,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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

// ── TIER SELECTOR (Traveloka style) ───────────────────────────────────────

class _TierSelector extends StatelessWidget {
  final List<PackageTier> tiers;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _TierSelector({
    required this.tiers,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tiers.length, (i) {
        final tier = tiers[i];
        final isSelected = i == selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < tiers.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm + 2,
                horizontal: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [],
              ),
              child: Column(
                children: [
                  // Badge "Terlaris"
                  if (tier.isPopular)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.surface.withOpacity(0.25)
                                : AppColors.accentSurface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
                      ),
                      child: Text(
                        '⭐ Terlaris',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color:
                              isSelected
                                  ? AppColors.textOnDark
                                  : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  Text(
                    tier.name,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontSize: 13,
                      color:
                          isSelected
                              ? AppColors.textOnDark
                              : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tier.formattedPrice,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color:
                          isSelected
                              ? AppColors.textOnDark.withOpacity(0.85)
                              : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Maks. ${tier.maxPerson} orang',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 9,
                      color:
                          isSelected
                              ? AppColors.textOnDark.withOpacity(0.7)
                              : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── TIER DETAIL ────────────────────────────────────────────────────────────

class _TierDetail extends StatelessWidget {
  final PackageTier tier;
  const _TierDetail({required this.tier});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(tier.name),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deskripsi tier
            Text(
              tier.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(color: AppColors.primary.withOpacity(0.15), thickness: 1),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Yang Sudah Termasuk:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...tier.includes.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 10,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── INCLUDES LIST ──────────────────────────────────────────────────────────

class _IncludesList extends StatelessWidget {
  final List<String> includes;
  const _IncludesList({required this.includes});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children:
          includes
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.earthSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: AppColors.earthLight.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 13,
                        color: AppColors.earth,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}

// ── DESTINATION LIST ───────────────────────────────────────────────────────

class _DestinationList extends StatelessWidget {
  final List<String> destinationIds;
  const _DestinationList({required this.destinationIds});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DestinationProvider>();
    final destinations =
        provider.allDestinations
            .where((d) => destinationIds.contains(d.id))
            .toList();

    if (destinations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Memuat destinasi...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // FIX: Tidak menggunakan ListView (yang punya scroll sendiri).
    //      Cukup Column biasa agar menyatu dengan parent scroll.
    return Column(
      children:
          destinations.map((d) => _DestinationItem(destination: d)).toList(),
    );
  }
}

class _DestinationItem extends StatelessWidget {
  final DestinationModel destination;
  const _DestinationItem({required this.destination});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(destination: destination),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.7),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Image.network(
                destination.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(
                        Icons.landscape_rounded,
                        color: AppColors.textOnDark,
                        size: 24,
                      ),
                    ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 11,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        // FIX: tambah Expanded agar teks lokasi
                        //      tidak overflow secara horizontal
                        child: Text(
                          destination.location,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 11,
                        color: Color(0xFFE8A020),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        destination.rating.toStringAsFixed(1),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Chevron
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── BOTTOM BAR ─────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final PackageTier? tier;
  final String fallbackPrice;

  const _BottomBar({required this.tier, required this.fallbackPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      // FIX: padding bottom otomatis ikut safe area device
      //      (notch, gesture bar, dsb.) tanpa perlu kalkulasi manual
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider.withOpacity(0.6), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNeutral.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Harga
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Harga per orang',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
              Text(
                tier?.formattedPrice ?? fallbackPrice,
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              if (tier != null)
                Text(
                  'Paket ${tier!.name} · Maks. ${tier!.maxPerson} orang',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          // Tombol pesan
          Expanded(
            child: GestureDetector(
              onTap: () {
                // TODO: navigasi ke halaman booking
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Memesan paket ${tier?.name ?? ''} — segera hadir!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textOnDark,
                      ),
                    ),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                );
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
