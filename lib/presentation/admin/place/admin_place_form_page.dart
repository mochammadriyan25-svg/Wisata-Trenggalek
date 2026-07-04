// lib/presentation/admin/place/admin_place_form_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/core/utils/icon_mapper.dart';
import 'package:aplikasi_wisata/data/models/place_model.dart';
import 'package:aplikasi_wisata/data/models/category_model.dart';
import 'package:aplikasi_wisata/data/models/destination_model.dart'
    show StreetViewConfig, Image360Config;
import 'package:aplikasi_wisata/data/services/firestore/place_service.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';
import 'package:aplikasi_wisata/widgets/admin/admin_image_picker_field.dart';
import 'package:aplikasi_wisata/widgets/admin/admin_multi_image_picker_field.dart';
import '../destination/admin_vt_preview_page.dart';

class AdminPlaceFormPage extends StatefulWidget {
  final PlaceModel? existing;
  const AdminPlaceFormPage({super.key, this.existing});
  bool get isEditMode => existing != null;

  @override
  State<AdminPlaceFormPage> createState() => _AdminPlaceFormPageState();
}

class _AdminPlaceFormPageState extends State<AdminPlaceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = PlaceService();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _mapsUrlCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _panoIdCtrl;
  late final TextEditingController _image360UrlCtrl;

  PlaceType _placeType = PlaceType.worship;
  String? _categoryId;
  String _imageUrl = '';
  List<String> _images = [];
  bool _hasVirtualTour = false;
  bool _isSaving = false;

  double _svHeading = 0.0;
  double _svPitch = 0.0;
  String _img360Url = '';
  double _img360Heading = 0.0;
  double _img360Pitch = 0.0;

  String get _img360Final {
    final link = _image360UrlCtrl.text.trim();
    return link.isNotEmpty ? link : _img360Url;
  }

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _mapsUrlCtrl = TextEditingController(text: e?.mapsUrl ?? '');
    _latCtrl = TextEditingController(
      text: e != null ? e.latitude.toString() : '',
    );
    _lngCtrl = TextEditingController(
      text: e != null ? e.longitude.toString() : '',
    );
    _panoIdCtrl = TextEditingController(text: e?.panoId ?? '');
    _placeType = e?.placeType ?? PlaceType.worship;
    _categoryId = e?.categoryId;
    _imageUrl = e?.imageUrl ?? '';
    _images = List.of(e?.images ?? []);
    _hasVirtualTour = e?.hasVirtualTour ?? false;
    _svHeading = e?.streetView.heading ?? 0.0;
    _svPitch = e?.streetView.pitch ?? 0.0;

    final existingImg360 = e?.image360.url ?? '';
    final isFirebase = existingImg360.contains(
      'firebasestorage.googleapis.com',
    );
    _img360Url = isFirebase ? existingImg360 : '';
    _image360UrlCtrl = TextEditingController(
      text: isFirebase ? '' : existingImg360,
    );
    _img360Heading = e?.image360.heading ?? 0.0;
    _img360Pitch = e?.image360.pitch ?? 0.0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _mapsUrlCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _panoIdCtrl.dispose();
    _image360UrlCtrl.dispose();
    super.dispose();
  }

  // ✅ NEW: Resolve kategori yang sesuai berdasarkan placeType
  List<CategoryModel> _getRelevantCategories(CategoryProvider provider) {
    if (_placeType == PlaceType.worship) {
      return provider.placeWorshipCategories;
    } else {
      return provider.placeHealthCategories;
    }
  }

  Future<void> _openStreetViewPreview() async {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi Latitude & Longitude dulu.')),
      );
      return;
    }
    final panoId = _panoIdCtrl.text.trim();
    final result = await Navigator.push<Map<String, double>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => AdminVtPreviewPage(
              latitude: lat,
              longitude: lng,
              panoId: panoId.isNotEmpty ? panoId : null,
              initialHeading: _svHeading,
              initialPitch: _svPitch,
            ),
      ),
    );
    if (result != null) {
      setState(() {
        _svHeading = result['heading']!;
        _svPitch = result['pitch']!;
      });
    }
  }

  Future<void> _openImage360Preview() async {
    final finalUrl = _img360Final;
    if (finalUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload atau masukkan link foto 360° dulu.'),
        ),
      );
      return;
    }
    final lat = double.tryParse(_latCtrl.text.trim()) ?? 0.0;
    final lng = double.tryParse(_lngCtrl.text.trim()) ?? 0.0;
    final result = await Navigator.push<Map<String, double>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => AdminVtPreviewPage(
              latitude: lat,
              longitude: lng,
              image360Url: finalUrl,
              initialHeading: _img360Heading,
              initialPitch: _img360Pitch,
            ),
      ),
    );
    if (result != null) {
      setState(() {
        _img360Heading = result['heading']!;
        _img360Pitch = result['pitch']!;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final model = PlaceModel(
        id: widget.existing?.id ?? '',
        placeType: _placeType,
        categoryId: _categoryId,
        name: _nameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageUrl: _imageUrl,
        images: _images,
        latitude: double.tryParse(_latCtrl.text.trim()) ?? 0.0,
        longitude: double.tryParse(_lngCtrl.text.trim()) ?? 0.0,
        mapsUrl: _mapsUrlCtrl.text.trim(),
        hasVirtualTour: _hasVirtualTour,
        panoId:
            _panoIdCtrl.text.trim().isEmpty ? null : _panoIdCtrl.text.trim(),
        streetView: StreetViewConfig(heading: _svHeading, pitch: _svPitch),
        image360: Image360Config(
          url: _img360Final,
          heading: _img360Heading,
          pitch: _img360Pitch,
        ),
        createdAt: widget.existing?.createdAt,
      );

      if (widget.isEditMode) {
        await _service.updatePlace(widget.existing!.id, model);
      } else {
        await _service.createPlace(model);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditMode ? 'Tempat diperbarui' : 'Tempat ditambahkan',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Tempat' : 'Tambah Tempat'),
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
                    // ── JENIS TEMPAT ──
                    _sectionLabel('Jenis Tempat'),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<PlaceType>(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Ibadah'),
                            value: PlaceType.worship,
                            groupValue: _placeType,
                            activeColor: AppColors.primary,
                            onChanged:
                                (v) => setState(() {
                                  _placeType = v!;
                                  _categoryId = null;
                                }),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<PlaceType>(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Kesehatan'),
                            value: PlaceType.health,
                            groupValue: _placeType,
                            activeColor: AppColors.primary,
                            onChanged:
                                (v) => setState(() {
                                  _placeType = v!;
                                  _categoryId = null;
                                }),
                          ),
                        ),
                      ],
                    ),

                    // ✅ DROPDOWN KATEGORI — filter by tipe kategori yang sesuai
                    _sectionLabel('Kategori'),
                    Consumer<CategoryProvider>(
                      builder: (context, catProvider, _) {
                        final relevantCategories = _getRelevantCategories(
                          catProvider,
                        );

                        if (relevantCategories.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    'Belum ada kategori ${_placeType == PlaceType.worship ? "tempat ibadah" : "fasilitas kesehatan"}. '
                                    'Buat di menu Kelola Kategori dengan tipe "${_placeType == PlaceType.worship ? "Tempat Ibadah" : "Fasilitas Kesehatan"}".',
                                    style: AppTextStyles.caption,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return DropdownButtonFormField<String?>(
                          value: _categoryId,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('-- Pilih Kategori --'),
                            ),
                            ...relevantCategories.map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      getCategoryIcon(c.icon),
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(c.name),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _categoryId = v),
                        );
                      },
                    ),

                    // ── INFORMASI DASAR ──
                    _sectionLabel('Informasi Dasar'),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Tempat',
                      ),
                      validator:
                          (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Wajib diisi'
                                  : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi (alamat singkat)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                      maxLines: 4,
                    ),

                    // ── GAMBAR ──
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

                    // ── LOKASI & MAPS ──
                    _sectionLabel('Lokasi & Maps'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
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
                            controller: _lngCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
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
                    TextFormField(
                      controller: _mapsUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Maps URL (Google Maps)',
                      ),
                    ),

                    // ── VIRTUAL TOUR 360° ──
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
                      TextFormField(
                        controller: _panoIdCtrl,
                        decoration: const InputDecoration(
                          labelText:
                              'Photo Sphere ID (opsional, format AF1Qip...)',
                          helperText:
                              'Kosongkan jika pakai Street View berdasarkan koordinat',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _OrientationTile(
                        title: 'Orientasi Street View / Photo Sphere',
                        heading: _svHeading,
                        pitch: _svPitch,
                        onPreview: _openStreetViewPreview,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Foto 360° (UGC)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AdminImagePickerField(
                        label: 'Gambar Equirectangular 360°',
                        initialUrl: _img360Url.isNotEmpty ? _img360Url : null,
                        onUploaded:
                            (url) => setState(() {
                              _img360Url = url;
                              _image360UrlCtrl.clear();
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              child: Text(
                                'atau menggunakan link UGC 360 resmi Google Maps',
                                style: AppTextStyles.caption,
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _image360UrlCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Link URL Foto 360° (Google Maps UGC)',
                          helperText:
                              'Contoh: https://lh3.googleusercontent.com/gpms-cs-s/...',
                          prefixIcon: Icon(Icons.link_rounded),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _OrientationTile(
                        title: 'Orientasi Foto 360°',
                        heading: _img360Heading,
                        pitch: _img360Pitch,
                        onPreview: _openImage360Preview,
                      ),
                    ],

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
                                      : 'Tambah Tempat',
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

class _OrientationTile extends StatelessWidget {
  final String title;
  final double heading;
  final double pitch;
  final VoidCallback onPreview;
  const _OrientationTile({
    required this.title,
    required this.heading,
    required this.pitch,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) => Container(
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
