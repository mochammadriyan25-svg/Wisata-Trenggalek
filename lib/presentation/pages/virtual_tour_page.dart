// lib/presentation/pages/virtual_tour_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/core/utils/virtual_tour_guard.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_webview_section.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_overlay_controls.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_guide_narration.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_info_panel.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_tour_step.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_limit_screen.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_viewfinder_frame.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_compass.dart';
import 'package:aplikasi_wisata/widgets/virtual_tour/vt_destination_header.dart';
// ↑ vt_revisit_screen.dart dihapus — revisit ditangani sebelum navigasi

enum VtTourMode { streetView, photoSphere, image360 }

class VirtualTourPage extends StatefulWidget {
  final DestinationModel destination;
  final VtTourMode tourMode;

  const VirtualTourPage({
    super.key,
    required this.destination,
    this.tourMode = VtTourMode.streetView,
  });

  @override
  State<VirtualTourPage> createState() => _VirtualTourPageState();
}

class _VirtualTourPageState extends State<VirtualTourPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;

  bool _isLimitReached = false;
  // _isRevisit dihapus — revisit check sekarang di DetailHeroSection

  WebViewController? _webViewController;
  bool _isAutoTourActive = false;
  bool _isInfoVisible = false;
  int _currentStepIndex = 0;
  Timer? _stepTimer;
  late final List<VtTourStep> _tourSteps;

  // Heading kompas pakai ValueNotifier agar update tidak me-rebuild
  // seluruh halaman tiap 200ms (penyebab tap tombol switch kadang hilang)
  late final ValueNotifier<double> _headingNotifier;

  late VtTourMode _activeMode;

  // Guard agar tap beruntun tidak memicu switch mode ganda
  bool _isSwitching = false;

  // REVISI (presisi timing): visibility switch button DIPISAH dari
  // _isInfoVisible. Kalau langsung pakai `!_isInfoVisible`, begitu panel
  // mulai close, switch button langsung bisa di-tap lagi padahal VtInfoPanel
  // masih dalam proses slide-down (300ms) — celah ini bisa bikin tombol
  // "ketabrak" ulang dengan panel yang belum sepenuhnya hilang.
  // Solusi: switch button hanya boleh muncul/aktif lagi SETELAH animasi
  // close panel benar-benar selesai (lihat _closeInfoPanel & _kInfoPanelCloseDuration).
  bool _isSwitchButtonVisible = true;
  Timer? _switchButtonDelayTimer;

  // Durasi terlama dari animasi penutupan VtInfoPanel (AnimatedSlide 300ms
  // vs AnimatedOpacity 250ms) — dipakai sebagai patokan delay agar switch
  // button benar-benar menunggu panel selesai hilang dari layar.
  static const _kInfoPanelCloseDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _activeMode = widget.tourMode;
    // Inisialisasi heading dari config sesuai mode aktif agar kompas tepat
    _headingNotifier = ValueNotifier(_headingForMode(_activeMode));
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entryCtrl.forward();
    _checkGuard();
    _tourSteps = _buildTourSteps();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _stepTimer?.cancel();
    _switchButtonDelayTimer?.cancel();
    _headingNotifier.dispose();
    super.dispose();
  }

  // ── Guard — hanya cek limit, revisit dihandle DetailHeroSection ──────────

  void _checkGuard() {
    if (VirtualTourGuard.isLimitReached) {
      _isLimitReached = true;
    }
    // recordLoad dan revisit check dipindah ke DetailHeroSection._handleTourTap
    // agar dialog revisit muncul di atas detail page, bukan membuka screen baru.
  }

  // ── Switch mode ───────────────────────────────────────────────────────────

  VtTourMode? get _switchTarget {
    final dest = widget.destination;
    return switch (_activeMode) {
      VtTourMode.streetView =>
        dest.hasImage360
            ? VtTourMode.image360
            : dest.hasPhotoSphere
            ? VtTourMode.photoSphere
            : null,
      VtTourMode.image360 => VtTourMode.streetView,
      VtTourMode.photoSphere => VtTourMode.streetView,
    };
  }

  void _switchMode(VtTourMode newMode) {
    // Cegah switch ganda saat WebView lama masih rebuild
    if (_isSwitching || newMode == _activeMode) return;
    _isSwitching = true;
    _stopAutoTour();
    // Reset heading kompas tanpa setState (cukup notifier)
    _headingNotifier.value = _headingForMode(newMode);
    setState(() {
      _activeMode = newMode;
      _webViewController = null;
    });
    // Lepas guard setelah frame berikutnya — cukup untuk mencegah
    // pointer-up beruntun memicu switch dua kali.
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _isSwitching = false;
    });
  }

  // ── Heading/Pitch awal per mode ──────────────────────────────────────────
  // Street View & Photo Sphere → pakai config streetView (lat/lng based)
  // Foto 360°                  → pakai config image360 (orientasi foto UGC)

  double _headingForMode(VtTourMode mode) => switch (mode) {
    VtTourMode.image360 => widget.destination.image360.heading,
    VtTourMode.streetView ||
    VtTourMode.photoSphere => widget.destination.streetView.heading,
  };

  double _pitchForMode(VtTourMode mode) => switch (mode) {
    VtTourMode.image360 => widget.destination.image360.pitch,
    VtTourMode.streetView ||
    VtTourMode.photoSphere => widget.destination.streetView.pitch,
  };

  // ── Navigation & heading ──────────────────────────────────────────────────

  void _onPanoramaNavigated() {
    if (VirtualTourGuard.isNavigationLimitReached) {
      _webViewController?.runJavaScript('disableNavigation();');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Batas navigasi (${VirtualTourGuard.navigationCap} langkah) tercapai.',
            ),
            backgroundColor: AppColors.vtScrimDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
      return;
    }
    VirtualTourGuard.recordNavigationStep();
  }

  void _onHeadingChanged(double heading) {
    // Update notifier saja — TIDAK setState — agar hanya kompas yang
    // rebuild, bukan seluruh Stack (WebView + tombol switch).
    _headingNotifier.value = heading;
  }

  void _onCoverageError() {
    if (!mounted) return;
    final msg = switch (_activeMode) {
      VtTourMode.image360 =>
        'Foto 360° tidak dapat dimuat. Periksa image360Url.',
      VtTourMode.photoSphere => 'Photo Sphere tidak tersedia. Periksa panoId.',
      VtTourMode.streetView => 'Street View tidak tersedia di koordinat ini.',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        action: SnackBarAction(
          label: 'Kembali',
          textColor: AppColors.textOnDark,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  // ── Tour logic ────────────────────────────────────────────────────────────

  List<VtTourStep> _buildTourSteps() {
    final name = widget.destination.name;
    final desc = widget.destination.description;
    final short = desc.length > 90 ? '${desc.substring(0, 90)}...' : desc;
    final rating = widget.destination.rating.toStringAsFixed(1);
    final loc = widget.destination.location;
    return [
      VtTourStep(
        title: 'Selamat Datang di $name',
        narration: short,
        heading: 0,
        pitch: 0,
      ),
      VtTourStep(
        title: 'Jelajahi Area Sekitar',
        narration: 'Putar pandangan untuk melihat sekeliling $name.',
        heading: 90,
        pitch: 5,
      ),
      VtTourStep(
        title: 'Sudut Pandang Berbeda',
        narration: 'Temukan keindahan $name — bernilai $rating/5.0.',
        heading: 180,
        pitch: 0,
      ),
      VtTourStep(
        title: 'Panorama $loc',
        narration: 'Nikmati panorama menyeluruh sebelum berkunjung.',
        heading: 270,
        pitch: -5,
      ),
    ];
  }

  void _toggleAutoTour() =>
      _isAutoTourActive ? _stopAutoTour() : _startAutoTour();

  void _startAutoTour() {
    setState(() {
      _isAutoTourActive = true;
      _currentStepIndex = 0;
    });
    _executeStep(0);
  }

  void _executeStep(int index) {
    if (!mounted || index >= _tourSteps.length) {
      _stopAutoTour();
      return;
    }
    final step = _tourSteps[index];
    setState(() => _currentStepIndex = index);
    _webViewController?.runJavaScript(
      'setPov(${step.heading},${step.pitch},1);',
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_isAutoTourActive) {
        _webViewController?.runJavaScript('startRotate(0.15);');
      }
    });
    _stepTimer = Timer(
      const Duration(seconds: 5),
      () => _executeStep(index + 1),
    );
  }

  void _stopAutoTour() {
    _stepTimer?.cancel();
    _webViewController?.runJavaScript('stopRotate();');
    if (mounted) setState(() => _isAutoTourActive = false);
  }

  // ── Info panel open/close (dengan delay presisi untuk switch button) ─────
  // Dipanggil dari tombol info di VtOverlayControls (toggle) DAN dari
  // tombol X di dalam VtInfoPanel (onClose) — keduanya HARUS lewat sini,
  // bukan setState langsung ke _isInfoVisible, supaya switch button selalu
  // konsisten timing-nya di kedua jalur tersebut.

  void _toggleInfoPanel() {
    if (_isInfoVisible) {
      _closeInfoPanel();
    } else {
      _openInfoPanel();
    }
  }

  void _openInfoPanel() {
    // Saat membuka: sembunyikan switch button SEKETIKA (tidak perlu delay —
    // tidak ada risiko "tap dini" di arah ini, justru kalau telat
    // disembunyikan, sempat ke-tap pas panel baru naik sedikit).
    _switchButtonDelayTimer?.cancel();
    setState(() {
      _isInfoVisible = true;
      _isSwitchButtonVisible = false;
    });
  }

  void _closeInfoPanel() {
    setState(() => _isInfoVisible = false);
    // Tunggu sampai animasi slide-down VtInfoPanel BENAR-BENAR selesai
    // (_kInfoPanelCloseDuration) sebelum switch button diizinkan muncul
    // & menerima tap lagi. Ini yang menutup celah timing sebelumnya.
    _switchButtonDelayTimer?.cancel();
    _switchButtonDelayTimer = Timer(_kInfoPanelCloseDuration, () {
      if (mounted) setState(() => _isSwitchButtonVisible = true);
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLimitReached) return const VtLimitScreen();
    // ↑ _isRevisit check dihapus

    final dest = widget.destination;
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final backBtnHeight = w * 0.11;
    final headerTextOffset = topPad + AppSpacing.sm + backBtnHeight + 6;
    final estimatedHeaderHeight = headerTextOffset + 22 + 16 + 60 + 18 + 22;
    final frameTop = estimatedHeaderHeight;
    final frameBottom = botPad + h * 0.13;

    // ── FIX: hitung tinggi aktual glass control bar (VtOverlayControls)
    // agar tombol switch TIDAK overlap dengan area hit-test-nya.
    //
    // Breakdown VtOverlayControls bottom strip:
    //   - gradient                         : 60
    //   - padding atas frosted container    : 14
    //   - konten tombol (_GlassLabelButton)  : ~40  (padding vertikal 11*2 + ikon/teks)
    //   - padding bawah frosted container    : 12 + botPad (safe area)
    //
    // Container frosted itu punya `color`, sehingga OPAQUE untuk hit-test
    // meski tampak transparan/blur — apa pun yang berada di rentang tinggi
    // ini akan "ketelan" tap-nya kalau VtOverlayControls dirender di atas.
    const glassBarGradientHeight = 60.0;
    const glassBarTopPadding = 14.0;
    const glassBarContentHeight = 40.0;
    const glassBarBottomPaddingExtra = 12.0;
    // REVISI: gap aman diperkecil dari 16 → 6. Tombol switch sekarang boleh
    // duduk lebih dekat/dikit overlap secara VISUAL dengan glass bar, karena
    // fix z-order (tombol switch = child TERAKHIR di Stack) sudah menjamin
    // tombol ini selalu menang hit-test duluan, jadi tap tidak akan ketelan
    // lagi walau jaraknya dipersempit. Ini yang membuat tombol bisa digeser
    // "lebih ke bawah" sesuai requested.
    const safeGapAboveGlassBar = 6.0;

    final glassBarHeight =
        glassBarGradientHeight +
        glassBarTopPadding +
        glassBarContentHeight +
        glassBarBottomPaddingExtra +
        botPad;

    // Posisi bottom tombol switch sekarang dijamin berada DI ATAS glass bar,
    // bukan lagi pakai angka ajaib "frameBottom - 18" yang ternyata jatuh
    // tepat di dalam rentang tinggi glass bar (itulah sebabnya tap kadang
    // ketelan oleh Container frosted glass di VtOverlayControls).
    final switchButtonBottom = glassBarHeight + safeGapAboveGlassBar;

    final activePanoId =
        _activeMode == VtTourMode.photoSphere ? dest.panoId : null;
    final activeImage360 =
        _activeMode == VtTourMode.image360 ? dest.image360.url : null;
    final switchTarget = _switchTarget;

    return Scaffold(
      backgroundColor: AppColors.vtBackground,
      body: FadeTransition(
        opacity: _entryFade,
        child: Stack(
          children: [
            KeyedSubtree(
              key: ValueKey(_activeMode),
              child: VtWebviewSection(
                latitude: dest.latitude,
                longitude: dest.longitude,
                panoId: activePanoId,
                image360Url: activeImage360,
                // Heading & pitch awal dari Firebase — kamera langsung
                // menghadap arah yang ditentukan saat virtual tour dibuka
                initialHeading: _headingForMode(_activeMode),
                initialPitch: _pitchForMode(_activeMode),
                onControllerReady:
                    (c) => setState(() => _webViewController = c),
                onPanoramaNavigated: _onPanoramaNavigated,
                onHeadingChanged: _onHeadingChanged,
                onCoverageError: _onCoverageError,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: VtDestinationHeader(
                destination: dest,
                topOffset: headerTextOffset,
              ),
            ),
            Positioned(
              top: frameTop,
              bottom: frameBottom,
              left: 0,
              right: 0,
              child: const IgnorePointer(child: VtViewfinderFrame()),
            ),
            Positioned(
              top: topPad + AppSpacing.sm,
              right: AppSpacing.md,
              child: ValueListenableBuilder<double>(
                valueListenable: _headingNotifier,
                builder: (_, heading, __) => VtCompass(heading: heading),
              ),
            ),
            // REVISI: badge mode digeser lebih ke bawah (66 → 92) supaya
            // tidak lagi menutupi teks header (nama/lokasi/rating) di
            // VtDestinationHeader. Ukurannya sendiri diperkecil di dalam
            // widget _ModeBadge (padding & ikon lebih kecil).
            Positioned(
              top: headerTextOffset + 70,
              left: AppSpacing.md + 3,
              child: _ModeBadge(mode: _activeMode),
            ),
            // ── FIX (z-order): VtOverlayControls dipindah ke SINI, SEBELUM
            // tombol switch. Di Flutter Stack, child yang dideklarasikan
            // LEBIH BELAKANGAN akan dirender di atas dan di-hit-test LEBIH
            // DULU. Sebelumnya tombol switch dideklarasikan SEBELUM
            // VtOverlayControls — artinya glass bar yang opaque untuk
            // hit-test selalu "menang" dan mencegat tap sebelum sampai ke
            // tombol switch, persis di rentang tinggi yang overlap.
            //
            // Sekarang tombol switch ditaruh PALING BELAKANG (lihat di
            // bawah) sebagai pemenang hit-test, sebagai pengaman tambahan
            // di luar fix reposisi (switchButtonBottom) di atas.
            VtOverlayControls(
              isAutoTourActive: _isAutoTourActive,
              isInfoVisible: _isInfoVisible,
              onBack: () {
                _stopAutoTour();
                Navigator.pop(context);
              },
              onToggleAutoTour: _toggleAutoTour,
              // REVISI: dulu langsung setState toggle _isInfoVisible, sekarang
              // lewat _toggleInfoPanel supaya delay presisi switch button
              // (lihat _closeInfoPanel) selalu konsisten lewat jalur ini.
              onToggleInfo: _toggleInfoPanel,
            ),
            if (_isAutoTourActive)
              Positioned(
                top: frameTop + 8,
                left: w * 0.04,
                right: w * 0.04,
                child: VtGuideNarration(
                  step: _tourSteps[_currentStepIndex],
                  currentIndex: _currentStepIndex,
                  totalSteps: _tourSteps.length,
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                offset: _isInfoVisible ? Offset.zero : const Offset(0, 1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _isInfoVisible ? 1.0 : 0.0,
                  child: VtInfoPanel(
                    destination: dest,
                    // REVISI: dulu langsung setState false, sekarang lewat
                    // _closeInfoPanel supaya tombol X di panel juga
                    // memicu delay presisi yang sama seperti toggle dari
                    // VtOverlayControls.
                    onClose: _closeInfoPanel,
                  ),
                ),
              ),
            ),
            // ── FIX: tombol switch sekarang berada di POSISI TERAKHIR
            // (paling atas secara z-order/hit-test) DAN di posisi vertikal
            // baru (switchButtonBottom) yang sudah dipastikan tidak overlap
            // dengan glass control bar. Kombinasi reposisi + reorder ini
            // membuat tombol selalu menerima tap secara konsisten.
            //
            // REVISI: karena tombol ini berada paling belakang di Stack
            // (pemenang z-order), dia ikut "melayang" di atas VtInfoPanel
            // saat panel itu di-slide naik dari bawah — terlihat aneh,
            // seolah tombol switch berdiri sendiri menutupi panel info.
            // Fix: sembunyikan (fade-out) DAN non-aktifkan (IgnorePointer)
            // tombol switch, dikontrol oleh _isSwitchButtonVisible (BUKAN
            // _isInfoVisible langsung) — supaya saat panel close, tombol
            // baru benar-benar boleh muncul & menerima tap SETELAH animasi
            // slide-down panel selesai (lihat _closeInfoPanel). Tanpa
            // pemisahan ini, ada celah ~50-100ms di mana tombol sudah bisa
            // ditap padahal panel masih kelihatan turun di layar.
            if (switchTarget != null)
              Positioned(
                bottom: switchButtonBottom,
                left: 0,
                right: 0,
                child: Center(
                  child: IgnorePointer(
                    ignoring: !_isSwitchButtonVisible,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      opacity: _isSwitchButtonVisible ? 1.0 : 0.0,
                      child: _SwitchModeButton(
                        currentMode: _activeMode,
                        targetMode: switchTarget,
                        onSwitch: () => _switchMode(switchTarget),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── _ModeBadge ────────────────────────────────────────────────────────────────

class _ModeBadge extends StatelessWidget {
  final VtTourMode mode;
  const _ModeBadge({required this.mode});

  @override
  Widget build(BuildContext context) {
    final (color, bg, icon, label) = switch (mode) {
      VtTourMode.streetView => (
        AppColors.vtStreetViewAccent,
        AppColors.vtStreetViewBg,
        Icons.directions_walk_rounded,
        'Street View',
      ),
      VtTourMode.photoSphere => (
        AppColors.vtPhotoSphereAccent,
        AppColors.vtPhotoSphereBg,
        Icons.panorama_photosphere_rounded,
        'Photo Sphere',
      ),
      VtTourMode.image360 => (
        AppColors.vtImage360Accent,
        AppColors.vtImage360Bg,
        Icons.image_rounded,
        'Foto 360°',
      ),
    };
    // REVISI: badge diperkecil — padding & ikon diturunkan, dan fontSize
    // teks di-override sedikit lebih kecil dari AppTextStyles.vtBadgeLabel
    // (kalau di tema aslinya sudah pas, tinggal hapus .copyWith di bawah).
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusBadge),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 8, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.vtBadgeLabel.copyWith(
              fontSize: (AppTextStyles.vtBadgeLabel.fontSize ?? 11) - 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── _SwitchModeButton ─────────────────────────────────────────────────────────

class _SwitchModeButton extends StatelessWidget {
  final VtTourMode currentMode;
  final VtTourMode targetMode;
  final VoidCallback onSwitch;

  const _SwitchModeButton({
    required this.currentMode,
    required this.targetMode,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (targetMode) {
      VtTourMode.streetView => (
        Icons.directions_walk_rounded,
        'Street View',
        AppColors.vtStreetViewAccent,
      ),
      VtTourMode.photoSphere => (
        Icons.panorama_photosphere_rounded,
        'Photo Sphere',
        AppColors.vtPhotoSphereAccent,
      ),
      VtTourMode.image360 => (
        Icons.image_rounded,
        'Foto 360°',
        AppColors.vtImage360Accent,
      ),
    };
    return Listener(
      // Pakai Listener (bukan GestureDetector) agar tap langsung fire pada
      // pointer event mentah, tanpa ikut "gesture arena" yang direbut WebView
      // panorama di belakangnya. Ini memperbaiki bug tombol switch yang
      // kadang harus ditap 2x.
      behavior: HitTestBehavior.opaque,
      onPointerUp: (_) => onSwitch(),
      child: Container(
        // REVISI: padding diperkecil (md/9 → sm+2/6) supaya tombol tidak
        // terlalu besar.
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.vtGlassFill,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: color.withOpacity(0.4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // REVISI: ikon diperkecil 15 → 12
            Icon(
              Icons.swap_horiz_rounded,
              color: AppColors.vtTextSubtle,
              size: 12,
            ),
            const SizedBox(width: 6),
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(
              'Beralih ke $label',
              style: AppTextStyles.vtSwitchLabel.copyWith(
                fontSize: (AppTextStyles.vtSwitchLabel.fontSize ?? 12) - 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
