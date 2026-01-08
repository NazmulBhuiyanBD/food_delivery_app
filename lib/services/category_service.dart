import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _db;
  CategoryService(this._db);

  CollectionReference get _ref => _db.collection('categories');

  Future<void> addCategory(String name, String imageUrl) async {
    await _ref.add({
      'name': name,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCategory(
      String id, String name, String imageUrl) async {
    await _ref.doc(id).update({
      'name': name,
      'imageUrl': imageUrl,
    });
  }

  Future<void> deleteCategory(String id) async {
    await _ref.doc(id).delete();
  }

  Stream<List<Category>> getCategories() {
    return _ref.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Category.fromMap(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
