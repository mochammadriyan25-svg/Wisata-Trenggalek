// lib/widgets/virtual_tour/vt_limit_screen.dart
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';

/// Layar yang ditampilkan ketika session cap [VirtualTourGuard._sessionCap]
/// telah tercapai dan tidak ada slot load Street View yang tersisa.
///
/// Ditampilkan oleh [VirtualTourPage] sebagai pengganti WebView —
/// sehingga Maps JavaScript API tidak pernah dipanggil.
class VtLimitScreen extends StatelessWidget {
  const VtLimitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white38,
                  size: 56,
                ),
                const SizedBox(height: 20),
                Text(
                  'Batas Sesi Tercapai',
                  style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  'Sesi ini sudah mencapai batas penggunaan virtual tour.\n'
                  'Restart aplikasi untuk melanjutkan.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white54, fontSize: 13, height: 1.6),
                ),
                const SizedBox(height: 28),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white70, size: 18),
                  label: Text(
                    'Kembali',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}