import 'package:flutter/material.dart';

class PopularItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String rating;
  final String views;

  const PopularItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Text("⭐ $rating • $views"),
              ],
            ),
          )
        ],
      ),
    );
  }
}