class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final String restaurantId;
  final bool isActive;
  final bool isChefSelection;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.restaurantId,
    this.isActive = true,
    this.isChefSelection = false,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'],
      description: data['description'],
      price: (data['price'] as num).toDouble(),
      imageUrl: data['imageUrl'],
      categoryId: data['categoryId'],
      restaurantId: data['restaurantId'] ?? '',
      isActive: data['isActive'] ?? true,
      isChefSelection: data['isChefSelection'] ?? false,
    );
  }
}
