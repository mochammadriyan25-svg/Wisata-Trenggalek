// lib/presentation/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _agree = false;

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
  Future<void> _register() async {
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the terms")),
      );
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password tidak sama")));
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
      '',
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/home_screen');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Register gagal')),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SlideTransition(
          position: _slideUp,
          child: FadeTransition(
            opacity: _fadeIn,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── HEADER
                  _RegisterHeader(),

                  // ── HERO IMAGE
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: Stack(
                        children: [
                          Image.network(
                            "https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&q=80",
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.forest_rounded,
                                      size: 56,
                                      color: AppColors.textOnDark,
                                    ),
                                  ),
                                ),
                          ),
                          // Teal-deep overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppColors.authHeroOverlay,
                              ),
                            ),
                          ),

                          // Nature pill badge — teal tone
                          Positioned(
                            top: AppSpacing.sm,
                            left: AppSpacing.sm,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm + 2,
                                vertical: AppSpacing.xs + 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusFull,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.forest_rounded,
                                    size: 10,
                                    color: AppColors.textOnDark,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    "Alam Trenggalek",
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

                          // Tagline overline
                          Positioned(
                            bottom: AppSpacing.sm,
                            left: AppSpacing.sm,
                            child: Text(
                              "Bergabung · Jelajahi · Rasakan",
                              style: AppTextStyles.overline.copyWith(
                                color: AppColors.textOnDark.withValues(
                                  alpha: 0.85,
                                ),
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── TITLE
                  const _RegisterTitle(),

                  const SizedBox(height: AppSpacing.lg),

                  // ── FORM
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        AuthTextField(
                          controller: _nameController,
                          label: "Nama Lengkap",
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AuthTextField(
                          controller: _emailController,
                          label: "Alamat Email",
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AuthTextField(
                          controller: _passwordController,
                          label: "Kata Sandi",
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AuthTextField(
                          controller: _confirmController,
                          label: "Konfirmasi Kata Sandi",
                          prefixIcon: Icons.shield_outlined,
                          obscureText: true,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // ── TERMS
                        _TermsCheckbox(
                          value: _agree,
                          onChanged: (v) => setState(() => _agree = v!),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        AuthPrimaryButton(
                          label: "Daftar",
                          isLoading: isLoading,
                          onPressed: _register,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // OR divider
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: AppColors.divider,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm + AppSpacing.xs,
                              ),
                              child: Text(
                                "ATAU",
                                style: AppTextStyles.labelSpaced.copyWith(
                                  color: AppColors.textHint,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: AppColors.divider,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Guest button — earthy warm
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : _continueAsGuest,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textEarth,
                              backgroundColor: AppColors.earthSurface,
                              side: BorderSide(
                                color: AppColors.earthLight,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                              ),
                            ),
                            icon: const Icon(
                              Icons.explore_outlined,
                              color: AppColors.bark,
                              size: 18,
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

                        const SizedBox(height: AppSpacing.lg),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Sudah punya akun? ",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                "Login",
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
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.waves_rounded,
                        size: 10,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "© 2026 Virtual Tourism Trenggalek",
                        style: AppTextStyles.labelSpacedSubtle,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────

class _RegisterHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.divider, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowNeutral.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Virtual Tourism Trenggalek",
                style: AppTextStyles.headlineMedium,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _RegisterTitle extends StatelessWidget {
  const _RegisterTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("MULAI PERJALANANMU", style: AppTextStyles.overline),
        const SizedBox(height: 6),
        const Text("Daftar Akun", style: AppTextStyles.headlineLarge),
        const SizedBox(height: 6),
        Text(
          "Bergabunglah dengan kami untuk menjelajahi permata\ntersembunyi di Trenggalek",
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: value ? AppColors.primarySurface : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: value ? AppColors.primaryLight : AppColors.divider,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              activeColor: AppColors.primary,
              checkColor: AppColors.textOnDark,
              side: const BorderSide(color: AppColors.divider, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            "Saya setuju dengan Syarat dan Ketentuan",
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: value ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: value ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
