import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../providers/image_upload_provider.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? product;
  const ProductFormPage({super.key, this.product});

  @override
  ConsumerState<ProductFormPage> createState() =>
      _ProductFormPageState();
}

class _ProductFormPageState
    extends ConsumerState<ProductFormPage> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameCtrl.text = widget.product!.name;
      descCtrl.text = widget.product!.description;
      priceCtrl.text = widget.product!.price.toString();
      selectedCategoryId = widget.product!.categoryId;
      ref.read(imageUploadProvider.notifier).clear();
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imageUploadProvider);
    final categories = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),

            const SizedBox(height: 16),

            switch (categories) {
              AsyncData(:final value) => DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration:
                      const InputDecoration(labelText: 'Category'),
                  items: value
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => selectedCategoryId = v,
                ),
              _ => const SizedBox.shrink(),
            },

            const SizedBox(height: 20),

            switch (imageState) {
              AsyncData(:final value) => Column(
                  children: [
                    if (value != null)
                      Image.network(value, height: 120)
                    else if (widget.product != null)
                      Image.network(widget.product!.imageUrl, height: 120),
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
              _ => const SizedBox.shrink(),
            },

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                final imageUrl =
                    ref.read(imageUploadProvider).value ??
                        widget.product?.imageUrl;

                if (imageUrl == null ||
                    selectedCategoryId == null ||
                    nameCtrl.text.isEmpty) return;

                final controller =
                    ref.read(productControllerProvider.notifier);

                if (widget.product == null) {
                  await controller.addProduct(
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    price: double.parse(priceCtrl.text),
                    imageUrl: imageUrl,
                    categoryId: selectedCategoryId!,
                  );
                } else {
                  await controller.updateProduct(
                    id: widget.product!.id,
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    price: double.parse(priceCtrl.text),
                    imageUrl: imageUrl,
                    categoryId: selectedCategoryId!,
                  );
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save Product'),
            ),
          ],
        ),
      ),
    );
  }
}
