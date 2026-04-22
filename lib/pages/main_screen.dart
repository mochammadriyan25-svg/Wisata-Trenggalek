import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/explore_page.dart';
import '../pages/favorite_page.dart';
import '../pages/profil_page.dart';
import '../widget/bottom_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() =>
      _MainScreenState();
}

class _MainScreenState
    extends State<MainScreen> {

  int currentIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    ExplorePage(),
    FavoritePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar:
          BottomNavbar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}