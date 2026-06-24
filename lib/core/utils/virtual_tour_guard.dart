// lib/core/utils/virtual_tour_guard.dart
//
// Guard empat lapis untuk mencegah Maps JavaScript API Street View
// dipanggil secara berlebihan dan menghasilkan tagihan tak terduga.
//
//   Lapis 1 — Debounce      : tolak tap ulang dalam [_debounceDuration]
//   Lapis 2 — Cache         : koordinat yang sama tidak hitung ulang ke cap
//   Lapis 3 — Session cap   : hard limit [sessionCap] load per sesi app
//   Lapis 4 — Nav cap       : hard limit [navigationCap] langkah navigasi
//                             per sesi app (setiap klik panah = 1 langkah)
//
// State bersifat in-memory — reset otomatis setiap app di-restart.

class VirtualTourGuard {
  VirtualTourGuard._();

  // ── Konfigurasi (public agar bisa direferensikan dari halaman lain) ────────

  /// Maksimum initial load Street View per sesi app.
  static const int sessionCap = 20;

  /// Maksimum langkah navigasi (klik panah / clickToGo) per sesi app.
  /// Setiap langkah = 1 Dynamic Street View API call (billable).
  /// 50 langkah × $0,014 = $0,70 — aman untuk thesis demo.
  static const int navigationCap = 50;

  /// Window waktu debounce setelah tap tombol 360°.
  static const Duration _debounceDuration = Duration(seconds: 2);

  // ── State internal ────────────────────────────────────────────────────────
  static int _sessionCount = 0;
  static int _navigationCount = 0;
  static DateTime? _lastTap;
  static final Set<String> _visitedCoords = {};

  // ── Getters publik ────────────────────────────────────────────────────────

  /// true jika tap terakhir terjadi kurang dari [_debounceDuration] yang lalu.
  static bool get isDebouncing =>
      _lastTap != null &&
      DateTime.now().difference(_lastTap!) < _debounceDuration;

  /// true jika jumlah initial load sesi ini sudah mencapai [sessionCap].
  static bool get isLimitReached => _sessionCount >= sessionCap;

  /// true jika jumlah langkah navigasi sesi ini sudah mencapai [navigationCap].
  static bool get isNavigationLimitReached =>
      _navigationCount >= navigationCap;

  /// Sisa slot initial load yang tersedia sesi ini.
  static int get remaining =>
      (sessionCap - _sessionCount).clamp(0, sessionCap);

  /// Sisa langkah navigasi yang tersedia sesi ini.
  static int get navigationRemaining =>
      (navigationCap - _navigationCount).clamp(0, navigationCap);

  /// true jika koordinat ini sudah pernah di-load dalam sesi yang berjalan.
  static bool hasVisited(double lat, double lng) =>
      _visitedCoords.contains(_coordKey(lat, lng));

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Catat timestamp tap — aktifkan debounce window.
  /// Panggil tepat sebelum Navigator.push ke VirtualTourPage.
  static void markTap() => _lastTap = DateTime.now();

  /// Catat satu initial load Street View.
  /// Dipanggil di VirtualTourPage saat panorama pertama kali diload.
  static void recordLoad(double lat, double lng) {
    _sessionCount++;
    _visitedCoords.add(_coordKey(lat, lng));
  }

  /// Catat satu langkah navigasi (klik panah / clickToGo).
  /// Dipanggil setiap kali event pano_changed diterima dari WebView.
  static void recordNavigationStep() => _navigationCount++;

  // ── Internal ──────────────────────────────────────────────────────────────
  static String _coordKey(double lat, double lng) =>
      '${lat.toStringAsFixed(3)}_${lng.toStringAsFixed(3)}';
}