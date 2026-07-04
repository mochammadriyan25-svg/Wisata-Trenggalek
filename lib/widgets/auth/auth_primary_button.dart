// lib/widgets/auth/auth_primary_button.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class AuthPrimaryButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressAnim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressAnim.forward(),
      onTapUp: (_) => _pressAnim.reverse(),
      onTapCancel: () => _pressAnim.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: widget.isLoading ? null : AppColors.primaryGradient,
              color:
                  widget.isLoading
                      ? AppColors.primaryLight.withValues(alpha: 0.35)
                      : null,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow:
                  widget.isLoading
                      ? []
                      : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onPressed,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                splashColor: AppColors.primaryLight.withValues(alpha: 0.25),
                highlightColor: Colors.transparent,
                child: Center(
                  child:
                      widget.isLoading
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.textOnDark,
                            ),
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.label,
                                style: AppTextStyles.buttonLabel,
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.textOnDark,
                                size: 16,
                              ),
                            ],
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
