// lib/widgets/package/package_destination_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/destination_model.dart';
import '../../providers/destination_provider.dart';
import '../../presentation/pages/detail_page.dart';

/// Menampilkan daftar destinasi yang termasuk dalam paket wisata.
/// Data destinasi diambil dari [DestinationProvider] berdasarkan [destinationIds].
///
/// Selama data belum tersedia (list kosong), menampilkan indikator loading.
/// Setiap item dapat ditekan untuk navigasi ke [DetailPage] destinasi terkait.
///
/// [destinationIds] : list id destinasi dari PackageModel.destinationIds
class PackageDestinationList extends StatelessWidget {
  final List<String> destinationIds;
  const PackageDestinationList({super.key, required this.destinationIds});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DestinationProvider>();
    final destinations =
        provider.allDestinations
            .where((d) => destinationIds.contains(d.id))
            .toList();

    if (destinations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Memuat destinasi...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children:
          destinations.map((d) => _DestinationItem(destination: d)).toList(),
    );
  }
}

/// Item tunggal destinasi dalam daftar paket.
/// Menampilkan thumbnail, nama, lokasi, dan rating.
/// Tap untuk navigasi ke [DetailPage].
class _DestinationItem extends StatelessWidget {
  final DestinationModel destination;
  const _DestinationItem({required this.destination});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(destination: destination),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.7),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Image.network(
                destination.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(
                        Icons.landscape_rounded,
                        color: AppColors.textOnDark,
                        size: 24,
                      ),
                    ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 11,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          destination.location,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 11,
                        color: Color(0xFFE8A020),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        destination.rating.toStringAsFixed(1),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Chevron
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
