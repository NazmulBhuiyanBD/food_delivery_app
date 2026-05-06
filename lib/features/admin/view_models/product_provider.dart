import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/models/product_model.dart';
import 'package:food_delivery_app/services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ref.read(firestoreProvider));
});

/// READ (realtime)
final productListProvider = StreamProvider<List<Product>>((ref) {
  return ref.read(productServiceProvider).getProducts();
});

/// WRITE (CRUD)
final productControllerProvider =
    NotifierProvider<ProductController, void>(
  ProductController.new,
);

class ProductController extends Notifier<void> {
  late final ProductService _service;

  @override
  void build() {
    _service = ref.read(productServiceProvider);
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String categoryId,
    required String restaurantId,
    bool isActive = true,
    bool isChefSelection = false,
  }) async {
    await _service.addProduct(
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      categoryId: categoryId,
      restaurantId: restaurantId,
      isActive: isActive,
      isChefSelection: isChefSelection,
    );
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String categoryId,
    required String restaurantId,
    required bool isActive,
    required bool isChefSelection,
  }) async {
    await _service.updateProduct(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      categoryId: categoryId,
      restaurantId: restaurantId,
      isActive: isActive,
      isChefSelection: isChefSelection,
    );
  }

  Future<void> deleteProduct(String id) async {
    await _service.deleteProduct(id);
  }
}
