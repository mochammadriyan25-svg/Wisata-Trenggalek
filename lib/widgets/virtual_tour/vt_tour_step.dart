// lib/widgets/virtual_tour/vt_tour_step.dart

/// Model satu langkah dalam guided virtual tour.
///
/// [heading] : arah horizontal kamera (0–360°, 0 = Utara)
/// [pitch]   : arah vertikal kamera (-90 = bawah, +90 = atas, 0 = lurus)
///
/// Digunakan oleh [VirtualTourPage] untuk menginjeksi setPov() ke Street View
/// via JavaScript, dan oleh [VtGuideNarration] untuk menampilkan narasi.
class VtTourStep {
  final String title;
  final String narration;
  final double heading;
  final double pitch;

  const VtTourStep({
    required this.title,
    required this.narration,
    required this.heading,
    this.pitch = 0.0,
  });
}