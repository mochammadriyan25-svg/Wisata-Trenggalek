// lib/widgets/admin/admin_room_type_list_field.dart
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/accommodation_model.dart';

class AdminRoomTypeListField extends StatefulWidget {
  final List<RoomType> initialItems;
  final ValueChanged<List<RoomType>> onChanged;

  const AdminRoomTypeListField({
    super.key,
    this.initialItems = const [],
    required this.onChanged,
  });

  @override
  State<AdminRoomTypeListField> createState() => _AdminRoomTypeListFieldState();
}

class _AdminRoomTypeListFieldState extends State<AdminRoomTypeListField> {
  late List<_RoomRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.initialItems.map((r) => _RoomRow.fromModel(r)).toList();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _emit() {
    final models = _rows
        .where((r) => r.nameCtrl.text.trim().isNotEmpty)
        .map((r) => RoomType(
              name: r.nameCtrl.text.trim(),
              pricePerNight:
                  int.tryParse(r.priceCtrl.text.trim()) ?? 0,
              description: r.descCtrl.text.trim(),
              facilities: r.facilitiesCtrl.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList(),
              maxGuest: int.tryParse(r.maxGuestCtrl.text.trim()) ?? 1,
              isAvailable: r.isAvailable,
              isPopular: r.isPopular,
            ))
        .toList();
    widget.onChanged(models);
  }

  void _add() => setState(() => _rows.add(_RoomRow.empty()));

  void _remove(int i) {
    setState(() {
      _rows[i].dispose();
      _rows.removeAt(i);
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Tipe Kamar',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
            ),
            FilledButton.tonalIcon(
              onPressed: _add,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tambah Tipe'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primarySurface,
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._rows.asMap().entries.map((entry) {
          final i = entry.key;
          final r = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSpacing.radiusMd),
                      topRight: Radius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textOnDark,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text('Tipe ke-${i + 1}',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      InkWell(
                        onTap: () => _remove(i),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.delete_outline_rounded,
                              size: 16,
                              color: AppColors.error.withValues(alpha: 0.8)),
                        ),
                      ),
                    ],
                  ),
                ),
                // Fields
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    children: [
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: r.nameCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Nama Tipe', isDense: true),
                            onChanged: (_) => _emit(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          width: 120,
                          child: TextFormField(
                            controller: r.priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Harga/Malam',
                                isDense: true,
                                prefixText: 'Rp '),
                            onChanged: (_) => _emit(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: r.maxGuestCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Tamu Maks', isDense: true),
                            onChanged: (_) => _emit(),
                          ),
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: r.descCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Deskripsi', isDense: true),
                        maxLines: 2,
                        onChanged: (_) => _emit(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: r.facilitiesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Fasilitas (pisahkan dengan koma)',
                          isDense: true,
                          helperText: 'Contoh: WiFi, AC, TV, Kamar Mandi Dalam',
                        ),
                        onChanged: (_) => _emit(),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(children: [
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            value: r.isAvailable,
                            onChanged: (v) {
                              setState(() => r.isAvailable = v);
                              _emit();
                            },
                            title: Text('Tersedia',
                                style: AppTextStyles.caption),
                            activeColor: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            value: r.isPopular,
                            onChanged: (v) {
                              setState(() => r.isPopular = v);
                              _emit();
                            },
                            title: Text('Terpopuler',
                                style: AppTextStyles.caption),
                            activeColor: AppColors.starColor,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _RoomRow {
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController descCtrl;
  final TextEditingController facilitiesCtrl;
  final TextEditingController maxGuestCtrl;
  bool isAvailable;
  bool isPopular;

  _RoomRow({
    required this.nameCtrl,
    required this.priceCtrl,
    required this.descCtrl,
    required this.facilitiesCtrl,
    required this.maxGuestCtrl,
    this.isAvailable = true,
    this.isPopular = false,
  });

  factory _RoomRow.empty() => _RoomRow(
        nameCtrl: TextEditingController(),
        priceCtrl: TextEditingController(),
        descCtrl: TextEditingController(),
        facilitiesCtrl: TextEditingController(),
        maxGuestCtrl: TextEditingController(text: '1'),
      );

  factory _RoomRow.fromModel(RoomType r) => _RoomRow(
        nameCtrl: TextEditingController(text: r.name),
        priceCtrl: TextEditingController(text: r.pricePerNight.toString()),
        descCtrl: TextEditingController(text: r.description),
        facilitiesCtrl:
            TextEditingController(text: r.facilities.join(', ')),
        maxGuestCtrl: TextEditingController(text: r.maxGuest.toString()),
        isAvailable: r.isAvailable,
        isPopular: r.isPopular,
      );

  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();
    facilitiesCtrl.dispose();
    maxGuestCtrl.dispose();
  }
}