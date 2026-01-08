import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/firebase_providers.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

/// Service provider
final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.read(firestoreProvider));
});

/// READ: realtime categories
final categoryListProvider = StreamProvider<List<Category>>((ref) {
  return ref.read(categoryServiceProvider).getCategories();
});

/// WRITE: add / update / delete
final categoryControllerProvider =
    NotifierProvider<CategoryController, void>(
  CategoryController.new,
);

class CategoryController extends Notifier<void> {
  late final CategoryService _service;

  @override
  void build() {
    _service = ref.read(categoryServiceProvider);
  }

  Future<void> addCategory(String name, String imageUrl) async {
    await _service.addCategory(name, imageUrl);
  }

  Future<void> updateCategory(
      String id, String name, String imageUrl) async {
    await _service.updateCategory(id, name, imageUrl);
  }

  Future<void> deleteCategory(String id) async {
    await _service.deleteCategory(id);
  }
}
