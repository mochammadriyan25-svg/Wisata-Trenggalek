// lib/widgets/destinations/search_header.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class SearchHeader extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;

  const SearchHeader({
    super.key,
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  State<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + AppSpacing.sm,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
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
        children: [
          _buildTopBar(context),
          const SizedBox(height: AppSpacing.md),
          _buildSearchField(),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        // Back button — teal surface, konsisten
        GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm + 2),

        // Icon badge — sama persis dengan ExplorePage & FavoritePage
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
            Icons.travel_explore_rounded,
            color: AppColors.textOnDark,
            size: 18,
          ),
        ),

        const SizedBox(width: AppSpacing.sm + 2),

        // Judul
        Expanded(
          child: Text(
            "Destinasi",
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Notif icon
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            size: 18,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: _isFocused ? AppColors.surface : AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: _isFocused ? AppColors.primary : AppColors.divider,
            width: _isFocused ? 1.5 : 1,
          ),
          boxShadow:
              _isFocused
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Row(
          children: [
            // Search icon — berubah warna saat focus
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 4,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.search_rounded,
                  key: ValueKey(_isFocused),
                  color: _isFocused ? AppColors.primary : AppColors.textHint,
                  size: 20,
                ),
              ),
            ),

            // Input
            Expanded(
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onSearchChanged,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Cari tempat wisata di Trenggalek...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                    fontSize: 13,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            // Clear button — muncul saat ada teks
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (_, value, __) {
                if (value.text.isEmpty) {
                  // Filter icon saat kosong
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm + 4),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                // Clear icon saat ada teks
                return GestureDetector(
                  onTap: () {
                    widget.controller.clear();
                    widget.onSearchChanged('');
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm + 4),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
