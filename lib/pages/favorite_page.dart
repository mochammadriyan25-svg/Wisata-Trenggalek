import 'package:aplikasi_wisata/widget/favorite.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() =>
      _FavoritesPageState();
}

class _FavoritesPageState
    extends State<FavoritesPage> {

  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Nature",
    "Cultural",
    "Culinary",
  ];

  final List<Map<String, dynamic>> favorites = [
    {
      "title": "Pantai Prigi",
      "location": "Watulimo, Trenggalek",
      "rating": "4.8",
      "reviews": "1.2k reviews",
      "icon": Icons.landscape
    },
    {
      "title": "Goa Lowo",
      "location": "Watulimo, Trenggalek",
      "rating": "4.6",
      "reviews": "850 reviews",
      "icon": Icons.nature_people
    },
    {
      "title": "Hutan Kota",
      "location": "Trenggalek City",
      "rating": "4.5",
      "reviews": "320 reviews",
      "icon": Icons.park
    },
    {
      "title": "Puncak Jaas",
      "location": "Tugu, Trenggalek",
      "rating": "4.7",
      "reviews": "210 reviews",
      "icon": Icons.hiking
    },
    {
      "title": "Air Terjun Pelang",
      "location": "Panggul, Trenggalek",
      "rating": "4.4",
      "reviews": "180 reviews",
      "icon": Icons.water_drop
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black),
          onPressed: () =>
              Navigator.pop(context),
        ),
        title: const Text(
          "Favorite Destinations",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [

          const SizedBox(height: 15),

          // CATEGORY FILTER
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection:
                  Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 16),
              itemCount: categories.length,
              itemBuilder:
                  (context, index) {
                final category =
                    categories[index];
                final isSelected =
                    category ==
                        selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory =
                          category;
                    });
                  },
                  child: Container(
                    margin:
                        const EdgeInsets
                            .only(right: 10),
                    padding:
                        const EdgeInsets
                            .symmetric(
                                horizontal:
                                    18),
                    decoration:
                        BoxDecoration(
                      color: isSelected
                          ? Colors.black
                          : Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                                  25),
                      border: Border.all(
                        color:
                            Colors.grey
                                .shade300,
                      ),
                    ),
                    alignment:
                        Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 15),

          // FAVORITE LIST
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 16),
              itemCount: favorites.length,
              itemBuilder:
                  (context, index) {
                final item =
                    favorites[index];

                return FavoriteCard(
                  title:
                      item["title"],
                  location:
                      item["location"],
                  rating:
                      item["rating"],
                  reviews:
                      item["reviews"],
                  icon:
                      item["icon"],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}