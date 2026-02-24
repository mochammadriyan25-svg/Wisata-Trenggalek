import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {

  String selectedCategory = "All";
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    "All",
    "Nature",
    "History",
    "Culinary",
  ];

  final List<Map<String, dynamic>> destinations = [
    {
      "title": "Prigi Beach",
      "subtitle": "Watulimo, South Trenggalek",
      "icon": Icons.water_drop,
      "color": Colors.blue
    },
    {
      "title": "Hutan Kota (City Forest)",
      "subtitle": "Trenggalek City Center",
      "icon": Icons.park,
      "color": Colors.green
    },
    {
      "title": "Panggul Great Mosque",
      "subtitle": "Panggul District",
      "icon": Icons.account_balance,
      "color": Colors.orange
    },
    {
      "title": "Ayam Lodho Pak Yusuf",
      "subtitle": "Culinary Heritage",
      "icon": Icons.restaurant,
      "color": Colors.purple
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
          "Search",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [

            const SizedBox(height: 10),

            // SEARCH BAR
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search),
                        hintText: "Type keywords...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    searchController.clear();
                    setState(() {});
                  },
                  child: const Text(
                    "Clear Search",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            // CATEGORY FILTER
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.black
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
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

            const SizedBox(height: 25),

            // TITLE
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "SUGGESTED DESTINATIONS",
                style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.5,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            // LIST DESTINATIONS
            Expanded(
              child: ListView.separated(
                itemCount: destinations.length,
                separatorBuilder: (_, __) =>
                    const Divider(),
                itemBuilder: (context, index) {
                  final item = destinations[index];

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: item["color"].withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: Icon(
                        item["icon"],
                        color: item["color"],
                      ),
                    ),
                    title: Text(
                      item["title"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(item["subtitle"]),
                    trailing:
                        const Icon(Icons.chevron_right),
                    onTap: () {},
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