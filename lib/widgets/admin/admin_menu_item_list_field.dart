// lib/widgets/admin/admin_menu_item_list_field.dart
import 'package:flutter/material.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/menu_item_model.dart';

class AdminMenuItemListField extends StatefulWidget {
  final List<MenuItemModel> initialItems;
  final ValueChanged<List<MenuItemModel>> onChanged;

  const AdminMenuItemListField({
    super.key,
    this.initialItems = const [],
    required this.onChanged,
  });

  @override
  State<AdminMenuItemListField> createState() => _AdminMenuItemListFieldState();
}

class _AdminMenuItemListFieldState extends State<AdminMenuItemListField> {
  late List<_MenuRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.initialItems.map((m) => _MenuRow.fromModel(m)).toList();
    if (_rows.isEmpty) _rows.add(_MenuRow.empty());
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _emitChange() {
    final models =
        _rows
            .where((r) => r.nameController.text.trim().isNotEmpty)
            .map(
              (r) => MenuItemModel(
                name: r.nameController.text.trim(),
                price: int.tryParse(r.priceController.text.trim()),
                description:
                    r.descController.text.trim().isEmpty
                        ? null
                        : r.descController.text.trim(),
              ),
            )
            .toList();
    widget.onChanged(models);
  }

  void _addRow() => setState(() => _rows.add(_MenuRow.empty()));

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
      if (_rows.isEmpty) _rows.add(_MenuRow.empty());
    });
    _emitChange();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Expanded(
              child: Text(
                'Daftar Menu',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: _addRow,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tambah Menu'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primarySurface,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        // Menu rows
        ..._rows.asMap().entries.map((entry) {
          final i = entry.key;
          final row = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row header: number badge + delete
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
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
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textOnDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Menu ke-${i + 1}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _removeRow(i),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: AppColors.error.withValues(alpha: 0.8),
                          ),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: row.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Menu',
                                isDense: true,
                              ),
                              onChanged: (_) => _emitChange(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                              controller: row.priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Harga',
                                isDense: true,
                                prefixText: 'Rp ',
                              ),
                              onChanged: (_) => _emitChange(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: row.descController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi (opsional)',
                          isDense: true,
                        ),
                        onChanged: (_) => _emitChange(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        if (_rows.isEmpty ||
            _rows.every((r) => r.nameController.text.trim().isEmpty))
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              'Minimal satu menu harus diisi',
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
            ),
          ),
      ],
    );
  }
}

// ── _MenuRow ─────────────────────────────────────────────────────────────────

class _MenuRow {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController descController;

  _MenuRow({
    required this.nameController,
    required this.priceController,
    required this.descController,
  });

  factory _MenuRow.empty() => _MenuRow(
    nameController: TextEditingController(),
    priceController: TextEditingController(),
    descController: TextEditingController(),
  );

  factory _MenuRow.fromModel(MenuItemModel m) => _MenuRow(
    nameController: TextEditingController(text: m.name),
    priceController: TextEditingController(text: m.price?.toString() ?? ''),
    descController: TextEditingController(text: m.description ?? ''),
  );

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descController.dispose();
  }
}
