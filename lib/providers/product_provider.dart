import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/firebase_providers.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

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
  }) async {
    await _service.addProduct(
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      categoryId: categoryId,
    );
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String categoryId,
  }) async {
    await _service.updateProduct(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      categoryId: categoryId,
    );
  }

  Future<void> deleteProduct(String id) async {
    await _service.deleteProduct(id);
  }
}
