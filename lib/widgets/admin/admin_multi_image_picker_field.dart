// lib/widgets/admin/admin_multi_image_picker_field.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/services/cloudinary/cloudinary_service.dart';

class AdminMultiImagePickerField extends StatefulWidget {
  final List<String> initialUrls;
  final ValueChanged<List<String>> onChanged;
  final String label;

  const AdminMultiImagePickerField({
    super.key,
    this.initialUrls = const [],
    required this.onChanged,
    this.label = 'Galeri Gambar',
  });

  @override
  State<AdminMultiImagePickerField> createState() =>
      _AdminMultiImagePickerFieldState();
}

class _AdminMultiImagePickerFieldState
    extends State<AdminMultiImagePickerField> {
  late List<String> _urls;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _urls = List.of(widget.initialUrls);
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _isUploading = true);
    try {
      final url = await CloudinaryService.instance.uploadImage(
        File(picked.path),
      );
      setState(() {
        _urls.add(url);
        _isUploading = false;
      });
      widget.onChanged(_urls);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload gagal, coba lagi.'),
          backgroundColor: AppColors.error,
        ),
      );
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
                    'Tambah Gambar Galeri',
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

  void _remove(int index) {
    setState(() => _urls.removeAt(index));
    widget.onChanged(_urls);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_urls.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '${_urls.length} foto',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ..._urls.asMap().entries.map((entry) {
              final index = entry.key;
              final url = entry.value;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: Image.network(
                      url,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            width: 88,
                            height: 88,
                            color: AppColors.primarySurface,
                            child: const Icon(
                              Icons.broken_image_rounded,
                              color: AppColors.textHint,
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: GestureDetector(
                      onTap: () => _remove(index),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),

            // Add button
            InkWell(
              onTap: _isUploading ? null : _showSourcePicker,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child:
                    _isUploading
                        ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tambah',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
