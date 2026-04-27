import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // ── Animasi masuk untuk logo & teks
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    // Fullscreen immersive saat splash
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      _waitForAuth(),
    ]).then((_) => _navigate());
  }

  // ── Logic tidak diubah sama sekali ──────────────────────────────
  Future<void> _waitForAuth() async {
    final auth = context.read<AuthProvider>();
    while (auth.status == AuthStatus.unknown) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _navigate() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.status == AuthStatus.authenticated) {
      Navigator.pushReplacementNamed(context, '/home_screen');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  // ────────────────────────────────────────────────────────────────

  Widget _loadingDot(int index) {
    // Animasi dot: pulse sequential dengan warna on-dark
    return ScaleTransition(
      scale: Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.15, 1.0, curve: Curves.easeInOut),
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final progress = (_controller.value - index * 0.15).clamp(0.0, 1.0);
          return Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Color.lerp(
                AppColors.textOnDark.withOpacity(0.3),
                AppColors.accent,
                progress,
              ),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ── Background: gradient gelap teal (alam Trenggalek)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.splashGradient,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Ornamen lingkaran dekoratif (background layer)
            Positioned(
              top: -80,
              right: -80,
              child: _DecorativeCircle(
                size: 280,
                color: AppColors.primaryLight.withOpacity(0.15),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: _DecorativeCircle(
                size: 220,
                color: AppColors.accent.withOpacity(0.10),
              ),
            ),

            // ── Konten utama
            Center(
              child: SlideTransition(
                position: _slideUp,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo container
                      Container(
                        width: AppSpacing.logoSize,
                        height: AppSpacing.logoSize,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusXl,
                          ),
                          border: Border.all(
                            color: AppColors.white.withOpacity(0.20),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withOpacity(0.4),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.travel_explore,
                          size: AppSpacing.logoIcon,
                          color: AppColors.textOnDark,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // "Virtual" — expressive italic
                      Text("Virtual", style: AppTextStyles.titleExpressive),

                      const SizedBox(height: AppSpacing.xs),

                      // "Tourism" — spaced subtitle
                      Text(
                        "Tourism",
                        style: AppTextStyles.subtitleMedium.copyWith(
                          color: AppColors.textOnDark.withOpacity(0.6),
                          letterSpacing: 4.0,
                        ),
                      ),

                      // "TRENGGALEK" — display bold
                      Text(
                        "TRENGGALEK",
                        style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.textOnDark,
                          letterSpacing: -1.5,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Separator "EAST JAVA"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _DividerLine(),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm + AppSpacing.xs,
                            ),
                            child: Text(
                              "EAST JAVA",
                              style: AppTextStyles.labelSpacedOnDark,
                            ),
                          ),
                          _DividerLine(),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      // Loading dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _loadingDot(0),
                          const SizedBox(width: AppSpacing.sm),
                          _loadingDot(1),
                          const SizedBox(width: AppSpacing.sm),
                          _loadingDot(2),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // "PREPARING YOUR JOURNEY"
                      Text(
                        "PREPARING YOUR JOURNEY",
                        style: AppTextStyles.labelSpacedOnDark.copyWith(
                          color: AppColors.textOnDark.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Footer
            Positioned(
              bottom: AppSpacing.lg,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "TRENGGALEK TOURISM BOARD • v2.0.0",
                  style: AppTextStyles.labelSpacedSubtle.copyWith(
                    color: AppColors.textOnDark.withOpacity(0.35),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.textOnDark.withOpacity(0.0),
            AppColors.textOnDark.withOpacity(0.4),
          ],
        ),
      ),
    );
  }
}
