// lib/core/constants/app_routes.dart
import 'package:flutter/material.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../screens/main_screen.dart';
import '../../presentation/admin/admin_dashboard_page.dart'; // ✅ TAMBAH


class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home_screen';
  static const String adminDashboard = '/admin_dashboard'; // ✅ TAMBAH


  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const MainScreen(),
    adminDashboard: (_) => const AdminDashboardPage(), // ✅ TAMBAH

  };
}