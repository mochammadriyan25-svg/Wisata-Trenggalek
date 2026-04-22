import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../models/category_model.dart';
import '../services/firestore/destination_service.dart';
import '../services/firestore/category_service.dart';
import '../pages/destinasi_page.dart';

class ExplorePage extends StatefulWidget {

final String initialCategory;
final bool showBackButton;

const ExplorePage({
super.key,
this.initialCategory = "All",
this.showBackButton = false,
});

@override
State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {

final DestinationService _destinationService = DestinationService();
final CategoryService _categoryService = CategoryService();

final TextEditingController _searchController = TextEditingController();

late String selectedCategory;

@override
void initState() {
super.initState();
selectedCategory = widget.initialCategory;

_searchController.addListener(() {
  setState(() {});
});

}

@override
Widget build(BuildContext context) {

return Scaffold(
  backgroundColor: const Color.fromARGB(255, 240, 240, 240),

  body: SafeArea(
    child: Column(
      children: [

        // ================= HEADER =================
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  if (widget.showBackButton)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            size: 18,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Back",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(width: 60),

                  const Expanded(
                    child: Center(
                      child: Text(
                        "Explore",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 60)

                ],
              ),

              const SizedBox(height: 16),

              // ================= SEARCH =================
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {

                  if (value.trim().isEmpty) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchResultPage(
                        initialQuery: value,
                        initialCategory: selectedCategory,
                      ),
                    ),
                  );
                },
                decoration: InputDecoration(
                  hintText: "Search destinations...",
                  prefixIcon: const Icon(Icons.search),

                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,

                  filled: true,
                  fillColor: Colors.grey.shade100,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ================= CATEGORY =================
              SizedBox(
                height: 40,
                child: StreamBuilder<List<CategoryModel>>(
                  stream: _categoryService.getAllCategories(),
                  builder: (context, snapshot) {

                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }

                    final categories = snapshot.data!;

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [

                        _buildChip("All"),

                        ...categories.map((cat) {
                          return _buildChip(cat.name);
                        }).toList(),

                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ================= DESTINATION LIST =================
        Expanded(
          child: StreamBuilder<List<DestinationModel>>(
            stream: _destinationService.getAllDestinations(),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: Text("No data"),
                );
              }

              final data = snapshot.data!;

              List<DestinationModel> filtered;

              if (selectedCategory == "All") {
                filtered = data;
              } else {

                filtered = data.where((item) {

                  final itemCategory =
                      item.category.toLowerCase().trim();

                  final selected =
                      selectedCategory.toLowerCase().trim();

                  return itemCategory.contains(selected);

                }).toList();

              }

              if (filtered.isEmpty) {
                return const Center(
                  child: Text("No destinations found"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {

                  final item = filtered[index];

                  return GestureDetector(
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchResultPage(
                            initialQuery: item.name,
                            initialCategory: selectedCategory,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [

                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item.imageUrl,
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  item.location,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(Icons.chevron_right),

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
  ),
);

}

// ================= CATEGORY CHIP =================
Widget _buildChip(String name) {

final isSelected = selectedCategory == name;

return GestureDetector(
  onTap: () {

    setState(() {
      selectedCategory = name;
    });
  },
  child: Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: isSelected ? Colors.green : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Text(
      name,
      style: TextStyle(
        fontSize: 12,
        color: isSelected
            ? Colors.white
            : Colors.grey.shade700,
      ),
    ),
  ),
);

}
}
