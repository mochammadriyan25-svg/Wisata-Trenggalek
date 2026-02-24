import 'package:flutter/material.dart';

class DestinationCard extends StatelessWidget {
  final String title;
  final String location;
  final String rating;
  final List<String> tags;

  const DestinationCard({
    super.key,
    required this.title,
    required this.location,
    required this.rating,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          // IMAGE AREA
          Stack(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius:
                      const BorderRadius
                          .vertical(
                    top:
                        Radius.circular(
                            20),
                  ),
                ),
              ),

              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor:
                      Colors.white,
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.grey,
                  ),
                ),
              ),

              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                              horizontal:
                                  8,
                              vertical: 4),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(
                                12),
                  ),
                  child:
                      Text("⭐ $rating"),
                ),
              )
            ],
          ),

          // CONTENT
          Padding(
            padding:
                const EdgeInsets.all(
                    14),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight:
                          FontWeight
                              .bold,
                      fontSize: 16),
                ),
                const SizedBox(
                    height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color:
                          Colors.grey,
                    ),
                    const SizedBox(
                        width: 4),
                    Text(
                      location,
                      style:
                          const TextStyle(
                        color:
                            Colors.grey,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                    height: 10),
                Wrap(
                  spacing: 6,
                  children: tags
                      .map((tag) =>
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                                        horizontal:
                                            10,
                                        vertical:
                                            5),
                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .grey[200],
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          8),
                            ),
                            child:
                                Text(tag,
                                    style:
                                        const TextStyle(
                                            fontSize:
                                                12)),
                          ))
                      .toList(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}