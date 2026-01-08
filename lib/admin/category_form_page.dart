import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../providers/image_upload_provider.dart';

class CategoryFormPage extends ConsumerStatefulWidget {
  final Category? category;
  const CategoryFormPage({super.key, this.category});

  @override
  ConsumerState<CategoryFormPage> createState() =>
      _CategoryFormPageState();
}

class _CategoryFormPageState
    extends ConsumerState<CategoryFormPage> {
  final nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      nameCtrl.text = widget.category!.name;
      ref.read(imageUploadProvider.notifier).clear();
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imageUploadProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null ? 'Add Category' : 'Edit Category',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Category Name',
              ),
            ),

            const SizedBox(height: 20),

            switch (imageState) {
              AsyncLoading() =>
                const CircularProgressIndicator(),

              AsyncError(:final error) =>
                Text(error.toString(),
                    style: const TextStyle(color: Colors.red)),

              AsyncData(:final value) => Column(
                  children: [
                    if (value != null)
                      Image.network(value, height: 120)
                    else if (widget.category != null)
                      Image.network(
                        widget.category!.imageUrl,
                        height: 120,
                      ),

                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(imageUploadProvider.notifier)
                            .pickAndUpload();
                      },
                      child: const Text('Upload Image'),
                    ),
                  ],
                ),
            },

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final imageUrl =
                      ref.read(imageUploadProvider).value ??
                      widget.category?.imageUrl;

                  if (nameCtrl.text.trim().isEmpty || imageUrl == null) {
                    return;
                  }

                  final controller =
                      ref.read(categoryControllerProvider.notifier);

                  if (widget.category == null) {
                    await controller.addCategory(
                      nameCtrl.text.trim(),
                      imageUrl,
                    );
                  } else {
                    await controller.updateCategory(
                      widget.category!.id,
                      nameCtrl.text.trim(),
                      imageUrl,
                    );
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
