// lib/widgets/accommodation/accommodation_room_type_section.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/accommodation_model.dart';
import 'accommodation_room_type_card.dart';

/// Section pilihan tipe kamar.
///
/// - Jika [roomTypes] tidak kosong → tampilkan daftar kartu tipe kamar
///   yang bisa dipilih (selectable).
/// - Jika [roomTypes] kosong → tampilkan kartu harga sederhana
///   (fallback ke [pricePerNight]).
class AccommodationRoomTypeSection extends StatefulWidget {
  final AccommodationModel item;

  const AccommodationRoomTypeSection({super.key, required this.item});

  @override
  State<AccommodationRoomTypeSection> createState() =>
      _AccommodationRoomTypeSectionState();
}

class _AccommodationRoomTypeSectionState
    extends State<AccommodationRoomTypeSection> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header
        _SectionHeader(hasRoomTypes: item.hasRoomTypes),
        const SizedBox(height: AppSpacing.md),

        // ── Konten: list kamar atau fallback harga dasar
        if (item.hasRoomTypes)
          _RoomTypeList(
            roomTypes: item.roomTypes,
            selectedIndex: _selectedIndex,
            onSelect: (i) => setState(() => _selectedIndex = i),
          )
        else
          _FallbackPriceCard(item: item),
      ],
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final bool hasRoomTypes;
  const _SectionHeader({required this.hasRoomTypes});

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
          hasRoomTypes ? 'Pilih Tipe Kamar' : 'Informasi Harga',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        if (hasRoomTypes) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              'Tap untuk memilih',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Room Type List ─────────────────────────────────────────────────────────

class _RoomTypeList extends StatelessWidget {
  final List<RoomType> roomTypes;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _RoomTypeList({
    required this.roomTypes,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: roomTypes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        return AccommodationRoomTypeCard(
          room: roomTypes[i],
          isSelected: selectedIndex == i,
          onTap: () => onSelect(i),
        );
      },
    );
  }
}

// ── Fallback Price Card (jika roomTypes kosong) ────────────────────────────

class _FallbackPriceCard extends StatelessWidget {
  final AccommodationModel item;
  const _FallbackPriceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Ikon hotel
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.hotel_rounded,
              color: AppColors.textOnDark,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Harga
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harga Per Malam',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.formattedStartingPrice,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color:
                        item.isFree ? Colors.green.shade700 : AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Informasi tipe kamar belum tersedia',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Badge recommended
          if (item.isRecommended)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: const Text(
                '⭐ Top',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
