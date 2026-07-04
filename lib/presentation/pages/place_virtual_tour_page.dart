// lib/presentation/pages/place_virtual_tour_page.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_webview_section.dart';

/// Halaman Virtual Tour untuk PlaceModel (tempat ibadah & fasilitas kesehatan).
///
/// Berbeda dari VirtualTourPage (untuk DestinationModel) — ini view-only,
/// tidak ada fitur navigasi wisata (guide, steps, dsb).
/// Langsung menggunakan VtWebviewSection yang sama persis.
///
/// Mode yang dipakai ditentukan oleh parameter:
/// - image360Url != null → mode foto 360° UGC (Pannellum)
/// - panoId != null → mode Photo Sphere (Maps JS API)
/// - keduanya null → Street View biasa berdasarkan koordinat
class PlaceVirtualTourPage extends StatefulWidget {
  final String name;
  final double latitude;
  final double longitude;
  final String? panoId;
  final String? image360Url;
  final double initialHeading;
  final double initialPitch;

  const PlaceVirtualTourPage({
    super.key,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.panoId,
    this.image360Url,
    this.initialHeading = 0.0,
    this.initialPitch = 0.0,
  });

  @override
  State<PlaceVirtualTourPage> createState() => _PlaceVirtualTourPageState();
}

class _PlaceVirtualTourPageState extends State<PlaceVirtualTourPage> {
  double _heading = 0.0;
  double _pitch = 0.0;
  WebViewController? _controller;

  bool get _isImage360 =>
      widget.image360Url != null && widget.image360Url!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _heading = widget.initialHeading;
    _pitch = widget.initialPitch;
  }

  void _onControllerReady(WebViewController ctrl) {
    _controller = ctrl;
    // Nonaktifkan navigasi Street View agar user tetap di titik ini
    if (!_isImage360) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _controller?.runJavaScript('disableNavigation();');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.vtBackground,
      body: Stack(
        children: [
          // WebView VT
          VtWebviewSection(
            latitude: widget.latitude,
            longitude: widget.longitude,
            panoId: widget.panoId,
            image360Url: widget.image360Url,
            initialHeading: widget.initialHeading,
            initialPitch: widget.initialPitch,
            onControllerReady: _onControllerReady,
            onPovChanged: (h, p) {
              if (mounted) setState(() { _heading = h; _pitch = p; });
            },
            onCoverageError: () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Panorama tidak tersedia di koordinat/URL ini.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: AppSpacing.md,
            child: _GlassButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),

          // Nama tempat
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: 64,
            right: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.vtGlassFill,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.vtDialogBorder),
              ),
              child: Text(
                widget.name,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textOnDark,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Heading / Pitch badge
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.vtGlassFill,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusLg),
                  border:
                      Border.all(color: AppColors.vtDialogBorder),
                ),
                child: Text(
                  'Heading: ${_heading.round()}°   Pitch: ${_pitch.round()}°',
                  style: AppTextStyles.vtSwitchLabel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.vtGlassFill,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: AppColors.textOnDark, size: 20),
          ),
        ),
      );
}