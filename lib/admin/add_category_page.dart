import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/image_upload_provider.dart';

class AddCategoryPage extends ConsumerWidget {
  const AddCategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = ref.watch(imageUploadProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Category")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image preview
            switch (imageState) {
              AsyncLoading() =>
                const CircularProgressIndicator(),

              AsyncError(:final error) =>
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),

              AsyncData(:final value) =>
                value == null
                    ? const Icon(Icons.image, size: 100)
                    : Image.network(value, height: 100),
            },

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                ref
                    .read(imageUploadProvider.notifier)
                    .pickAndUpload();
              },
              child: const Text("Upload Image"),
            ),
          ],
        ),
      ),
    );
  }
}
