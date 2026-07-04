// lib/presentation/admin/accommodation/admin_accommodation_form_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/accommodation_model.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';
import 'package:aplikasi_wisata/data/services/firestore/accommodation_service.dart';
import 'package:aplikasi_wisata/widgets/admin/admin_image_picker_field.dart';
import 'package:aplikasi_wisata/widgets/admin/admin_multi_image_picker_field.dart';
import 'package:aplikasi_wisata/widgets/admin/admin_room_type_list_field.dart';

class AdminAccommodationFormPage extends StatefulWidget {
  final AccommodationModel? existing;
  const AdminAccommodationFormPage({super.key, this.existing});
  bool get isEditMode => existing != null;

  @override
  State<AdminAccommodationFormPage> createState() =>
      _AdminAccommodationFormPageState();
}

class _AdminAccommodationFormPageState
    extends State<AdminAccommodationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = AccommodationService();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _mapsUrlCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _maps360UrlCtrl;

  String? _selectedCategoryId;
  String _imageUrl = '';
  List<String> _images = [];
  bool _hasVirtualTour = false;
  bool _isRecommended = false;
  List<RoomType> _roomTypes = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _mapsUrlCtrl = TextEditingController(text: e?.mapsUrl ?? '');
    _latCtrl = TextEditingController(text: e != null ? e.latitude.toString() : '');
    _lngCtrl = TextEditingController(text: e != null ? e.longitude.toString() : '');
    _priceCtrl = TextEditingController(text: e?.pricePerNight.toString() ?? '0');
    _maps360UrlCtrl = TextEditingController(text: e?.maps360Url ?? '');
    _selectedCategoryId = e?.categoryId;
    _imageUrl = e?.imageUrl ?? '';
    _images = List.of(e?.images ?? []);
    _hasVirtualTour = e?.hasVirtualTour ?? false;
    _isRecommended = e?.isRecommended ?? false;
    _roomTypes = List.of(e?.roomTypes ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _locationCtrl.dispose();
    _mapsUrlCtrl.dispose(); _latCtrl.dispose(); _lngCtrl.dispose();
    _priceCtrl.dispose(); _maps360UrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pilih kategori dulu.'),
          backgroundColor: AppColors.error));
      return;
    }
    if (_hasVirtualTour && _maps360UrlCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Maps 360° URL wajib diisi jika punya Virtual Tour.'),
          backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final model = AccommodationModel(
        id: widget.existing?.id ?? '',
        name: _nameCtrl.text.trim(),
        categoryId: _selectedCategoryId!,
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        imageUrl: _imageUrl,
        images: _images,
        latitude: double.tryParse(_latCtrl.text.trim()) ?? 0.0,
        longitude: double.tryParse(_lngCtrl.text.trim()) ?? 0.0,
        mapsUrl: _mapsUrlCtrl.text.trim(),
        hasVirtualTour: _hasVirtualTour,
        maps360Url: _hasVirtualTour ? _maps360UrlCtrl.text.trim() : null,
        pricePerNight: int.tryParse(_priceCtrl.text.trim()) ?? 0,
        roomTypes: _roomTypes,
        // ⚠️ Rating tidak dari form — dikelola ReviewService
        rating: widget.existing?.rating ?? 0.0,
        isRecommended: _isRecommended,
        createdAt: widget.existing?.createdAt,
      );

      if (widget.isEditMode) {
        await _service.updateAccommodation(widget.existing!.id, model);
      } else {
        await _service.createAccommodation(model);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(widget.isEditMode
                ? 'Akomodasi diperbarui'
                : 'Akomodasi ditambahkan')));
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
              style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final accomCategories = context
        .watch<CategoryProvider>()
        .categories
        .where((c) => c.type == 'accommodation')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: Text(widget.isEditMode
              ? 'Edit Akomodasi'
              : 'Tambah Akomodasi')),
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
                          const InputDecoration(labelText: 'Nama Akomodasi'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration:
                          const InputDecoration(labelText: 'Kategori Akomodasi'),
                      hint: const Text('Pilih kategori'),
                      items: accomCategories
                          .map((c) =>
                              DropdownMenuItem(value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _locationCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Lokasi (alamat singkat)'),
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
                      value: _isRecommended,
                      onChanged: (v) => setState(() => _isRecommended = v),
                      title: const Text('Tampilkan di Rekomendasi'),
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

                    _sectionLabel('Lokasi & Maps'),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          decoration: const InputDecoration(labelText: 'Latitude'),
                          validator: (v) =>
                              double.tryParse(v?.trim() ?? '') == null
                                  ? 'Wajib angka'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextFormField(
                          controller: _lngCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          decoration: const InputDecoration(labelText: 'Longitude'),
                          validator: (v) =>
                              double.tryParse(v?.trim() ?? '') == null
                                  ? 'Wajib angka'
                                  : null,
                        ),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _mapsUrlCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Maps URL (Google Maps)'),
                    ),

                    _sectionLabel('Harga & Tipe Kamar'),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga Dasar per Malam',
                        prefixText: 'Rp ',
                        helperText:
                            'Digunakan sebagai fallback jika tidak ada tipe kamar',
                      ),
                      validator: (v) =>
                          int.tryParse(v?.trim() ?? '') == null
                              ? 'Wajib angka'
                              : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AdminRoomTypeListField(
                      initialItems: _roomTypes,
                      onChanged: (rooms) => _roomTypes = rooms,
                    ),

                    _sectionLabel('Virtual Tour 360°'),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _hasVirtualTour,
                      onChanged: (v) => setState(() => _hasVirtualTour = v),
                      title: const Text('Punya Virtual Tour'),
                      activeColor: AppColors.primary,
                    ),
                    if (_hasVirtualTour)
                      TextFormField(
                        controller: _maps360UrlCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Maps 360° URL',
                          helperText:
                              'URL gambar/peta equirectangular 360° untuk VT',
                          prefixIcon: Icon(Icons.link_rounded),
                        ),
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
                                    strokeWidth: 2, color: AppColors.textOnDark))
                            : Text(widget.isEditMode
                                ? 'Simpan Perubahan'
                                : 'Tambah Akomodasi'),
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