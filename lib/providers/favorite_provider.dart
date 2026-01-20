import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Stores a list of Product IDs that are marked as favorite
final favoriteProvider = StateNotifierProvider<FavoriteNotifier, List<String>>((ref) {
  return FavoriteNotifier();
});

class FavoriteNotifier extends StateNotifier<List<String>> {
  FavoriteNotifier() : super([]);

  void toggleFavorite(String productId) {
    if (state.contains(productId)) {
      state = state.where((id) => id != productId).toList();
    } else {
      state = [...state, productId];
    }
  }

  bool isFavorite(String productId) {
    return state.contains(productId);
  }
}