// lib/widgets/package/package_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/package_model.dart';
import '../../data/models/favorite_model.dart';
import '../../providers/favorite_provider.dart';

class PackageBottomBar extends StatefulWidget {
  final PackageTier? tier;
  final String fallbackPrice;
  final String packageId;
  final String userId;

  const PackageBottomBar({
    super.key,
    required this.tier,
    required this.fallbackPrice,
    required this.packageId,
    required this.userId,
  });

  @override
  State<PackageBottomBar> createState() => _PackageBottomBarState();
}

class _PackageBottomBarState extends State<PackageBottomBar> {
  int _quantity = 1;

  int get _totalPrice {
    final basePrice = widget.tier?.price ?? 0;
    return basePrice * _quantity;
  }

  String get _formattedTotalPrice {
    if (widget.tier == null) return widget.fallbackPrice;
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'IDR ${formatter.format(_totalPrice)}';
  }

  int get _totalPerson {
    final maxPerson = widget.tier?.maxPerson ?? 1;
    return maxPerson * _quantity;
  }

  void _increment() => setState(() => _quantity++);
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = context.watch<FavoriteProvider>();
    final isFavorite = favoriteProvider.isFavorite(
      widget.packageId,
      FavoriteItemType.package,
    );
    final isLoading = favoriteProvider.isLoading;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── GRADIENT FADE: transparan → surface ──
        Container(
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.surface.withOpacity(0.0),
                AppColors.surface.withOpacity(1.0),
              ],
            ),
          ),
        ),

        // ── BODY BAR ──
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            bottomPad > 0 ? bottomPad + AppSpacing.sm : AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ROW ATAS: Harga + Qty
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total Harga',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                      Text(
                        _formattedTotalPrice,
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      if (widget.tier != null)
                        Text(
                          '${widget.tier!.name} · $_totalPerson orang',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: AppColors.textHint,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  _buildQtyCounter(),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // ROW BAWAH: Favorit + Share
              _ActionButtons(
                isFavorite: isFavorite,
                isLoading: isLoading,
                onFavorite:
                    () => favoriteProvider.toggleFavorite(
                      widget.userId,
                      widget.packageId,
                      FavoriteItemType.package,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQtyCounter() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove_rounded,
            onTap: _quantity > 1 ? _decrement : null,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            child: Text(
              '$_quantity',
              style: AppTextStyles.headlineSmall.copyWith(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add_rounded,
            onTap: _increment,
            isActive: true,
          ),
        ],
      ),
    );
  }
}

// ── TOMBOL AKSI: Favorit (expanded) + Share ──
class _ActionButtons extends StatelessWidget {
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback onFavorite;

  const _ActionButtons({
    required this.isFavorite,
    required this.isLoading,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: isLoading ? null : onFavorite,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 52,
              decoration: BoxDecoration(
                gradient: isFavorite ? null : AppColors.primaryGradient,
                color: isFavorite ? AppColors.primarySurface : null,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border:
                    isFavorite
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                boxShadow:
                    isFavorite
                        ? []
                        : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
              ),
              child: Center(
                child:
                    isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                isFavorite
                                    ? AppColors.primary
                                    : AppColors.textOnDark,
                          ),
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color:
                                  isFavorite
                                      ? AppColors.primary
                                      : AppColors.textOnDark,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              isFavorite
                                  ? 'Saved to Favorites'
                                  : 'Add to Favorites',
                              style: AppTextStyles.buttonLabel.copyWith(
                                fontSize: 14,
                                color:
                                    isFavorite
                                        ? AppColors.primary
                                        : AppColors.textOnDark,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // Tombol Share
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: AppColors.earthSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.earthLight, width: 1.2),
          ),
          child: const Icon(
            Icons.share_rounded,
            color: AppColors.bark,
            size: 20,
          ),
        ),
      ],
    );
  }
}

/// Tombol qty (+/-)
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isActive;

  const _QtyButton({required this.icon, this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color:
              enabled
                  ? (isActive ? AppColors.primary : Colors.transparent)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(
          icon,
          size: 16,
          color:
              enabled
                  ? (isActive ? AppColors.textOnDark : AppColors.primary)
                  : AppColors.textHint,
        ),
      ),
    );
  }
}
