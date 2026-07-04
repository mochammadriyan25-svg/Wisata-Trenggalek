// lib/presentation/admin/destination/admin_destination_form_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart';
import 'package:aplikasi_wisata/data/models/menu_item_model.dart';
import 'package:aplikasi_wisata/providers/destination_provider.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';
import 'package:aplikasi_wisata/widgets/admin/admin_image_picker_field.dart';
import 'package:aplikasi_wisata/widgets/admin/admin_multi_image_picker_field.dart';
import 'package:aplikasi_wisata/widgets/admin/admin_menu_item_list_field.dart';
import 'admin_vt_preview_page.dart';

class AdminDestinationFormPage extends StatefulWidget {
  final DestinationModel? existing;
  const AdminDestinationFormPage({super.key, this.existing});

  bool get isEditMode => existing != null;

  @override
  State<AdminDestinationFormPage> createState() =>
      _AdminDestinationFormPageState();
}

class _AdminDestinationFormPageState extends State<AdminDestinationFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _mapsUrlController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late final TextEditingController _panoIdController;
  late final TextEditingController _priceAdultController;
  late final TextEditingController _priceChildController;
  late final TextEditingController _image360UrlController;

  String? _selectedCategoryId;
  String _imageUrl = '';
  List<String> _images = [];
  bool _hasVirtualTour = false;
  bool _isRecommended = false;
  List<MenuItemModel> _menus = [];

  double _streetViewHeading = 0.0;
  double _streetViewPitch = 0.0;
  String _image360Url = '';
  double _image360Heading = 0.0;
  double _image360Pitch = 0.0;

  bool _isSaving = false;

  bool get _isKuliner => _selectedCategoryId == kCategoryKuliner;

  /// URL final image360 — link manual diprioritaskan atas upload device.
  String get _image360FinalUrl {
    final linkUrl = _image360UrlController.text.trim();
    return linkUrl.isNotEmpty ? linkUrl : _image360Url;
  }

  @override
  void initState() {
    super.initState();
    final e = widget.existing;

    _nameController = TextEditingController(text: e?.name ?? '');
    _locationController = TextEditingController(text: e?.location ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _mapsUrlController = TextEditingController(text: e?.mapsUrl ?? '');
    _latController = TextEditingController(
      text: e != null ? e.latitude.toString() : '',
    );
    _lngController = TextEditingController(
      text: e != null ? e.longitude.toString() : '',
    );
    _panoIdController = TextEditingController(text: e?.panoId ?? '');
    _priceAdultController = TextEditingController(
      text: e?.priceAdult?.toString() ?? '',
    );
    _priceChildController = TextEditingController(
      text: e?.priceChild?.toString() ?? '',
    );

    // Deteksi sumber image360: Firebase Storage → _image360Url, UGC/lainnya → controller
    final existingImage360 = e?.image360.url ?? '';
    final isFirebaseUpload = existingImage360.contains(
      'firebasestorage.googleapis.com',
    );
    _image360Url = isFirebaseUpload ? existingImage360 : '';
    _image360UrlController = TextEditingController(
      text: isFirebaseUpload ? '' : existingImage360,
    );

    _selectedCategoryId = e?.categoryId;
    _imageUrl = e?.imageUrl ?? '';
    _images = List.of(e?.images ?? []);
    _hasVirtualTour = e?.hasVirtualTour ?? false;
    _isRecommended = e?.isRecommended ?? false;
    _menus = List.of(e?.menus ?? []);

    _streetViewHeading = e?.streetView.heading ?? 0.0;
    _streetViewPitch = e?.streetView.pitch ?? 0.0;
    _image360Heading = e?.image360.heading ?? 0.0;
    _image360Pitch = e?.image360.pitch ?? 0.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _mapsUrlController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _panoIdController.dispose();
    _priceAdultController.dispose();
    _priceChildController.dispose();
    _image360UrlController.dispose();
    super.dispose();
  }

  Future<void> _openStreetViewPreview() async {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi Latitude & Longitude dulu sebelum preview.'),
        ),
      );
      return;
    }
    final panoId = _panoIdController.text.trim();
    final result = await Navigator.push<Map<String, double>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => AdminVtPreviewPage(
              latitude: lat,
              longitude: lng,
              panoId: panoId.isNotEmpty ? panoId : null,
              initialHeading: _streetViewHeading,
              initialPitch: _streetViewPitch,
            ),
      ),
    );
    if (result != null) {
      setState(() {
        _streetViewHeading = result['heading']!;
        _streetViewPitch = result['pitch']!;
      });
    }
  }

  Future<void> _openImage360Preview() async {
    final finalUrl = _image360FinalUrl;
    if (finalUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Upload Foto 360° atau masukkan link URL dulu sebelum preview.',
          ),
        ),
      );
      return;
    }
    final lat = double.tryParse(_latController.text.trim()) ?? 0.0;
    final lng = double.tryParse(_lngController.text.trim()) ?? 0.0;
    final result = await Navigator.push<Map<String, double>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => AdminVtPreviewPage(
              latitude: lat,
              longitude: lng,
              image360Url: finalUrl,
              initialHeading: _image360Heading,
              initialPitch: _image360Pitch,
            ),
      ),
    );
    if (result != null) {
      setState(() {
        _image360Heading = result['heading']!;
        _image360Pitch = result['pitch']!;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori dulu.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<DestinationProvider>();

    final model = DestinationModel(
      id: widget.existing?.id ?? '',
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId!,
      // ⚠️ Rating tidak dari form — dikelola ReviewService.
      rating: widget.existing?.rating ?? 0.0,
      imageUrl: _imageUrl,
      images: _images,
      latitude: double.tryParse(_latController.text.trim()) ?? 0.0,
      longitude: double.tryParse(_lngController.text.trim()) ?? 0.0,
      mapsUrl: _mapsUrlController.text.trim(),
      hasVirtualTour: _hasVirtualTour,
      panoId:
          _panoIdController.text.trim().isEmpty
              ? null
              : _panoIdController.text.trim(),
      streetView: StreetViewConfig(
        heading: _streetViewHeading,
        pitch: _streetViewPitch,
      ),
      image360: Image360Config(
        url: _image360FinalUrl,
        heading: _image360Heading,
        pitch: _image360Pitch,
      ),
      priceAdult:
          _isKuliner ? null : int.tryParse(_priceAdultController.text.trim()),
      priceChild:
          _isKuliner ? null : int.tryParse(_priceChildController.text.trim()),
      menus: _isKuliner ? _menus : [],
      isRecommended: _isRecommended,
      createdAt: widget.existing?.createdAt,
    );

    try {
      if (widget.isEditMode) {
        await provider.updateDestination(widget.existing!.id, model);
      } else {
        await provider.createDestination(model);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditMode
                  ? 'Destinasi diperbarui'
                  : 'Destinasi ditambahkan',
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

  // ── Section Label ──────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
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

  Widget _image360Divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            'atau menggunakan link UGC 360 resmi Google Maps',
            style: AppTextStyles.caption,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    ),
  );

  // ── Price Validator ────────────────────────────────────────────────────────

  String? _validatePrice(String? v) {
    final trimmed = v?.trim() ?? '';
    if (trimmed.isEmpty) return null; // null = tampil "-" di UI
    if (int.tryParse(trimmed) == null) return 'Masukkan angka valid';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final destinationCategories =
        context.watch<CategoryProvider>().destinationCategories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Destinasi' : 'Tambah Destinasi'),
      ),
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
                    // Rating read-only (edit mode)
                    if (widget.isEditMode)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.accentSurface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.starColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Rating: ${widget.existing!.rating.toStringAsFixed(1)} '
                                '(otomatis dari ulasan, tidak bisa diubah manual)',
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── INFORMASI DASAR ──────────────────────────────────
                    _sectionLabel('Informasi Dasar'),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Destinasi',
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Nama wajib diisi'
                                  : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items:
                          destinationCategories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi (alamat singkat)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descriptionController,
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

                    // ── GAMBAR ───────────────────────────────────────────
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

                    // ── LOKASI & MAPS ────────────────────────────────────
                    _sectionLabel('Lokasi & Maps'),
                    TextFormField(
                      controller: _mapsUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Maps URL (link Google Maps)',
                      ),
                    ),

                    // ── VIRTUAL TOUR 360° ────────────────────────────────
                    _sectionLabel('Virtual Tour 360°'),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _hasVirtualTour,
                      onChanged: (v) => setState(() => _hasVirtualTour = v),
                      title: const Text('Punya Virtual Tour'),
                      activeColor: AppColors.primary,
                    ),
                    if (_hasVirtualTour) ...[
                      const SizedBox(height: AppSpacing.sm),

                      // 1. Photo Sphere ID
                      TextFormField(
                        controller: _panoIdController,
                        decoration: const InputDecoration(
                          labelText:
                              'Photo Sphere ID (opsional, format AF1Qip...)',
                          helperText:
                              'Kosongkan jika pakai Street View resmi berdasarkan koordinat',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // 2. Lat & Lng (dipindah ke sini agar kontekstual dengan Photo Sphere)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                              ),
                              validator:
                                  (v) =>
                                      double.tryParse(v?.trim() ?? '') == null
                                          ? 'Wajib angka'
                                          : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              controller: _lngController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                              ),
                              validator:
                                  (v) =>
                                      double.tryParse(v?.trim() ?? '') == null
                                          ? 'Wajib angka'
                                          : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // 3. Orientasi Street View
                      _OrientationPreviewTile(
                        title: 'Orientasi Street View / Photo Sphere',
                        heading: _streetViewHeading,
                        pitch: _streetViewPitch,
                        onPreview: _openStreetViewPreview,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Foto 360° UGC
                      Text(
                        'Foto 360° (UGC)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AdminImagePickerField(
                        label: 'Gambar Equirectangular 360°',
                        initialUrl:
                            _image360Url.isNotEmpty ? _image360Url : null,
                        onUploaded:
                            (url) => setState(() {
                              _image360Url = url;
                              _image360UrlController.clear();
                            }),
                      ),
                      _image360Divider(),
                      TextFormField(
                        controller: _image360UrlController,
                        decoration: const InputDecoration(
                          labelText: 'Link URL Foto 360° (Google Maps UGC)',
                          helperText:
                              'Contoh: https://lh3.googleusercontent.com/gpms-cs-s/...',
                          prefixIcon: Icon(Icons.link_rounded),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _OrientationPreviewTile(
                        title: 'Orientasi Foto 360°',
                        heading: _image360Heading,
                        pitch: _image360Pitch,
                        onPreview: _openImage360Preview,
                      ),
                    ],

                    // ── MENU / HARGA TIKET ───────────────────────────────
                    if (_isKuliner) ...[
                      _sectionLabel('Menu (Kuliner)'),
                      AdminMenuItemListField(
                        initialItems: _menus,
                        onChanged: (menus) => _menus = menus,
                      ),
                    ] else ...[
                      _sectionLabel('Harga Tiket'),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.accentSurface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Text(
                          'Kosongkan jika tidak ada info → tampil "-"  ·  Isi 0 → tampil "Gratis"',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // [CHANGED] Anak di KIRI, Dewasa di KANAN
                          Expanded(
                            child: TextFormField(
                              controller: _priceChildController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Harga Anak',
                                prefixText: 'Rp ',
                              ),
                              validator: _validatePrice,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              controller: _priceAdultController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Harga Dewasa',
                                prefixText: 'Rp ',
                              ),
                              validator: _validatePrice,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // ── SIMPAN ───────────────────────────────────────────
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
                                      : 'Tambah Destinasi',
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

// ── _OrientationPreviewTile ──────────────────────────────────────────────────

class _OrientationPreviewTile extends StatelessWidget {
  final String title;
  final double heading;
  final double pitch;
  final VoidCallback onPreview;

  const _OrientationPreviewTile({
    required this.title,
    required this.heading,
    required this.pitch,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Heading: ${heading.round()}°   Pitch: ${pitch.round()}°',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onPreview,
            icon: const Icon(Icons.threed_rotation_rounded, size: 18),
            label: const Text('Preview & Atur'),
          ),
        ],
      ),
    );
  }
}
