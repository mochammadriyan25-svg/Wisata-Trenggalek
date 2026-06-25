// lib/presentation/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_primary_button.dart';
import '../../core/constants/app_route.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _animCtrl.forward();
  }

  // ── Logic tidak diubah ──────────────────────────────────────────
  String _getRedirectRoute() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['redirectTo'] != null) {
      return args['redirectTo'] as String;
    }
    return '/home_screen';
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      final isAdmin = await auth.isCurrentUserAdmin(); // ✅ TAMBAH
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        isAdmin ? AppRoutes.adminDashboard : _getRedirectRoute(), // ✅ UBAH
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Login gagal')),
      );
      auth.clearError();
    }
  }

  Future<void> _loginWithGoogle() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (!mounted) return;
    if (success) {
      final isAdmin = await auth.isCurrentUserAdmin(); // ✅ TAMBAH
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        isAdmin ? AppRoutes.adminDashboard : _getRedirectRoute(), // ✅ UBAH
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Login Google gagal')),
      );
      auth.clearError();
    }
  }

  void _continueAsGuest() {
    Navigator.pushReplacementNamed(context, '/home_screen');
  }
  // ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ Baris 1: Pastikan scaffold resize
      backgroundColor: AppColors.background,
      body: GestureDetector(
        // ✅ Baris 2: Dismiss keyboard saat tap di luar
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          // ✅ Baris 3: Hindari notch/status bar
          child: SingleChildScrollView(
            // ✅ Baris 4: Bisa scroll saat keyboard muncul
            child: Center(
              // ✅ Baris 5: Center dipindah ke dalam scroll
              child: SlideTransition(
                position: _slideUp,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Container(
                    margin: const EdgeInsets.all(AppSpacing.md),
                    constraints: const BoxConstraints(maxWidth: 420),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: AppColors.divider.withOpacity(0.7),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowDeep,
                          blurRadius: 32,
                          offset: Offset(0, 12),
                        ),
                        BoxShadow(
                          color: AppColors.shadowNeutral,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── HEADER
                        _LoginHeader(),

                        // ── IMAGE
                        _HeroImage(borderRadius: AppSpacing.radiusMd),

                        // ── TITLE
                        const _LoginTitle(),

                        // ── FORM
                        _LoginForm(
                          emailController: _emailController,
                          passwordController: _passwordController,
                          obscure: _obscure,
                          isLoading: isLoading,
                          onToggleObscure:
                              () => setState(() => _obscure = !_obscure),
                          onLogin: _login,
                          onGoogle: _loginWithGoogle,
                          onGuest: _continueAsGuest,
                        ),

                        // ── FOOTER
                        _LoginFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Row(
            children: [
              // Logo badge — teal gradient
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.travel_explore,
                  size: 18,
                  color: AppColors.textOnDark,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "Virtual Tourism Trenggalek",
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final double borderRadius;
  const _HeroImage({required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Hero photo — pantai/alam Trenggalek
            Image.network(
              "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80",
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.landscape_rounded,
                        size: 48,
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),
            ),

            // Deep teal gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.authHeroOverlay),
              ),
            ),

            // Location pill — sand/accent tone
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.xs + 1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 10,
                      color: AppColors.textOnDark,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      "Trenggalek, Jawa Timur",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tagline overline — bottom left
            Positioned(
              bottom: AppSpacing.sm,
              left: AppSpacing.sm,
              child: Text(
                "JELAJAHI · TEMUKAN · KAGUMKAN",
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.textOnDark.withOpacity(0.85),
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginTitle extends StatelessWidget {
  const _LoginTitle();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overline — tren 2026
          Text("HALO PENJELAJAH", style: AppTextStyles.overline),
          SizedBox(height: 6),
          Text("Selamat Datang", style: AppTextStyles.headlineLarge),
          SizedBox(height: 6),
          Text(
            "Jelajahi permata tersembunyi Trenggalek dari layar Anda.",
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscure;
  final bool isLoading;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;
  final VoidCallback onGoogle;
  final VoidCallback onGuest;

  const _LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.obscure,
    required this.isLoading,
    required this.onToggleObscure,
    required this.onLogin,
    required this.onGoogle,
    required this.onGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          AuthTextField(
            controller: emailController,
            label: "Alamat Email",
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: AppSpacing.sm + AppSpacing.xs),

          AuthTextField(
            controller: passwordController,
            label: "Kata Sandi",
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: obscure,
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textHint,
                size: AppSpacing.iconMd,
              ),
              onPressed: onToggleObscure,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          AuthPrimaryButton(
            label: "Masuk",
            isLoading: isLoading,
            onPressed: onLogin,
          ),

          const SizedBox(height: AppSpacing.md),

          // Or divider
          Row(
            children: [
              const Expanded(
                child: Divider(color: AppColors.divider, thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + AppSpacing.xs,
                ),
                child: Text(
                  "Atau lanjutkan dengan",
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                ),
              ),
              const Expanded(
                child: Divider(color: AppColors.divider, thickness: 1),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm + AppSpacing.xs),

          // Google button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onGoogle,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.divider, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ).copyWith(
                overlayColor: WidgetStateProperty.all(AppColors.primarySurface),
              ),
              icon: Icon(Icons.g_mobiledata, size: 24, color: AppColors.accent),
              label: Text(
                "Masuk dengan Google",
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm + AppSpacing.xs),

          // Guest button — earthy warm tone
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: onGuest,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textEarth,
                backgroundColor: AppColors.earthSurface,
                side: BorderSide(color: AppColors.earthLight, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              icon: const Icon(
                Icons.explore_outlined,
                size: 18,
                color: AppColors.bark,
              ),
              label: Text(
                "Masuk sebagai Tamu",
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textEarth,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.footerGradient,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.radiusLg),
        ),
        border: Border(
          top: BorderSide(color: AppColors.divider.withOpacity(0.5), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Belum punya akun? ",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/register'),
            child: Text(
              "Daftar",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primaryLight,
                decorationThickness: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
