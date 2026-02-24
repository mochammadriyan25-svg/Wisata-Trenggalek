import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [
          _buildItem(
              icon: Icons.home,
              label: "Home",
              index: 0),
          _buildItem(
              icon: Icons.explore,
              label: "Explore",
              index: 1),
          _buildItem(
              icon: Icons.favorite,
              label: "Favorites",
              index: 2),
          _buildItem(
              icon: Icons.person,
              label: "Profile",
              index: 3),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive =
        currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Stack(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isActive
                      ? const Color(0xFF059669)
                      : Colors.grey,
                ),

                if (isActive)
                  Positioned(
                    top: 0,
                    right: -2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration:
                          const BoxDecoration(
                        color:
                            Color(0xFF059669),
                        shape:
                            BoxShape.circle,
                      ),
                    ),
                  )
              ],
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w500,
                color: isActive
                    ? const Color(
                        0xFF059669)
                    : Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }
}