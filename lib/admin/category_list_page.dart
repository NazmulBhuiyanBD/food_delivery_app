import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_provider.dart';
import 'category_form_page.dart';

class CategoryListPage extends ConsumerWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CategoryFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: switch (categories) {
        AsyncLoading() =>
          const Center(child: CircularProgressIndicator()),

        AsyncError(:final error) =>
          Center(child: Text(error.toString())),

        AsyncData(:final value) =>
          ListView.builder(
            itemCount: value.length,
            itemBuilder: (_, i) {
              final category = value[i];
              return ListTile(
                title: Text(category.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    ref
                        .read(categoryControllerProvider.notifier)
                        .deleteCategory(category.id);
                  },
                ),
              );
            },
          ),
      },
    );
  }
}
