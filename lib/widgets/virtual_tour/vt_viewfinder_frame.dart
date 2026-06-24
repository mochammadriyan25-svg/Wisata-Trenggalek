// lib/widgets/virtual_tour/vt_viewfinder_frame.dart
import 'package:flutter/material.dart';

/// Overlay dekoratif 4 sudut bracket (viewfinder kamera) yang sepenuhnya
/// responsif — ukuran bracket dihitung sebagai persentase ukuran layar
/// sehingga tampak proporsional di semua ukuran HP.
///
/// Bracket berdenyut pelan (opacity 0.30 → 0.70) untuk kesan "aktif".
/// Widget ini IgnorePointer agar tidak menghalangi interaksi Street View.
class VtViewfinderFrame extends StatefulWidget {
  const VtViewfinderFrame({super.key});

  @override
  State<VtViewfinderFrame> createState() => _VtViewfinderFrameState();
}

class _VtViewfinderFrameState extends State<VtViewfinderFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.30,
      end: 0.70,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _opacity,
        builder:
            (_, __) => CustomPaint(
              painter: _BracketPainter(opacity: _opacity.value),
              child: const SizedBox.expand(),
            ),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final double opacity;
  const _BracketPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(opacity)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    // Responsif: margin dan arm dihitung dari persentase layar
    final margin = size.width * 0.055; // ~5.5% lebar layar
    final arm = size.width * 0.075; // ~7.5% lebar layar

    final w = size.width;
    final h = size.height;

    // ── Sudut kiri atas
    canvas.drawLine(
      Offset(margin, margin + arm),
      Offset(margin, margin),
      paint,
    );
    canvas.drawLine(
      Offset(margin, margin),
      Offset(margin + arm, margin),
      paint,
    );

    // ── Sudut kanan atas
    canvas.drawLine(
      Offset(w - margin - arm, margin),
      Offset(w - margin, margin),
      paint,
    );
    canvas.drawLine(
      Offset(w - margin, margin),
      Offset(w - margin, margin + arm),
      paint,
    );

    // ── Sudut kiri bawah
    canvas.drawLine(
      Offset(margin, h - margin - arm),
      Offset(margin, h - margin),
      paint,
    );
    canvas.drawLine(
      Offset(margin, h - margin),
      Offset(margin + arm, h - margin),
      paint,
    );

    // ── Sudut kanan bawah
    canvas.drawLine(
      Offset(w - margin - arm, h - margin),
      Offset(w - margin, h - margin),
      paint,
    );
    canvas.drawLine(
      Offset(w - margin, h - margin),
      Offset(w - margin, h - margin - arm),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BracketPainter old) => old.opacity != opacity;
}
  