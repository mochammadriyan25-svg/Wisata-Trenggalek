import 'package:flutter/material.dart';

class FavoriteCard extends StatelessWidget {
  final String title;
  final String location;
  final String rating;
  final String reviews;
  final IconData icon;

  const FavoriteCard({
    super.key,
    required this.title,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 16),
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [

          // IMAGE
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius:
                  BorderRadius.circular(
                      12),
            ),
            child: Icon(
              icon,
              size: 35,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(width: 14),

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
                      child: Text(
                        title,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                          fontSize:
                              15,
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.red
                                .withOpacity(
                                    0.1),
                        shape: BoxShape
                            .circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color:
                            Colors.red,
                        size: 18,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 6),

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
                        fontSize:
                            12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color:
                          Colors.amber,
                    ),
                    const SizedBox(
                        width: 4),
                    Text(
                      rating,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                    const SizedBox(
                        width: 8),
                    Text(
                      "($reviews)",
                      style:
                          const TextStyle(
                        fontSize:
                            12,
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}