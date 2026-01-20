import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/product_model.dart';
import '../models/cart_item.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);
  void add(Product product) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final oldItem = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        oldItem.copyWith(quantity: oldItem.quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }
  void decrease(Product product) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    if (existingIndex < 0) return;

    final oldItem = state[existingIndex];
    if (oldItem.quantity > 1) {
      state = [
        ...state.sublist(0, existingIndex),
        oldItem.copyWith(quantity: oldItem.quantity - 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = state.where((item) => item.product.id != product.id).toList();
    }
  }
  void remove(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void clear() {
    state = [];
  }

  double get subtotal => state.fold(0, (sum, item) => sum + item.total);
}