class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'],
      description: data['description'],
      price: (data['price'] as num).toDouble(),
      imageUrl: data['imageUrl'],
      categoryId: data['categoryId'],
    );
  }
}
