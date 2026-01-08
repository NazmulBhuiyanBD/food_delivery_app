import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _db;
  ProductService(this._db);

  CollectionReference get _ref => _db.collection('products');

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String categoryId,
  }) async {
    await _ref.add({
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String categoryId,
  }) async {
    await _ref.doc(id).update({
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
    });
  }

  Future<void> deleteProduct(String id) async {
    await _ref.doc(id).delete();
  }

  Stream<List<Product>> getProducts() {
    return _ref.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) =>
              Product.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList(),
    );
  }
}
