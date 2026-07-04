// lib/presentation/admin/package/admin_package_form_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/package_model.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';
import 'package:aplikasi_wisata/data/services/firestore/package_service.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';
import 'package:aplikasi_wisata/providers/destination_provider.dart';
import 'package:aplikasi_wisata/widgets/admin/admin_image_picker_field.dart';
import 'package:aplikasi_wisata/widgets/admin/admin_multi_image_picker_field.dart';
import 'package:aplikasi_wisata/widgets/admin/admin_package_tier_list_field.dart';

class AdminPackageFormPage extends StatefulWidget {
  final PackageModel? existing;
  const AdminPackageFormPage({super.key, this.existing});
  bool get isEditMode => existing != null;

  @override
  State<AdminPackageFormPage> createState() => _AdminPackageFormPageState();
}

class _AdminPackageFormPageState extends State<AdminPackageFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = PackageService();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _daysCtrl;
  late final TextEditingController _nightsCtrl;
  late final TextEditingController _includesCtrl;

  String? _selectedCategoryId;
  String _imageUrl = '';
  List<String> _images = [];
  bool _isActive = true;
  Set<String> _selectedDestinationIds = {};
  List<PackageTier> _tiers = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _priceCtrl = TextEditingController(text: e?.price.toString() ?? '0');
    _daysCtrl = TextEditingController(text: e?.durationDays.toString() ?? '1');
    _nightsCtrl =
        TextEditingController(text: e?.durationNights.toString() ?? '0');
    _includesCtrl =
        TextEditingController(text: e?.includes.join(', ') ?? '');
    _selectedCategoryId = e?.categoryId;
    _imageUrl = e?.imageUrl ?? '';
    _images = List.of(e?.images ?? []);
    _isActive = e?.isActive ?? true;
    _selectedDestinationIds = Set.of(e?.destinationIds ?? []);
    _tiers = List.of(e?.tiers ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose();
    _daysCtrl.dispose(); _nightsCtrl.dispose(); _includesCtrl.dispose();
    super.dispose();
  }

  void _showDestinationSelector(List<DestinationModel> destinations) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            builder: (_, scrollCtrl) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(children: [
                    Expanded(
                      child: Text('Pilih Destinasi',
                          style: AppTextStyles.bodyLarge
                              .copyWith(fontWeight: FontWeight.w700)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text('${_selectedDestinationIds.length} dipilih',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Selesai'),
                    ),
                  ]),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: destinations.length,
                    itemBuilder: (_, i) {
                      final d = destinations[i];
                      final selected = _selectedDestinationIds.contains(d.id);
                      return CheckboxListTile(
                        value: selected,
                        activeColor: AppColors.primary,
                        title: Text(d.name, style: AppTextStyles.bodyMedium),
                        subtitle: Text(d.location,
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        secondary: d.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm),
                                child: Image.network(d.imageUrl,
                                    width: 44, height: 44, fit: BoxFit.cover))
                            : Container(
                                width: 44, height: 44,
                                color: AppColors.primarySurface,
                                child: const Icon(Icons.landscape_rounded,
                                    color: AppColors.primary)),
                        onChanged: (val) {
                          setModal(() {
                            if (val == true) {
                              _selectedDestinationIds.add(d.id);
                            } else {
                              _selectedDestinationIds.remove(d.id);
                            }
                          });
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pilih kategori dulu.'),
          backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final includes = _includesCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final model = PackageModel(
        id: widget.existing?.id ?? '',
        categoryId: _selectedCategoryId!,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageUrl: _imageUrl,
        images: _images,
        price: int.tryParse(_priceCtrl.text.trim()) ?? 0,
        durationDays: int.tryParse(_daysCtrl.text.trim()) ?? 1,
        durationNights: int.tryParse(_nightsCtrl.text.trim()) ?? 0,
        includes: includes,
        destinationIds: _selectedDestinationIds.toList(),
        tiers: _tiers,
        isActive: _isActive,
        createdAt: widget.existing?.createdAt,
        // ⚠️ Rating tidak dari form — dikelola ReviewService
        rating: widget.existing?.rating ?? 0.0,
      );

      if (widget.isEditMode) {
        await _service.updatePackage(widget.existing!.id, model);
      } else {
        await _service.createPackage(model);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(widget.isEditMode
                ? 'Paket diperbarui'
                : 'Paket ditambahkan')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
        child: Row(children: [
          Container(
              width: 3, height: 16,
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: AppSpacing.xs),
          Text(text,
              style: AppTextStyles.headlineSmall
                  .copyWith(color: AppColors.primary)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final pkgCategories = context
        .watch<CategoryProvider>()
        .categories
        .where((c) => c.type == 'package')
        .toList();
    final allDestinations =
        context.watch<DestinationProvider>().allDestinations;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: Text(widget.isEditMode ? 'Edit Paket' : 'Tambah Paket')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isEditMode)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                            color: AppColors.accentSurface,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm)),
                        child: Row(children: [
                          const Icon(Icons.star_rounded,
                              size: 16, color: AppColors.starColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                                'Rating: ${widget.existing!.rating.toStringAsFixed(1)} (otomatis dari ulasan)',
                                style: AppTextStyles.caption),
                          ),
                        ]),
                      ),

                    _sectionLabel('Informasi Dasar'),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Nama Paket'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration:
                          const InputDecoration(labelText: 'Kategori Paket'),
                      hint: const Text('Pilih kategori'),
                      items: pkgCategories
                          .map((c) =>
                              DropdownMenuItem(value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedCategoryId = v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                      maxLines: 4,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      title: const Text('Paket Aktif (tampil di aplikasi)'),
                      activeColor: AppColors.primary,
                    ),

                    _sectionLabel('Gambar'),
                    AdminImagePickerField(
                      label: 'Gambar Utama',
                      initialUrl: _imageUrl.isNotEmpty ? _imageUrl : null,
                      onUploaded: (url) => setState(() => _imageUrl = url),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AdminMultiImagePickerField(
                      label: 'Galeri Tambahan',
                      initialUrls: _images,
                      onChanged: (urls) => setState(() => _images = urls),
                    ),

                    _sectionLabel('Harga & Durasi'),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Harga Dasar', prefixText: 'Rp '),
                      validator: (v) =>
                          int.tryParse(v?.trim() ?? '') == null
                              ? 'Wajib angka'
                              : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _daysCtrl,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Durasi (Hari)'),
                          validator: (v) =>
                              int.tryParse(v?.trim() ?? '') == null
                                  ? 'Wajib angka'
                                  : null,
                          onChanged: (v) {
                            // Auto-isi malam = hari - 1
                            final days = int.tryParse(v.trim()) ?? 1;
                            if (days > 0) {
                              _nightsCtrl.text = (days - 1).toString();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextFormField(
                          controller: _nightsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Durasi (Malam)',
                              helperText: 'Otomatis: hari - 1'),
                          validator: (v) =>
                              int.tryParse(v?.trim() ?? '') == null
                                  ? 'Wajib angka'
                                  : null,
                        ),
                      ),
                    ]),

                    _sectionLabel('Termasuk dalam Paket'),
                    TextFormField(
                      controller: _includesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Fasilitas (pisahkan dengan koma)',
                        helperText: 'Contoh: Makan 3x, Pemandu, Tiket Masuk',
                      ),
                      maxLines: 3,
                    ),

                    _sectionLabel('Destinasi'),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _showDestinationSelector(allDestinations),
                      icon: const Icon(Icons.landscape_rounded),
                      label: Text(_selectedDestinationIds.isEmpty
                          ? 'Pilih Destinasi'
                          : '${_selectedDestinationIds.length} destinasi dipilih'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      ),
                    ),
                    if (_selectedDestinationIds.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: _selectedDestinationIds.map((id) {
                          final dest = allDestinations
                              .where((d) => d.id == id)
                              .firstOrNull;
                          return Chip(
                            label: Text(dest?.name ?? id.substring(0, 6),
                                style: AppTextStyles.caption),
                            backgroundColor: AppColors.primarySurface,
                            deleteIconColor: AppColors.primary,
                            onDeleted: () =>
                                setState(() => _selectedDestinationIds.remove(id)),
                          );
                        }).toList(),
                      ),
                    ],

                    _sectionLabel('Tier Harga'),
                    AdminPackageTierListField(
                      initialItems: _tiers,
                      onChanged: (tiers) => _tiers = tiers,
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textOnDark))
                            : Text(widget.isEditMode
                                ? 'Simpan Perubahan'
                                : 'Tambah Paket'),
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