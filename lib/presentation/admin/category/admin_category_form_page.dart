// lib/presentation/admin/category/admin_category_form_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/core/utils/icon_mapper.dart';
import 'package:aplikasi_wisata/data/models/category_model.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';
import 'package:aplikasi_wisata/widgets/admin/admin_image_picker_field.dart';

class AdminCategoryFormPage extends StatefulWidget {
  final CategoryModel? existing;
  const AdminCategoryFormPage({super.key, this.existing});

  bool get isEditMode => existing != null;

  @override
  State<AdminCategoryFormPage> createState() => _AdminCategoryFormPageState();
}

class _AdminCategoryFormPageState extends State<AdminCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedType;
  late String _selectedIcon;
  String _imageUrl = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _selectedType = e?.type ?? CategoryType.destination;
    _selectedIcon =
        (e != null && kValidCategoryIconKeys.contains(e.icon))
            ? e.icon
            : kValidCategoryIconKeys.first;
    _imageUrl = e?.imageUrl ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final provider = context.read<CategoryProvider>();

    final model = CategoryModel(
      id: widget.existing?.id ?? '',
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      imageUrl: _imageUrl,
      type: _selectedType,
      createdAt: widget.existing?.createdAt,
    );

    try {
      if (widget.isEditMode) {
        await provider.updateCategory(widget.existing!.id, model);
      } else {
        await provider.createCategory(model);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditMode
                  ? 'Kategori diperbarui'
                  : 'Kategori ditambahkan',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _typeLabel(String type) => switch (type) {
    CategoryType.destination => 'Destinasi',
    CategoryType.package => 'Paket',
    CategoryType.accommodation => 'Akomodasi',
    CategoryType.placeWorship => 'Tempat Ibadah', // ✅ NEW
    CategoryType.placeHealth => 'Fasilitas Kesehatan', // ✅ NEW
    _ => type,
  };

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Kategori' : 'Tambah Kategori'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── GAMBAR ──
                    _sectionLabel('Gambar Kategori'),
                    AdminImagePickerField(
                      label: 'Gambar Kategori',
                      initialUrl: _imageUrl.isNotEmpty ? _imageUrl : null,
                      onUploaded: (url) => setState(() => _imageUrl = url),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── INFORMASI ──
                    _sectionLabel('Informasi'),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Kategori',
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Nama wajib diisi'
                                  : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Kategori',
                      ),
                      items:
                          CategoryType.values
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(_typeLabel(t)),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                    ),

                    // ✅ TIDAK ADA LAGI FIELD GRUP — tipe langsung worship/health
                    const SizedBox(height: AppSpacing.lg),

                    // ── PILIH IKON ──
                    _sectionLabel('Pilih Ikon'),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cols = (constraints.maxWidth / 56)
                              .floor()
                              .clamp(5, 10);
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  crossAxisSpacing: AppSpacing.xs,
                                  mainAxisSpacing: AppSpacing.xs,
                                ),
                            itemCount: kValidCategoryIconKeys.length,
                            itemBuilder: (context, i) {
                              final key = kValidCategoryIconKeys[i];
                              final selected = key == _selectedIcon;
                              return Tooltip(
                                message: key,
                                child: InkWell(
                                  onTap:
                                      () => setState(() => _selectedIcon = key),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    decoration: BoxDecoration(
                                      color:
                                          selected
                                              ? AppColors.primary
                                              : AppColors.primarySurface,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm,
                                      ),
                                      border:
                                          selected
                                              ? null
                                              : Border.all(
                                                color: AppColors.divider,
                                                width: 0.5,
                                              ),
                                    ),
                                    child: Icon(
                                      getCategoryIcon(key),
                                      color:
                                          selected
                                              ? AppColors.textOnDark
                                              : AppColors.primary,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (_selectedIcon.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          'Dipilih: $_selectedIcon',
                          style: AppTextStyles.caption,
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        child:
                            _isSaving
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textOnDark,
                                  ),
                                )
                                : Text(
                                  widget.isEditMode
                                      ? 'Simpan Perubahan'
                                      : 'Tambah Kategori',
                                ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
