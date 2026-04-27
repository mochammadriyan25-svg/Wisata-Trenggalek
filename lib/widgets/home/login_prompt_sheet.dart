// lib/widgets/login_prompt_sheet.dart

import 'package:flutter/material.dart';

class LoginPromptSheet extends StatelessWidget {
  const LoginPromptSheet({
    super.key,
    required this.redirectBackRoute,
  });

  final String redirectBackRoute;

  void _navigateToLogin(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/login',
      arguments: {'redirectTo': redirectBackRoute},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          const SizedBox(height: 24),
          _buildIcon(),
          const SizedBox(height: 16),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildSubtitle(),
          const SizedBox(height: 28),
          _buildLoginButton(context),
          const SizedBox(height: 12),
          _buildDismissButton(context),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13EC80).withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.lock_outline_rounded,
        size: 36,
        color: Color(0xFF059669),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      "Login Diperlukan",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      "Fitur ini hanya tersedia untuk pengguna\nyang sudah login.",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _navigateToLogin(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF13EC80),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          "Login Sekarang",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildDismissButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text("Nanti Saja", style: TextStyle(fontSize: 14)),
      ),
    );
  }
}