// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/providers/auth_provider.dart';
import 'package:aplikasi_wisata/widgets/home/home_banner.dart';
import 'package:aplikasi_wisata/widgets/home/home_category_section.dart';
import 'package:aplikasi_wisata/widgets/home/home_recommendation_section.dart';
import 'package:aplikasi_wisata/widgets/home/home_search_bar.dart';
import 'package:aplikasi_wisata/widgets/home/home_package_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Status bar transparan agar header menyatu dengan system UI
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _HomeHeader(),
              SizedBox(height: AppSpacing.md),
              HomeBanner(),
              SizedBox(height: AppSpacing.lg),
              HomeSearchBar(),
              SizedBox(height: AppSpacing.lg),
              HomeCategorySection(),
              SizedBox(height: AppSpacing.lg),
              HomeRecommendationSection(),
              SizedBox(height: AppSpacing.lg),
              HomePackageSection(),
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.user?.name;
    final firstName = userName?.split(' ').first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
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
            color: AppColors.shadowNeutral.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo badge — teal gradient
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.travel_explore,
              color: AppColors.textOnDark,
              size: 22,
            ),
          ),

          const SizedBox(width: AppSpacing.sm + 4),

          // Brand + greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "V-Trenggalek",
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                if (firstName != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        "Halo, ",
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                      Text(
                        "$firstName! 👋",
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 2),
                  Text(
                    "Jelajahi Trenggalek hari ini",
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
