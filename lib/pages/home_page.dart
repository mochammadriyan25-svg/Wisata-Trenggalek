import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firestore/destination_service.dart';
import '../services/firestore/category_service.dart';
import '../models/destination_model.dart';
import '../models/category_model.dart';
import 'detail_page.dart';
import 'explore_page.dart';
import '../utils/icon_mapper.dart';

class HomePage extends StatefulWidget {
const HomePage({super.key});

@override
State<HomePage> createState() =>
_HomePageState();
}

class _HomePageState extends State<HomePage> {

final DestinationService destinationService =
DestinationService();

final CategoryService categoryService =
CategoryService();

final TextEditingController searchController =
TextEditingController();

final List<String> banners = [
"assets/1.png",
"assets/2.png",
];

final PageController _pageController =
PageController(viewportFraction: 0.92);

final ScrollController _categoryController =
ScrollController();

int currentBanner = 0;
double categoryScroll = 0;

Timer? bannerTimer;

@override
void initState() {
super.initState();

bannerTimer =
    Timer.periodic(const Duration(seconds: 4),
        (timer) {

  if (_pageController.hasClients) {

    currentBanner++;

    if (currentBanner >= banners.length) {
      currentBanner = 0;
    }

    _pageController.animateToPage(
      currentBanner,
      duration:
          const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
});

_categoryController.addListener(() {
  setState(() {
    categoryScroll =
        _categoryController.offset;
  });
});

}

@override
void dispose() {
bannerTimer?.cancel();
_pageController.dispose();
_categoryController.dispose();
super.dispose();
}

Color categoryColor(int index) {

List<Color> colors = [
  const Color(0xFF2A9D8F),
  const Color(0xFFE76F51),
  const Color(0xFFF4A261),
  const Color(0xFF3A86FF),
  const Color(0xFF8338EC),
  const Color(0xFFFF006E),
];

return colors[index % colors.length];

}
Widget buildHeader() {
return Container(
width: double.infinity,
padding: const EdgeInsets.only(
left: 16,
right: 16,
top: 10,
bottom: 10,
),
decoration: const BoxDecoration(
color: const Color(0xFFF1F5F4),
),
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 16,
vertical: 10,
),
decoration: BoxDecoration(
color: const Color(0xFFF1F5F4),
borderRadius: BorderRadius.circular(18),
),
child: Row(
mainAxisAlignment:
MainAxisAlignment.spaceBetween,
children: [

      Row(
        children: [

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF13EC80),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.travel_explore,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            "V–Trenggalek",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  ),
),

);
}
@override
Widget build(BuildContext context) {

return Scaffold(
  backgroundColor: const Color.fromARGB(255, 235, 255, 243),

  body: SafeArea(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          buildHeader(),
 const SizedBox(height: 16),
          // BANNER
          Column(
            children: [

              SizedBox(
                height: 170,

                child: PageView.builder(

                  controller:
                      _pageController,

                  onPageChanged:
                      (index) {

                    setState(() {
                      currentBanner =
                          index;
                    });
                  },

                  itemCount:
                      banners.length,

                  itemBuilder:
                      (context, index) {

                    return Container(

                      margin:
                          EdgeInsets.only(
                        left:
                            index == 0
                                ? 16
                                : 8,
                        right:
                            index ==
                                    banners
                                            .length -
                                        1
                                ? 16
                                : 8,
                      ),

                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    16),

                        image:
                            DecorationImage(
                          image:
                              AssetImage(
                                  banners[
                                      index]),
                          fit: BoxFit
                              .cover,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                children:
                    List.generate(
                  banners.length,
                  (index) {

                    bool isActive =
                        index ==
                            currentBanner;

                    return AnimatedContainer(

                      duration:
                          const Duration(
                              milliseconds:
                                  300),

                      margin:
                          const EdgeInsets
                              .symmetric(
                                  horizontal:
                                      4),

                      width:
                          isActive
                              ? 16
                              : 6,

                      height: 6,

                      decoration:
                          BoxDecoration(

                        color: isActive
                            ? Colors
                                .teal
                            : Colors
                                .grey
                                .shade400,

                        borderRadius:
                            BorderRadius
                                .circular(
                                    10),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search destinations...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            searchController.clear();
                          });
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          const SizedBox(height: 20),

          // ================= CATEGORIES =================
          const Padding(
            padding:
                EdgeInsets.symmetric(
                    horizontal: 16),
            child: Text(
              "Categories",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
 const SizedBox(height: 20),

StreamBuilder<List<CategoryModel>>(
stream: categoryService.getAllCategories(),
builder: (context, snapshot) {

if (!snapshot.hasData) {
  return const SizedBox();
}

final categories = snapshot.data!;

return Container(
  margin: const EdgeInsets.symmetric(horizontal: 16),
  padding: const EdgeInsets.symmetric(vertical: 18),

  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),

    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 12,
        offset: const Offset(0,4),
      )
    ],
  ),

  child: Column(
    children: [

      SizedBox(
        height: 95,

        child: ListView.builder(

          scrollDirection: Axis.horizontal,

          padding: const EdgeInsets.symmetric(horizontal: 16),

          itemCount: categories.length,

          itemBuilder: (context,index){

            final item = categories[index];

            return GestureDetector(

              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExplorePage(
                      initialCategory: item.name,
                      showBackButton: true,
                    ),
                  ),
                );
              },

              child: Container(

                width: 80,
                margin: const EdgeInsets.only(right: 14),

                child: Column(
                  children: [

                    Container(
                      height: 60,
                      width: 60,

                      decoration: BoxDecoration(

                        borderRadius: BorderRadius.circular(16),

                        gradient: LinearGradient(
                          colors: [
                            categoryColor(index),
                            categoryColor(index).withOpacity(0.6)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: categoryColor(index).withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0,4),
                          )
                        ],
                      ),

                      child: Icon(
                        getCategoryIcon(item.icon),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      item.name,
                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),

      const SizedBox(height: 12),

      Container(
        height: 4,
        width: 36,

        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      )
    ],
  ),
);

},
),
 const SizedBox(height: 16),
          // ================= RECOMMENDED =================
          const Padding(
            padding:
                EdgeInsets.symmetric(
                    horizontal: 16),
            child: Text(
              "Recommended",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 260,

            child: StreamBuilder<
                List<DestinationModel>>(

              stream: destinationService
                  .getRecommendedDestinations(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {

                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final destinations =
                    snapshot.data!;

                return ListView.builder(

                  scrollDirection:
                      Axis.horizontal,

                  padding:
                      const EdgeInsets.symmetric(
                          horizontal: 16),

                  itemCount:
                      destinations.length,

                  itemBuilder:
                      (context, index) {

                    final item =
                        destinations[index];

                    return GestureDetector(

                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetailPage(
                              destination: item,
                            ),
                          ),
                        );
                      },

                      child: Container(

                        width: 220,

                        margin:
                            const EdgeInsets.only(
                                right: 16),

                        decoration:
                            BoxDecoration(

                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                                  16),

                          boxShadow: [

                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(
                                      0.05),

                              blurRadius: 10,

                              offset:
                                  const Offset(
                                      0, 4),
                            )
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            ClipRRect(

                              borderRadius:
                                  const BorderRadius
                                      .vertical(
                                top: Radius
                                    .circular(
                                        16),
                              ),

                              child: Image.network(

                                item.imageUrl,

                                height: 140,

                                width: double.infinity,

                                fit: BoxFit.cover,
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets
                                      .all(12),

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(
                                    item.name,

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 6),

                                  Text(
                                    item.location,

                                    style:
                                        const TextStyle(
                                      fontSize: 12,
                                      color: Colors
                                          .grey,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 6),

                                  Row(
                                    children: [

                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors
                                            .amber,
                                      ),

                                      const SizedBox(
                                          width: 4),

                                      Text(item.rating
                                          .toString()),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    ),
  ),
);

}
}