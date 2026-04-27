// lib/widgets/home/home_category_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/data/models/category_model.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';
import 'package:aplikasi_wisata/core/utils/icon_mapper.dart';
import 'package:aplikasi_wisata/presentation/pages/explore_page.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class HomeCategorySection extends StatelessWidget {
  const HomeCategorySection({super.key});

  // Palet kategori — harmonis dengan teal+earth sistem
  static const List<List<Color>> _categoryGradients = [
    [Color(0xFF0A6E6E), Color(0xFF064E4E)], // Teal primary
    [Color(0xFFB8845A), Color(0xFF7A5438)], // Earth clay
    [Color(0xFF2A9D8F), Color(0xFF1A7068)], // Teal muda
    [Color(0xFF5E8C61), Color(0xFF3D6B40)], // Forest sage
    [Color(0xFFC8965A), Color(0xFF9A6E3A)], // Warm sand
    [Color(0xFF4A8FA8), Color(0xFF2E6B85)], // Ocean blue
  ];

  List<Color> _gradientForIndex(int index) =>
      _categoryGradients[index % _categoryGradients.length];

  @override
  Widget build(BuildContext context) {
    // ✅ Gunakan CategoryProvider — konsisten dengan arsitektur
    final provider = context.watch<CategoryProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "Categories",
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 4),

        // ✅ Gunakan state dari provider
        if (provider.isLoading)
          const SizedBox(
            height: 95,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            ),
          )
        else if (provider.errorMessage != null)
          SizedBox(
            height: 80,
            child: Center(
              child: Text(
                'Gagal memuat kategori.',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          )
        else if (provider.categories.isEmpty)
          SizedBox(
            height: 80,
            child: Center(
              child: Text(
                'Belum ada kategori.',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          )
        else
          _CategoryList(
            categories: provider.categories,
            gradientForIndex: _gradientForIndex,
          ),
      ],
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.categories,
    required this.gradientForIndex,
  });

  final List<CategoryModel> categories;
  final List<Color> Function(int) gradientForIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider.withOpacity(0.7), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNeutral.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 95,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: categories.length,
              itemBuilder:
                  (context, index) => _CategoryItem(
                    category: categories[index],
                    gradient: gradientForIndex(index),
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Scroll indicator
          Container(
            height: 4,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.category, required this.gradient});

  final CategoryModel category;
  final List<Color> gradient;

  void _navigateToExplore(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ExplorePage(
              initialCategoryId: category.id,
              showBackButton: true,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToExplore(context),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            // Icon badge — gradient
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                getCategoryIcon(category.icon),
                color: AppColors.textOnDark,
                size: 26,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
