import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../services/firestore/destination_service.dart';
import 'detail_page.dart';

class SearchResultPage extends StatefulWidget {
  final String initialQuery;
  final String initialCategory;

  const SearchResultPage({
    super.key,
    required this.initialQuery,
    required this.initialCategory,
  });

  @override
  State<SearchResultPage> createState() =>
      _SearchResultPageState();
}

class _SearchResultPageState
    extends State<SearchResultPage> {

  final DestinationService _service =
      DestinationService();

  late String searchQuery;
  late String selectedCategory;

  final TextEditingController _controller =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    searchQuery = widget.initialQuery;
    selectedCategory =
        widget.initialCategory;
    _controller.text = searchQuery;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F6FA),
      body: Column(
        children: [

          // ================= HEADER =================
          Container(
            padding:
                const EdgeInsets.only(
                    top: 20,
                    left: 16,
                    right: 16,
                    bottom: 16),
            color: Colors.white,
            child: Column(
              children: [

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(
                            context);
                      },
                      icon: const Icon(
                          Icons.arrow_back),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Destinations",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                          Icons.notifications),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // SEARCH FIELD
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                              horizontal:
                                  16),
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .grey.shade100,
                    borderRadius:
                        BorderRadius
                            .circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                          Icons.search,
                          color:
                              Colors.grey),
                      const SizedBox(
                          width: 8),
                      Expanded(
                        child: TextField(
                          controller:
                              _controller,
                          onChanged:
                              (value) {
                            setState(() {
                              searchQuery =
                                  value;
                            });
                          },
                          decoration:
                              const InputDecoration(
                            border:
                                InputBorder
                                    .none,
                            hintText:
                                "Search places in Trenggalek...",
                          ),
                        ),
                      ),
                      const Icon(
                          Icons.tune,
                          color:
                              Colors.grey),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),

          // ================= LIST =================
          Expanded(
            child: StreamBuilder<
                List<DestinationModel>>(
              stream:
                  _service.getAllDestinations(),
              builder:
                  (context, snapshot) {

                if (!snapshot
                    .hasData) {
                  return const Center(
                      child:
                          CircularProgressIndicator());
                }

                final allData =
                    snapshot.data!;

                final filtered =
                    allData.where((item) {

                  final matchSearch =
                      item.name
                          .toLowerCase()
                          .contains(
                              searchQuery
                                  .toLowerCase());

                  final matchCategory =
                      selectedCategory ==
                              "All"
                          ? true
                          : item.category ==
                              selectedCategory;

                  return matchSearch &&
                      matchCategory;
                }).toList();

                return ListView.builder(
                  padding:
                      const EdgeInsets
                          .all(16),
                  itemCount:
                      filtered.length,
                  itemBuilder:
                      (context, index) {

                    final item =
                        filtered[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    DetailPage(
                              destination:
                                  item,
                            ),
                          ),
                        );
                      },
                      child:
                          Container(
                        margin:
                            const EdgeInsets
                                .only(
                                    bottom:
                                        20),
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors
                                  .black
                                  .withOpacity(
                                      0.04),
                              blurRadius:
                                  8,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [

                            // IMAGE
                            Stack(
                              children: [

                                ClipRRect(
                                  borderRadius:
                                      const BorderRadius
                                          .vertical(
                                    top:
                                        Radius.circular(
                                            20),
                                  ),
                                  child:
                                      AspectRatio(
                                    aspectRatio:
                                        4 / 3,
                                    child:
                                        Image.network(
                                      item
                                          .imageUrl,
                                      fit: BoxFit
                                          .cover,
                                    ),
                                  ),
                                ),

                                // FAVORITE BUTTON
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child:
                                      Container(
                                    height:
                                        36,
                                    width:
                                        36,
                                    decoration:
                                        BoxDecoration(
                                      color: Colors
                                          .white
                                          .withOpacity(
                                              0.9),
                                      shape:
                                          BoxShape
                                              .circle,
                                    ),
                                    child:
                                        const Icon(
                                      Icons
                                          .favorite_border,
                                      color: Colors
                                          .grey,
                                    ),
                                  ),
                                ),

                                // RATING
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  child:
                                      Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                                horizontal:
                                                    8,
                                                vertical:
                                                    4),
                                    decoration:
                                        BoxDecoration(
                                      color: Colors
                                          .white
                                          .withOpacity(
                                              0.9),
                                      borderRadius:
                                          BorderRadius.circular(
                                              8),
                                    ),
                                    child:
                                        Row(
                                      children: [
                                        const Icon(
                                          Icons
                                              .star,
                                          size:
                                              14,
                                          color: Colors
                                              .amber,
                                        ),
                                        const SizedBox(
                                            width:
                                                4),
                                        Text(
                                          item.rating
                                              .toString(),
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                12,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // CONTENT
                            Padding(
                              padding:
                                  const EdgeInsets
                                      .all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [

                                  Text(
                                    item.name,
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          18,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
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
                                            16,
                                        color: Colors
                                            .grey,
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
                                              13,
                                          color:
                                              Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                      height:
                                          12),

                                  Wrap(
                                    spacing:
                                        8,
                                    children: [
                                      _tag(
                                          item
                                              .category),
                                      const _TagPopular(),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding:
          const EdgeInsets
              .symmetric(
                  horizontal: 10,
                  vertical: 4),
      decoration:
          BoxDecoration(
        color: Colors
            .blue.shade50,
        borderRadius:
            BorderRadius.circular(
                6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color:
              Colors.blue.shade700,
        ),
      ),
    );
  }
}

class _TagPopular
    extends StatelessWidget {
  const _TagPopular();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets
              .symmetric(
                  horizontal: 10,
                  vertical: 4),
      decoration:
          BoxDecoration(
        color:
            Colors.grey.shade200,
        borderRadius:
            BorderRadius.circular(
                6),
      ),
      child: const Text(
        "Popular",
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }
}