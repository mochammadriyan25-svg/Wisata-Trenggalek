// lib/widgets/package/package_hero_info_overlay.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/package_model.dart';

/// Info overlay di bagian bawah hero image — Skenario A.
/// Menampilkan judul + badge durasi, destinasi, dan rating (realtime).
/// Fade-out dikendalikan oleh parent ([PackageHeroImage]) via [scrollOffset].
class PackageHeroInfoOverlay extends StatelessWidget {
  final PackageModel pkg;
  const PackageHeroInfoOverlay({super.key, required this.pkg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Nama paket
          Text(
            pkg.name,
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.15,
              shadows: [
                const Shadow(
                  color: Color(0x55000000),
                  blurRadius: 16,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Baris badge: durasi + destinasi | rating realtime di pojok kanan
          Row(
            children: [
              _HeroBadge(
                icon: Icons.calendar_today_rounded,
                label: '${pkg.durationDays} Hari ${pkg.durationNights} Malam',
              ),
              const SizedBox(width: 8),
              _HeroBadge(
                icon: Icons.location_on_rounded,
                label: '${pkg.destinationIds.length} Destinasi',
              ),
              const Spacer(),

              // ── RATING REALTIME ─────────────────────────────
              StreamBuilder<DocumentSnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('packages')
                        .doc(pkg.id)
                        .snapshots(),
                builder: (context, snapshot) {
                  double liveRating = pkg.rating;

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data != null && data['rating'] != null) {
                      liveRating = (data['rating'] as num).toDouble();
                    }
                  }

                  return _HeroRatingBadge(label: liveRating.toStringAsFixed(1));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HERO BADGE — style untuk background gelap
// ─────────────────────────────────────────────

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HERO RATING BADGE — di pojok kanan, putih transparan
// ─────────────────────────────────────────────

class _HeroRatingBadge extends StatelessWidget {
  final String label;

  const _HeroRatingBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFD166)),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
