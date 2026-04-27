// lib/core/utils/auth_guard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/home/login_prompt_sheet.dart';

class AuthGuard {
  static bool isGuest(BuildContext context) {
    return context.read<AuthProvider>().isGuest;
  }

  static void checkAndRun({
    required BuildContext context,
    required VoidCallback action,
    String redirectBackRoute = '/home_screen',
  }) {
    if (isGuest(context)) {
      _showLoginPrompt(context, redirectBackRoute);
    } else {
      action();
    }
  }

  static void _showLoginPrompt(BuildContext context, String redirectBackRoute) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LoginPromptSheet(redirectBackRoute: redirectBackRoute),
    );
  }
}