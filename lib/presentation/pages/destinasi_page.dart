// lib/presentation/pages/destinasi_page.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/destination_model.dart';
import '../../data/services/firestore/destination_service.dart';
import '../../widgets/destinations/destination_card.dart';
import '../../widgets/destinations/search_header.dart';
import 'detail_page.dart';

class SearchResultPage extends StatefulWidget {
  final String initialQuery;
  final String initialCategory;

  const SearchResultPage({
    super.key,
    required this.initialQuery,
    required this.initialCategory,
  });

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  final DestinationService _service = DestinationService();

  late String _searchQuery;
  late String _selectedCategory;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery;
    _selectedCategory = widget.initialCategory;
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DestinationModel> _applyFilter(List<DestinationModel> all) {
    return all.where((item) {
      final matchSearch = item.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchCategory =
          _selectedCategory == 'All'
              ? true
              : item.categoryId == _selectedCategory;
      return matchSearch && matchCategory;
    }).toList();
  }

  void _onSearchChanged(String value) => setState(() => _searchQuery = value);

  void _navigateToDetail(DestinationModel destination) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(destination: destination)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header (search + icon badge di dalamnya)
          SearchHeader(
            controller: _searchController,
            onSearchChanged: _onSearchChanged,
          ),

          // ── List
          Expanded(
            child: StreamBuilder<List<DestinationModel>>(
              stream: _service.getAllDestinations(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const _DestinasiLoadingState();
                }

                final filtered = _applyFilter(snapshot.data!);

                if (filtered.isEmpty) {
                  return _DestinasiEmptyState(query: _searchQuery);
                }

                final featured = filtered.first;
                final rest = filtered.skip(1).toList();

                return ListView(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: AppSpacing.lg,
                  ),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // ── Section label
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        bottom: AppSpacing.sm,
                      ),
                      child: Text(
                        'PILIHAN UTAMA',
                        style: AppTextStyles.labelSpaced.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),

                    // ── Featured card
                    FeaturedDestinationCard(
                      destination: featured,
                      onTap: () => _navigateToDetail(featured),
                    ),

                    // ── Section label + list jika ada destinasi lain
                    if (rest.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.md,
                          bottom: AppSpacing.sm + 4,
                        ),
                        child: Text(
                          'SEMUA DESTINASI',
                          style: AppTextStyles.labelSpaced.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ),

                      ...rest.map(
                        (item) => HorizontalDestinationCard(
                          destination: item,
                          onTap: () => _navigateToDetail(item),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── EMPTY STATE ───────────────────────────────────────────────────────────────

class _DestinasiEmptyState extends StatelessWidget {
  final String query;
  const _DestinasiEmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tidak ada hasil untuk "$query"',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Coba kata kunci yang berbeda',
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── LOADING STATE ─────────────────────────────────────────────────────────────

class _DestinasiLoadingState extends StatelessWidget {
  const _DestinasiLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 2.5,
      ),
    );
  }
}
