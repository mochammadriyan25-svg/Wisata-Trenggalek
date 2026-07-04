// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_wisata/core/constants/app_route.dart';
import 'package:aplikasi_wisata/core/theme/app_theme.dart';
import 'package:aplikasi_wisata/providers/auth_provider.dart';
import 'package:aplikasi_wisata/providers/review_provider.dart';
import 'package:aplikasi_wisata/providers/destination_provider.dart';
import 'package:aplikasi_wisata/providers/favorite_provider.dart';
import 'package:aplikasi_wisata/providers/category_provider.dart';
import 'package:aplikasi_wisata/providers/package_provider.dart';
import 'package:aplikasi_wisata/providers/accommodation_provider.dart';
import 'package:aplikasi_wisata/providers/admin_provider.dart';
import 'package:aplikasi_wisata/providers/place_provider.dart'; // [NEW]
import 'screens/splash_screen.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());
  }
}

class TrenggalekTourismApp extends StatelessWidget {
  const TrenggalekTourismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => AccommodationProvider()),
        ChangeNotifierProvider(create: (_) => PackageProvider()..init()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        // [NEW] PlaceProvider — stream semua tempat ibadah & kesehatan
        // Di-stream dari awal agar recommendation sections tidak ada loading delay.
        ChangeNotifierProvider(create: (_) => PlaceProvider()),
        ChangeNotifierProxyProvider<AuthProvider, FavoriteProvider>(
          create: (_) => FavoriteProvider(),
          update: (_, authProvider, favoriteProvider) {
            final provider = favoriteProvider ?? FavoriteProvider();
            final userId = authProvider.user?.id;
            if (authProvider.status == AuthStatus.authenticated &&
                userId != null) {
              provider.init(userId);
            } else if (authProvider.status == AuthStatus.unauthenticated) {
              provider.reset();
            }
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        scrollBehavior: AppScrollBehavior(),
        home: const SplashScreen(),
        routes: AppRoutes.routes,
      ),
    );
  }
}
