import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../services/firestore/favorite_service.dart';
import '../services/firestore/destination_service.dart';
import 'detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() =>
      _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {

  final FavoriteService _favoriteService =
      FavoriteService();

  final DestinationService _destinationService =
      DestinationService();

  final String userId = "dummyUserId";

  String selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: SafeArea(
        child: Column(
          children: [

            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16),
              color: Colors.white,
              child: const Center(
                child: Text(
                  "Favorite Destinations",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
 const SizedBox(height: 16),
            // ================= FILTER =================
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 12,
                  left: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip("All"),
                    _chip("Nature"),
                    _chip("Cultural"),
                    _chip("Culinary"),
                  ],
                ),
              ),
            ),

            // ================= LIST FAVORITE =================
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: _favoriteService
                    .getUserFavoriteIds(userId),
                builder: (context, favSnapshot) {

                  if (favSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator());
                  }

                  if (!favSnapshot.hasData ||
                      favSnapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No favorite destinations yet",
                        style: TextStyle(
                            color: Colors.grey),
                      ),
                    );
                  }

                  final favoriteIds =
                      favSnapshot.data!;

                  return StreamBuilder<
                      List<DestinationModel>>(
                    stream:
                        _destinationService
                            .getAllDestinations(),
                    builder:
                        (context, destSnapshot) {

                      if (!destSnapshot
                          .hasData) {
                        return const Center(
                            child:
                                CircularProgressIndicator());
                      }

                      final allDestinations =
                          destSnapshot.data!;

                      final favorites =
                          allDestinations
                              .where((dest) =>
                                  favoriteIds
                                      .contains(
                                          dest.id))
                              .where((dest) =>
                                  selectedCategory ==
                                          "All"
                                      ? true
                                      : dest.category ==
                                          selectedCategory)
                              .toList();

                      return ListView.builder(
                        padding:
                            const EdgeInsets
                                .all(16),
                        itemCount:
                            favorites.length,
                        itemBuilder:
                            (context, index) {

                          final item =
                              favorites[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailPage(
                                    destination:
                                        item,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets
                                      .only(
                                          bottom:
                                              14),
                              padding:
                                  const EdgeInsets
                                      .all(12),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors
                                        .black
                                        .withOpacity(
                                            0.03),
                                    blurRadius:
                                        6,
                                  )
                                ],
                              ),
                              child: Row(
                                children: [

                                  // IMAGE
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                12),
                                    child:
                                        Image.network(
                                      item.imageUrl,
                                      width: 90,
                                      height: 90,
                                      fit:
                                          BoxFit
                                              .cover,
                                    ),
                                  ),

                                  const SizedBox(
                                      width: 14),

                                  // CONTENT
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [

                                            Expanded(
                                              child:
                                                  Text(
                                                item.name,
                                                style:
                                                    const TextStyle(
                                                  fontSize:
                                                      15,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            GestureDetector(
                                              onTap:
                                                  () {
                                                _favoriteService
                                                    .removeFavorite(
                                                        userId,
                                                        item.id);
                                              },
                                              child:
                                                  const Icon(
                                                Icons
                                                    .favorite,
                                                color:
                                                    Colors.red,
                                              ),
                                            )
                                          ],
                                        ),

                                        const SizedBox(
                                            height:
                                                6),

                                        Row(
                                          children: [
                                            const Icon(
                                              Icons
                                                  .location_on,
                                              size:
                                                  14,
                                              color:
                                                  Colors.grey,
                                            ),
                                            const SizedBox(
                                                width:
                                                    4),
                                            Text(
                                              item
                                                  .location,
                                              style:
                                                  const TextStyle(
                                                fontSize:
                                                    12,
                                                color:
                                                    Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(
                                            height:
                                                10),

                                        Row(
                                          children: [

                                            Container(
                                              padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                          horizontal:
                                                              6,
                                                          vertical:
                                                              2),
                                              decoration:
                                                  BoxDecoration(
                                                color: Colors
                                                    .amber
                                                    .shade50,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        6),
                                              ),
                                              child:
                                                  Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .star,
                                                    size:
                                                        12,
                                                    color:
                                                        Colors.amber,
                                                  ),
                                                  const SizedBox(
                                                      width:
                                                          3),
                                                  Text(
                                                    item.rating
                                                        .toString(),
                                                    style:
                                                        const TextStyle(
                                                      fontSize:
                                                          11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(
                                                width:
                                                    8),

                                            Text(
                                              item
                                                  .category,
                                              style:
                                                  const TextStyle(
                                                fontSize:
                                                    11,
                                                color:
                                                    Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String name) {
    final isSelected =
        selectedCategory == name;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = name;
        });
      },
      child: Container(
        margin:
            const EdgeInsets.only(
                right: 10),
        padding:
            const EdgeInsets
                .symmetric(
                    horizontal: 18,
                    vertical: 8),
        decoration:
            BoxDecoration(
          color: isSelected
              ? Colors.green
              : Colors.white,
          borderRadius:
              BorderRadius.circular(
                  20),
          border: Border.all(
              color:
                  Colors.grey.shade300),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 13,
            color: isSelected
                ? Colors.white
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}