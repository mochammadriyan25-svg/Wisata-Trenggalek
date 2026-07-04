// lib/presentation/pages/profil_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/data/services/cloudinary/cloudinary_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final firestore = FirebaseFirestore.instance;

  // Foto profil — URL dari Firestore (persistent) atau local preview saat upload
  String _photoUrl = '';
  File?
  _localImageFile; // hanya untuk preview sementara saat upload berlangsung
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Future<void> loadUserData() async {
    final user = _currentUser;
    if (user == null) return;
    try {
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        final data = doc.data();
        setState(() {
          nameController.text = data?['name'] ?? '';
          phoneController.text = data?['phone'] ?? '';
          _photoUrl = data?['photoUrl'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loadUserData: $e');
    }
  }

  Future<void> saveUserData() async {
    final user = _currentUser;
    if (user == null) return;
    await firestore.collection('users').doc(user.uid).set({
      'name': nameController.text,
      'phone': phoneController.text,
      'email': user.email,
    }, SetOptions(merge: true));
  }

  // ── FOTO PROFIL ───────────────────────────────────────────────────────────

  /// Tampilkan bottom sheet pilihan sumber foto.
  void _showPhotoPicker() {
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
                    'Ganti Foto Profil',
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

  /// Pick foto → upload ke Cloudinary → simpan URL ke Firestore.
  Future<void> _pickAndUpload(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final file = File(picked.path);
    setState(() {
      _localImageFile = file; // tampil preview lokal saat upload
      _isUploadingPhoto = true;
    });

    try {
      final url = await CloudinaryService.instance.uploadImage(file);
      if (!mounted) return;

      // Simpan URL ke Firestore
      final user = _currentUser;
      if (user != null) {
        await firestore.collection('users').doc(user.uid).set({
          'photoUrl': url,
        }, SetOptions(merge: true));
      }

      if (mounted) {
        setState(() {
          _photoUrl = url;
          _localImageFile = null; // beralih ke network URL
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _localImageFile = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload foto: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  /// Image provider untuk avatar: local preview > network URL > placeholder.
  ImageProvider get _avatarImage {
    if (_localImageFile != null) return FileImage(_localImageFile!);
    if (_photoUrl.isNotEmpty) return NetworkImage(_photoUrl);
    return const NetworkImage('https://i.pravatar.cc/150');
  }

  // ── EDIT FIELD ────────────────────────────────────────────────────────────

  void editField(String title, TextEditingController controller) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            title: Text(
              'Edit $title',
              style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
            ),
            content: TextField(
              controller: controller,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.primarySurface,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(
                    color: AppColors.divider,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.8,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 4,
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.divider, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    await saveUserData();
                    if (mounted) setState(() {});
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ── INFO ITEM ROW ─────────────────────────────────────────────────────────

  Widget _infoItem(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap, {
    bool readOnly = false,
  }) {
    return GestureDetector(
      onTap: readOnly ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.divider, width: 1),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: AppSpacing.iconMd,
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value.isEmpty ? '-' : value,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (!readOnly)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
                size: AppSpacing.iconMd,
              ),
          ],
        ),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    // ── Guest state
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Silakan login untuk melihat profil',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.pushReplacementNamed(context, '/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.sm + 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                    child: Text('Login', style: AppTextStyles.buttonLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Main profile
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER — selaras dengan _FavoriteHeader di favorite_page.dart
            // [CHANGED] Hapus back button, pakai icon + teks "Profil"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.divider.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowNeutral.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.textOnDark,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Text(
                    'Profil',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // ── BODY
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ── AVATAR CARD
                    Container(
                      width: double.infinity,
                      color: AppColors.surface,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xl,
                        horizontal: AppSpacing.md,
                      ),
                      child: Column(
                        children: [
                          // Avatar dengan tombol edit
                          Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.primaryGradient,
                                  border: Border.all(
                                    color: AppColors.primarySurface,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                  // Image dari local preview atau network URL
                                  image:
                                      _isUploadingPhoto
                                          ? null
                                          : DecorationImage(
                                            image: _avatarImage,
                                            fit: BoxFit.cover,
                                          ),
                                ),
                                child:
                                    _isUploadingPhoto
                                        ? const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.textOnDark,
                                        )
                                        : null,
                              ),

                              // Edit badge — tap buka picker kamera/galeri
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap:
                                      _isUploadingPhoto
                                          ? null
                                          : _showPhotoPicker,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.surface,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      size: 14,
                                      color: AppColors.textOnDark,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Nama
                          Text(
                            nameController.text.isEmpty
                                ? 'Your Name'
                                : nameController.text,
                            style: AppTextStyles.headlineLarge.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),

                          // Email
                          Text(
                            user.email ?? '-',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textHint,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Member badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs + 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.earthSurface,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull,
                              ),
                              border: Border.all(
                                color: AppColors.earthLight,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_outlined,
                                  size: 13,
                                  color: AppColors.earth,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Member Wisata Trenggalek',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textEarth,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // ── INFO ITEMS
                    Container(
                      color: AppColors.surface,
                      child: Column(
                        children: [
                          _infoItem(
                            'Full Name',
                            nameController.text,
                            Icons.person_outline_rounded,
                            () => editField('Name', nameController),
                          ),
                          _infoItem(
                            'Phone Number',
                            phoneController.text,
                            Icons.phone_outlined,
                            () => editField('Phone', phoneController),
                          ),
                          _infoItem(
                            'Email',
                            user.email ?? '',
                            Icons.mail_outline_rounded,
                            () {},
                            readOnly: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // ── LOGOUT
                    Container(
                      color: AppColors.surface,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: logout,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            backgroundColor: AppColors.error.withValues(
                              alpha: 0.05,
                            ),
                            side: BorderSide(
                              color: AppColors.error.withValues(alpha: 0.3),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.logout_rounded,
                            size: AppSpacing.iconMd,
                          ),
                          label: Text(
                            'Logout',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.waves_rounded,
                          size: 10,
                          color: AppColors.primaryLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '© 2026 Virtual Tourism Trenggalek',
                          style: AppTextStyles.labelSpacedSubtle,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
