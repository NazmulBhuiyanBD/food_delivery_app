import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/features/admin/view_models/product_provider.dart';
import 'package:food_delivery_app/features/customer/view_models/favorite_provider.dart';
import 'package:food_delivery_app/features/customer/view_models/cart_provider.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    final favorites = ref.watch(favoriteProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("My Favorites")),
      body: productsAsync.when(
        data: (allProducts) {
          final favProducts = allProducts.where((p) => favorites.contains(p.id)).toList();

          if (favProducts.isEmpty) {
            return const Center(child: Text("No favorites yet!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            itemCount: favProducts.length,
            itemBuilder: (ctx, i) {
              final product = favProducts[i];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Image.network(product.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                  title: Text(product.name),
                  subtitle: Text("৳ ${product.price}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.shopping_cart_checkout, color: Color(0xFFFF8A00)),
                    onPressed: () {
                      ref.read(cartProvider.notifier).add(product);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to cart")));
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}