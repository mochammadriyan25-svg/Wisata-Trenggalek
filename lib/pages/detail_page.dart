import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String title;
  final String location;
  final double rating;
  final String category;
  final String description;

  const DetailPage({
    super.key,
    required this.title,
    required this.location,
    required this.rating,
    required this.category,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [

          // CONTENT
          SingleChildScrollView(
            child: Column(
              children: [

                // IMAGE HEADER
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.landscape,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    // GRADIENT
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black26,
                              Colors.transparent
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 360 BUTTON
                    Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.view_in_ar,
                                size: 30,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Tap for 360° Tour",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),

                    // CATEGORY BADGE
                    Positioned(
                      bottom: 15,
                      left: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ),
                    )
                  ],
                ),

                // CONTENT SECTION
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25)),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      // TITLE + RATING
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 18,
                                  color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                rating.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 18,
                              color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: const TextStyle(
                                color: Colors.grey),
                          )
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "About Destination",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        description,
                        style: const TextStyle(
                            color: Colors.grey,
                            height: 1.5),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "Nearby Amenities",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        height: 80,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: const [
                            AmenityItem(
                                icon: Icons.hotel,
                                label: "Hotel"),
                            AmenityItem(
                                icon: Icons.restaurant,
                                label: "Dining"),
                            AmenityItem(
                                icon: Icons.local_mall,
                                label: "Souvenir"),
                            AmenityItem(
                                icon: Icons.local_parking,
                                label: "Parking"),
                            AmenityItem(
                                icon: Icons.wc,
                                label: "Restroom"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "Location",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(Icons.location_on,
                              size: 40,
                              color: Colors.green),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Entrance Fee",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Adult"),
                                Text("IDR 15.000")
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Child"),
                                Text("IDR 10.000")
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Row(
                        children: [

                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 15),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          12),
                                ),
                              ),
                              icon: const Icon(
                                  Icons.favorite),
                              label: const Text(
                                  "Add to Favorites"),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey),
                            ),
                            child: const Icon(
                                Icons.share),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

          // TOP BAR
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black),
                    onPressed: () =>
                        Navigator.pop(context),
                  ),
                ),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.more_horiz,
                      color: Colors.black),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AmenityItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const AmenityItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Icon(icon,
                color: Colors.orange),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12))
        ],
      ),
    );
  }
}