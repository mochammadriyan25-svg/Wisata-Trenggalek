// lib/widgets/virtual_tour/vt_overlay_controls.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';

/// Kontrol overlay Flutter di atas WebView.
///
/// Tombol bawah menggunakan efek frosted glass (BackdropFilter blur)
/// agar tampak menyatu dengan panorama — tidak terkesan "ditempel" begitu saja.
/// Semua ukuran responsif terhadap lebar layar.
class VtOverlayControls extends StatelessWidget {
  final bool isAutoTourActive;
  final bool isInfoVisible;
  final VoidCallback onBack;
  final VoidCallback onToggleAutoTour;
  final VoidCallback onToggleInfo;

  const VtOverlayControls({
    super.key,
    required this.isAutoTourActive,
    required this.isInfoVisible,
    required this.onBack,
    required this.onToggleAutoTour,
    required this.onToggleInfo,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;
    final w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // ── Tombol back (kiri atas)
        Positioned(
          top: topPad + AppSpacing.sm,
          left: AppSpacing.md,
          child: _GlassIconButton(
            icon: Icons.arrow_back_rounded,
            size: w * 0.11,
            onTap: onBack,
          ),
        ),

        // ── Area bawah: gradient + frosted glass pill berisi tombol
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient dari transparan ke hitam — membingkai area bawah
              Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),

              // Frosted glass strip berisi tombol + Google attribution area
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: double.infinity,
                    color: Colors.black.withValues(alpha: 0.45),
                    padding: EdgeInsets.fromLTRB(
                      w * 0.05,
                      14,
                      w * 0.05,
                      botPad + 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _GlassLabelButton(
                          icon:
                              isAutoTourActive
                                  ? Icons.stop_circle_outlined
                                  : Icons.play_circle_outline_rounded,
                          label: isAutoTourActive ? 'Stop Tur' : 'Tur Otomatis',
                          isActive: isAutoTourActive,
                          screenWidth: w,
                          onTap: onToggleAutoTour,
                        ),
                        SizedBox(width: w * 0.04),
                        _GlassLabelButton(
                          icon: Icons.info_outline_rounded,
                          label: 'Info Lokasi',
                          isActive: isInfoVisible,
                          screenWidth: w,
                          onTap: onToggleInfo,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;
  const _GlassIconButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.48),
        ),
      ),
    ),
  );
}

class _GlassLabelButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final double screenWidth;
  final VoidCallback onTap;

  const _GlassLabelButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.screenWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.045,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color:
            isActive
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color:
              isActive
                  ? Colors.white.withValues(alpha: 0.65)
                  : Colors.white.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: screenWidth * 0.048, color: Colors.white),
          SizedBox(width: screenWidth * 0.02),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: screenWidth * 0.033,
            ),
          ),
        ],
      ),
    ),
  );
}
