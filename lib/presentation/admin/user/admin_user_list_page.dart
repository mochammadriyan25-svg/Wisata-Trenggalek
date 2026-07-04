// lib/presentation/admin/user/admin_user_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/theme/app_colors.dart';
import 'package:aplikasi_wisata/core/theme/app_spacing.dart';
import 'package:aplikasi_wisata/core/theme/app_text_styles.dart';
import 'package:aplikasi_wisata/data/models/user_model.dart';
import 'package:aplikasi_wisata/providers/admin_provider.dart';
import 'admin_user_detail_page.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  final _searchController = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _filter(List<UserModel> source) {
    if (_keyword.isEmpty) return source;
    return source.where((u) {
      final kw = _keyword;
      return u.name.toLowerCase().contains(kw) ||
          u.email.toLowerCase().contains(kw);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final list = _filter(admin.allUsers);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
            child: TextField(
              controller: _searchController,
              onChanged: (v) =>
                  setState(() => _keyword = v.toLowerCase().trim()),
              decoration: InputDecoration(
                hintText: 'Cari nama atau email...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _keyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _keyword = '');
                        })
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    borderSide: BorderSide(color: AppColors.divider)),
              ),
            ),
          ),
        ),
      ),
      body: admin.usersLoading
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? _buildEmpty()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                              '${list.length} pengguna terdaftar',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: list.length,
                        itemBuilder: (context, i) =>
                            _UserCard(user: list[i]),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
              child:
                  const Icon(Icons.people_rounded, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(_keyword.isNotEmpty ? 'Tidak ada hasil' : 'Belum ada pengguna',
                style:
                    AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => AdminUserDetailPage(user: user))),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primarySurface,
              backgroundImage: user.photoUrl.isNotEmpty
                  ? NetworkImage(user.photoUrl)
                  : null,
              child: user.photoUrl.isEmpty
                  ? Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: AppColors.primary))
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(user.name,
                            style: AppTextStyles.bodyLarge
                                .copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (user.isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppColors.starColor.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.shield_rounded,
                                size: 10, color: AppColors.starColor),
                            const SizedBox(width: 3),
                            Text('Admin',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.starColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10)),
                          ]),
                        ),
                    ]),
                    const SizedBox(height: 2),
                    Text(user.email,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 20),
          ]),
        ),
      ),
    );
  }
}