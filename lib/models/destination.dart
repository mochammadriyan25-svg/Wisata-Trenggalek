class Destination {
  final String id;
  final String name;
  final String location;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final double rating;
  final String price;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.price,
  });

  factory Destination.fromFirestore(String id, Map<String, dynamic> data) {
    return Destination(
      id: id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      rating: (data['rating'] as num).toDouble(),
      price: data['price'] ?? '',
    );
  }
}