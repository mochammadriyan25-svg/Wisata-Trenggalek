import 'package:aplikasi_wisata/widget/category.dart';
import 'package:aplikasi_wisata/widget/popular_item.dart';
import 'package:aplikasi_wisata/widget/recommended.dart';
import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              // LOCATION HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Current Location",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.teal),
                          SizedBox(width: 4),
                          Text(
                            "Trenggalek, East Java",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ],
                      )
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.notifications_none),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // TITLE
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Discover ",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: "Paradise",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    TextSpan(
                      text: "\nin Trenggalek",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Find the best spots for your next adventure.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // SEARCH BAR
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: "Search destinations, tours...",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // CATEGORIES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Categories",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "See All",
                    style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    CategoryItem(
                        icon: Icons.park, label: "Nature"),
                    CategoryItem(
                        icon: Icons.account_balance,
                        label: "Culture"),
                    CategoryItem(
                        icon: Icons.restaurant,
                        label: "Culinary"),
                    CategoryItem(
                        icon: Icons.beach_access,
                        label: "Beach"),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // RECOMMENDED
              const Text(
                "Recommended",
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 230,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    RecommendedCard(
                      title: "Prigi Beach",
                      location: "Watulimo, Trenggalek",
                      price: "Free Entry",
                      rating: "4.8",
                    ),
                    RecommendedCard(
                      title: "Pelangi Waterfall",
                      location: "Panggul, Trenggalek",
                      price: "\$2.00 / person",
                      rating: "4.7",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // POPULAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Popular Virtual Tours",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "View All",
                    style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),

              const SizedBox(height: 15),

              const PopularItem(
                title: "Mangrove Forest 360°",
                subtitle:
                    "Experience the lush greenery of the forest",
                rating: "4.7",
                views: "1.2k Views",
              ),

              const PopularItem(
                title: "Traditional Dance VR",
                subtitle:
                    "Immerse yourself in the traditional performance",
                rating: "4.9",
                views: "850 Views",
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}