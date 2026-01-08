import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import 'cart_page.dart';

class CustomerHome extends ConsumerWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: switch (products) {
        AsyncLoading() =>
          const Center(child: CircularProgressIndicator()),

        AsyncError(:final error) =>
          Center(child: Text(error.toString())),

        AsyncData(:final value) =>
          ListView.builder(
            itemCount: value.length,
            itemBuilder: (_, i) {
              final product = value[i];
              return ListTile(
                leading: Image.network(product.imageUrl, width: 50),
                title: Text(product.name),
                subtitle: Text('৳ ${product.price}'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    ref.read(cartProvider.notifier).add(product);
                  },
                ),
              );
            },
          ),
      },
    );
  }
}
