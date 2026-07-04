// lib/presentation/admin/destination/admin_vt_preview_page.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_webview_section.dart';

class AdminVtPreviewPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? panoId;
  final String? image360Url;
  final double initialHeading;
  final double initialPitch;

  const AdminVtPreviewPage({
    super.key,
    required this.latitude,
    required this.longitude,
    this.panoId,
    this.image360Url,
    this.initialHeading = 0.0,
    this.initialPitch = 0.0,
  });

  @override
  State<AdminVtPreviewPage> createState() => _AdminVtPreviewPageState();
}

class _AdminVtPreviewPageState extends State<AdminVtPreviewPage> {
  double _heading = 0.0;
  double _pitch = 0.0;
  WebViewController? _controller;
  bool get _isImage360 => widget.image360Url != null && widget.image360Url!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _heading = widget.initialHeading;
    _pitch = widget.initialPitch;
  }

  void _onControllerReady(WebViewController controller) {
    _controller = controller;
    if (!_isImage360) {
      // Delay kecil — beri waktu initSV() (pencarian panorama async)
      // selesai sebelum disableNavigation() dipanggil.
      Future.delayed(const Duration(milliseconds: 800), () {
        _controller?.runJavaScript('disableNavigation();');
      });
    }
  }

  void _confirm() => Navigator.pop(context, {'heading': _heading, 'pitch': _pitch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.vtBackground,
      body: Stack(
        children: [
          VtWebviewSection(
            latitude: widget.latitude,
            longitude: widget.longitude,
            panoId: widget.panoId,
            image360Url: widget.image360Url,
            initialHeading: widget.initialHeading,
            initialPitch: widget.initialPitch,
            onControllerReady: _onControllerReady,
            onPovChanged: (h, p) => setState(() {
              _heading = h;
              _pitch = p;
            }),
            onCoverageError: () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Panorama tidak tersedia di koordinat/URL ini.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: AppSpacing.md,
            child: _GlassIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            right: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.vtGlassFill,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.vtDialogBorder),
              ),
              child: Text('Heading: ${_heading.round()}°  Pitch: ${_pitch.round()}°',
                  style: AppTextStyles.vtSwitchLabel),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md + 60,
            child: Text(
              'Geser/drag panorama untuk menentukan arah pandang awal.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: AppColors.vtTextMuted),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _confirm,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Gunakan Orientasi Ini'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.vtGlassFill,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, color: AppColors.textOnDark, size: 20)),
      ),
    );
  }
}