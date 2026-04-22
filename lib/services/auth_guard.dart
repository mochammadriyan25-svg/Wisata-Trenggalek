import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGuard {
  static bool isGuest() {
    return FirebaseAuth.instance.currentUser == null;
  }

  static void checkAndRun({
    required BuildContext context,
    required VoidCallback action,
    String redirectBackRoute = '/home_screen',
  }) {
    if (isGuest()) {
      _showLoginPrompt(context, redirectBackRoute);
    } else {
      action();
    }
  }

  static void _showLoginPrompt(
    BuildContext context,
    String redirectBackRoute,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LoginPromptSheet(
        redirectBackRoute: redirectBackRoute,
      ),
    );
  }
}


class _LoginPromptSheet extends StatelessWidget {
  final String redirectBackRoute;

  const _LoginPromptSheet({
    required this.redirectBackRoute,
  });

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
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Icon
          Container(
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
          ),

          const SizedBox(height: 16),

          // Title
          const Text(
            "Login Diperlukan",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          const Text(
            "Fitur ini hanya tersedia untuk pengguna\nyang sudah login.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          // Login button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // tutup bottom sheet
                Navigator.pushNamed(
                  context,
                  '/login',
                  arguments: {'redirectTo': redirectBackRoute},
                );
              },
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Dismiss button
          SizedBox(
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
              child: const Text(
                "Nanti Saja",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}