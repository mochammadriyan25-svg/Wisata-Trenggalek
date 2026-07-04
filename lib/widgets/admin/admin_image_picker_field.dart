// lib/widgets/admin/admin_image_picker_field.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/services/cloudinary/cloudinary_service.dart';

/// Upload 1 gambar (kamera ATAU galeri) ke Cloudinary.
/// [initialUrl] = URL existing saat mode edit. [onUploaded] dipanggil
/// dengan URL final setelah upload sukses.
class AdminImagePickerField extends StatefulWidget {
  final String? initialUrl;
  final ValueChanged<String> onUploaded;
  final String label;

  const AdminImagePickerField({
    super.key,
    this.initialUrl,
    required this.onUploaded,
    this.label = 'Gambar',
  });

  @override
  State<AdminImagePickerField> createState() => _AdminImagePickerFieldState();
}

class _AdminImagePickerFieldState extends State<AdminImagePickerField> {
  String? _previewUrl;
  File? _localFile;
  bool _isUploading = false;
  String? _error;

  bool get _hasImage =>
      _localFile != null || (_previewUrl != null && _previewUrl!.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _previewUrl = widget.initialUrl;
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _localFile = file;
      _isUploading = true;
      _error = null;
    });

    try {
      final url = await CloudinaryService.instance.uploadImage(file);
      if (!mounted) return;
      setState(() {
        _previewUrl = url;
        _localFile = null;
        _isUploading = false;
      });
      widget.onUploaded(url);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _error = 'Upload gagal, coba lagi.';
      });
    }
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  child: Text(
                    widget.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text('Ambil dari Kamera'),
                  subtitle: const Text('Foto langsung menggunakan kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUpload(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text('Pilih dari Galeri'),
                  subtitle: const Text('Pilih foto yang sudah ada'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUpload(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _isUploading ? null : _showSourcePicker,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _hasImage ? Colors.transparent : AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color:
                    _error != null
                        ? AppColors.error
                        : _hasImage
                        ? AppColors.divider
                        : AppColors.primary.withValues(alpha: 0.35),
                width: _hasImage ? 1 : 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildContent(),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  _error!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _showSourcePicker,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Coba lagi',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isUploading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.sm),
          Text('Mengunggah...', style: AppTextStyles.caption),
        ],
      );
    }

    if (_localFile != null) {
      return Image.file(
        _localFile!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_previewUrl != null && _previewUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _previewUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          ),
          // Edit overlay button
          Positioned(
            bottom: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit_rounded,
                    size: 13,
                    color: AppColors.textOnDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ganti',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return _placeholder();
  }

  Widget _placeholder() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: const Icon(
            Icons.add_a_photo_rounded,
            size: 26,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Tap untuk pilih gambar',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text('Kamera atau Galeri', style: AppTextStyles.caption),
      ],
    ),
  );
}
