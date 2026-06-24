// lib/widgets/virtual_tour/vt_compass.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';

/// Kompas interaktif yang menampilkan arah pandang kamera Street View
/// secara real-time.
///
/// [heading] diperbarui setiap kali user memutar kamera — dikirim dari
/// JavaScript (event pov_changed) via CompassChannel ke Flutter.
/// Jarum kompas berputar berlawanan dengan heading agar N selalu
/// menunjuk ke Utara relatif terhadap arah pandang user.
///
/// Keberadaan kompas ini mempertegas bahwa Street View berjalan
/// di dalam kontrol penuh aplikasi — bukan antarmuka Google Maps.
class VtCompass extends StatelessWidget {
  final double heading;
  const VtCompass({super.key, required this.heading});

  /// Konversi heading ke label arah mata angin
  String get _cardinalLabel {
    final h = heading % 360;
    if (h < 22.5 || h >= 337.5) return 'U';
    if (h < 67.5) return 'TL';
    if (h < 112.5) return 'T';
    if (h < 157.5) return 'TG';
    if (h < 202.5) return 'S';
    if (h < 247.5) return 'BD';
    if (h < 292.5) return 'B';
    return 'BL';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.30), width: 1),
      ),
      child: Stack(alignment: Alignment.center, children: [
        // ── Lingkaran skala kompas (dekoratif)
        Positioned.fill(
          child: CustomPaint(painter: _CompassScalePainter()),
        ),

        // ── Jarum kompas (berputar berlawanan heading)
        Transform.rotate(
          angle: -heading * math.pi / 180,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ujung utara (merah)
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              // Ujung selatan (putih)
              Container(
                width: 3,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),

        // ── Derajat heading (pojok bawah dalam circle)
        Positioned(
          bottom: 8,
          child: Text(
            '${heading.round()}°',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withOpacity(0.70),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),

        // ── Label arah mata angin
        Positioned(
          top: 7,
          child: Text(
            _cardinalLabel,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ]),
    );
  }
}

/// Painter untuk garis-garis skala kompas (tick marks)
class _CompassScalePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.20)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Gambar 8 tick mark di sekeliling lingkaran
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * math.pi / 180;
      final inner = Offset(
        center.dx + (radius - 4) * math.cos(angle),
        center.dy + (radius - 4) * math.sin(angle),
      );
      final outer = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}