import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';
import 'package:aplikasi_wisata/data/models/menu_item_model.dart';

class DetailEntranceFeeCard extends StatelessWidget {
  final DestinationModel item;
  const DetailEntranceFeeCard({super.key, required this.item});

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
          // ── HEADER ────────────────────────────────────────────────────────
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
                item.isKuliner ? 'Daftar Menu' : 'Harga Tiket',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── CONTENT ───────────────────────────────────────────────────────
          if (item.isKuliner)
            _KulinerMenuList(menus: item.menus)
          else
            _TicketPriceList(item: item),
        ],
      ),
    );
  }
}

// ── KULINER: DAFTAR MENU ──────────────────────────────────────────────────────

class _KulinerMenuList extends StatelessWidget {
  final List<MenuItemModel> menus;
  const _KulinerMenuList({required this.menus});

  @override
  Widget build(BuildContext context) {
    if (menus.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          'Menu belum tersedia',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menus.length,
      separatorBuilder:
          (_, __) => Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Divider(
                color: AppColors.earthLight.withOpacity(0.6),
                thickness: 1,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
      itemBuilder: (_, index) => _MenuRow(menu: menus[index]),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final MenuItemModel menu;
  const _MenuRow({required this.menu});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.restaurant_menu_rounded,
            size: 16,
            color: AppColors.textEarth,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Nama + deskripsi opsional
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                menu.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              if (menu.description != null && menu.description!.isNotEmpty)
                Text(
                  menu.description!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ),

        // Harga
        Text(
          menu.formattedPrice,
          style: AppTextStyles.headlineSmall.copyWith(
            fontSize: 14,
            color: menu.isFree ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── NON-KULINER: HARGA TIKET ──────────────────────────────────────────────────

class _TicketPriceList extends StatelessWidget {
  final DestinationModel item;
  const _TicketPriceList({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DetailFeeRow(label: 'Dewasa', amount: item.priceAdult),
        const SizedBox(height: AppSpacing.sm),
        Divider(color: AppColors.earthLight.withOpacity(0.6), thickness: 1),
        const SizedBox(height: AppSpacing.sm),
        DetailFeeRow(label: 'Anak', amount: item.priceChild),
      ],
    );
  }
}

// ── DETAIL FEE ROW (tetap publik, bisa dipakai di tempat lain) ────────────────

class DetailFeeRow extends StatelessWidget {
  final String label;
  final int amount;
  const DetailFeeRow({super.key, required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    final formatted =
        amount == 0
            ? '0'
            : 'IDR ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              label == 'Dewasa'
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
