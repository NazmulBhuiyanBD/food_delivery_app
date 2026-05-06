class Restaurant {
  final String id;
  final String restaurantName;
  final String description;
  final String address;
  final String phone;
  final String? bannerImageUrl;

  Restaurant({
    required this.id,
    required this.restaurantName,
    required this.description,
    required this.address,
    required this.phone,
    this.bannerImageUrl,
  });

  factory Restaurant.fromMap(String id, Map<String, dynamic> data) {
    return Restaurant(
      id: id,
      restaurantName: data['restaurantName'] ?? 'Unknown Restaurant',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      bannerImageUrl: data['bannerImageUrl'],
    );
  }
}
