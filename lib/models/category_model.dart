class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
  });

  factory CategoryModel.fromFirestore(
      String id,
      Map<String, dynamic> data) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'imageUrl': imageUrl,
    };
  }
}