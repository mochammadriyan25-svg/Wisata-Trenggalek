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

  @override
  void initState() {
    super.initState();
    _previewUrl = widget.initialUrl;
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: AppColors.primary),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Pilih dari Galeri'),
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
        Text(widget.label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _isUploading ? null : _showSourcePicker,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.divider),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildContent(),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
        ],
      ],
    );
  }

  Widget _buildContent() {
    if (_isUploading) return const Center(child: CircularProgressIndicator());
    if (_localFile != null) {
      return Image.file(_localFile!, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }
    if (_previewUrl != null && _previewUrl!.isNotEmpty) {
      return Image.network(
        _previewUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.add_a_photo_rounded, size: 36, color: AppColors.textHint),
        const SizedBox(height: AppSpacing.xs),
        Text('Tap untuk pilih gambar', style: AppTextStyles.caption),
      ],
    ),
  );
}