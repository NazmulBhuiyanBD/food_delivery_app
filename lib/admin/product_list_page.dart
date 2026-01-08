import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/product_provider.dart';
import 'product_form_page.dart';

class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProductFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
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
                leading: Image.network(
                  product.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(product.name),
                subtitle: Text('৳ ${product.price}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    ref
                        .read(productControllerProvider.notifier)
                        .deleteProduct(product.id);
                  },
                ),
              );
            },
          ),
      },
    );
  }
}
