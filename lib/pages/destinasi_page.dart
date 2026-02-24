import 'package:aplikasi_wisata/widget/destinations.dart';
import 'package:flutter/material.dart';

class DestinationsPage extends StatefulWidget {
  const DestinationsPage({super.key});

  @override
  State<DestinationsPage> createState() =>
      _DestinationsPageState();
}

class _DestinationsPageState
    extends State<DestinationsPage> {

  String selectedCategory = "All Places";

  final List<String> categories = [
    "All Places",
    "Beaches",
    "Caves",
    "Waterfalls",
    "Historic",
  ];

  final List<Map<String, dynamic>> destinations = [
    {
      "title": "Pasir Putih Beach",
      "location": "Watulimo, Trenggalek",
      "rating": "4.8",
      "tags": ["Beach", "Popular"]
    },
    {
      "title": "Lowo Cave",
      "location": "Watulimo, Trenggalek",
      "rating": "4.5",
      "tags": ["Nature", "Cave"]
    },
    {
      "title": "Pelang Waterfall",
      "location": "Panggul, Trenggalek",
      "rating": "4.7",
      "tags": ["Waterfall"]
    },
    {
      "title": "Dam Bagong",
      "location": "Trenggalek City",
      "rating": "4.2",
      "tags": ["Historic"]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Destinations",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_none,
                color: Colors.black),
          )
        ],
      ),
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [

            const SizedBox(height: 10),

            // SEARCH BAR
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText:
                      "Search places in Trenggalek...",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // CATEGORY FILTER
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection:
                    Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
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
                          const EdgeInsets.only(
                              right: 10),
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

            // LIST DESTINATIONS
            Expanded(
              child: ListView.builder(
                itemCount:
                    destinations.length,
                itemBuilder:
                    (context, index) {
                  final item =
                      destinations[index];

                  return DestinationCard(
                    title: item["title"],
                    location:
                        item["location"],
                    rating:
                        item["rating"],
                    tags:
                        List<String>.from(
                            item["tags"]),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}