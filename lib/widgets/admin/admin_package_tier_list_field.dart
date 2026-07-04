// lib/widgets/admin/admin_package_tier_list_field.dart
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/package_model.dart';

class AdminPackageTierListField extends StatefulWidget {
  final List<PackageTier> initialItems;
  final ValueChanged<List<PackageTier>> onChanged;

  const AdminPackageTierListField({
    super.key,
    this.initialItems = const [],
    required this.onChanged,
  });

  @override
  State<AdminPackageTierListField> createState() =>
      _AdminPackageTierListFieldState();
}

class _AdminPackageTierListFieldState
    extends State<AdminPackageTierListField> {
  late List<_TierRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.initialItems.map((t) => _TierRow.fromModel(t)).toList();
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
        .map((r) => PackageTier(
              name: r.nameCtrl.text.trim(),
              price: int.tryParse(r.priceCtrl.text.trim()) ?? 0,
              description: r.descCtrl.text.trim(),
              includes: r.includesCtrl.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList(),
              minPerson: int.tryParse(r.minPersonCtrl.text.trim()) ?? 1,
              isPopular: r.isPopular,
            ))
        .toList();
    widget.onChanged(models);
  }

  void _add() => setState(() => _rows.add(_TierRow.empty()));

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
              child: Text('Tier Harga',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
            ),
            FilledButton.tonalIcon(
              onPressed: _add,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tambah Tier'),
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
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm)),
                        child: Center(
                          child: Text('${i + 1}',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textOnDark,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text('Tier ${i + 1}',
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
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    children: [
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: r.nameCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Nama Tier', isDense: true),
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
                                labelText: 'Harga',
                                isDense: true,
                                prefixText: 'Rp '),
                            onChanged: (_) => _emit(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: r.minPersonCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Min Orang', isDense: true),
                            onChanged: (_) => _emit(),
                          ),
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: r.descCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Deskripsi', isDense: true),
                        maxLines: 2,
                        onChanged: (_) => _emit(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: r.includesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Termasuk (pisah koma)',
                          isDense: true,
                          helperText: 'Contoh: Makan 3x, Pemandu, Akomodasi',
                        ),
                        onChanged: (_) => _emit(),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: r.isPopular,
                        onChanged: (v) {
                          setState(() => r.isPopular = v);
                          _emit();
                        },
                        title: Text('Tandai sebagai Terlaris',
                            style: AppTextStyles.caption),
                        activeColor: AppColors.starColor,
                      ),
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

class _TierRow {
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController descCtrl;
  final TextEditingController includesCtrl;
  final TextEditingController minPersonCtrl;
  bool isPopular;

  _TierRow({
    required this.nameCtrl,
    required this.priceCtrl,
    required this.descCtrl,
    required this.includesCtrl,
    required this.minPersonCtrl,
    this.isPopular = false,
  });

  factory _TierRow.empty() => _TierRow(
        nameCtrl: TextEditingController(),
        priceCtrl: TextEditingController(),
        descCtrl: TextEditingController(),
        includesCtrl: TextEditingController(),
        minPersonCtrl: TextEditingController(text: '1'),
      );

  factory _TierRow.fromModel(PackageTier t) => _TierRow(
        nameCtrl: TextEditingController(text: t.name),
        priceCtrl: TextEditingController(text: t.price.toString()),
        descCtrl: TextEditingController(text: t.description),
        includesCtrl: TextEditingController(text: t.includes.join(', ')),
        minPersonCtrl: TextEditingController(text: t.minPerson.toString()),
        isPopular: t.isPopular,
      );

  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();
    includesCtrl.dispose();
    minPersonCtrl.dispose();
  }
}