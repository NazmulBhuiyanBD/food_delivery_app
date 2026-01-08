import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/product_model.dart';

final cartProvider =
    StateNotifierProvider<CartNotifier, List<Product>>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<List<Product>> {
  CartNotifier() : super([]);

  void add(Product product) {
    state = [...state, product];
  }

  void remove(Product product) {
    state = state.where((p) => p.id != product.id).toList();
  }

  double get total =>
      state.fold(0, (sum, item) => sum + item.price);
}
