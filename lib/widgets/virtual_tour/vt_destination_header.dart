// lib/widgets/virtual_tour/vt_destination_header.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart'; // ← tambah
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';

/// Header bergaya frosted glass yang menutupi seluruh area atas layar —
/// mulai dari status bar hingga bawah teks lokasi.
class VtDestinationHeader extends StatelessWidget {
  final DestinationModel destination;
  final double topOffset;

  const VtDestinationHeader({
    super.key,
    required this.destination,
    required this.topOffset,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final hPad = w * 0.05;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(hPad, topOffset, hPad, 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.55, 1.0],
              colors: [
                // Gradient header — nilai spesifik efek visual, dibiarkan inline
                Colors.black.withValues(alpha: 0.70),
                Colors.black.withValues(alpha: 0.38),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Kiri: badge + nama + lokasi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _VtBadge(screenWidth: w),
                    SizedBox(height: w * 0.015),
                    Text(
                      destination.name,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.textOnDark, // ← was Colors.white
                        fontSize: w * 0.048,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        shadows: const [
                          Shadow(
                            color: Color(0x99000000),
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: w * 0.01),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: w * 0.031,
                          color:
                              AppColors
                                  .vtTextSubtle, // ← was Colors.white.withValues(alpha: 0.65)
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            destination.location,
                            style: AppTextStyles.caption.copyWith(
                              color:
                                  AppColors
                                      .vtTextSubtle, // ← was Colors.white.withValues(alpha: 0.65)
                              fontSize: w * 0.029,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Kanan: branding — 40% opacity dibiarkan inline (tidak ada token yang cukup dekat)
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'WISATA',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.50),
                        fontSize: w * 0.022,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    Text(
                      'TRENGGALEK',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.50),
                        fontSize: w * 0.022,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _VtBadge ──────────────────────────────────────────────────────────────────

class _VtBadge extends StatelessWidget {
  final double screenWidth;
  const _VtBadge({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenWidth * 0.008,
      ),
      decoration: BoxDecoration(
        // 0.18 dan 0.35 dibiarkan inline — efek glass badge spesifik widget ini
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.view_in_ar_rounded,
            size: screenWidth * 0.026,
            color: AppColors.textOnDark, // ← was Colors.white
          ),
          SizedBox(width: screenWidth * 0.015),
          Text(
            'VIRTUAL TOUR 360°',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textOnDark, // ← was Colors.white
              fontSize: screenWidth * 0.022,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
