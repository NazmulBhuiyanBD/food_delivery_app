import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/models/restaurant_model.dart';
import 'package:food_delivery_app/models/product_model.dart';

final restaurantProvider = StreamProvider.family<Restaurant?, String>((ref, restaurantId) {
  return ref.read(firestoreProvider)
      .collection('owners')
      .doc(restaurantId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        return Restaurant.fromMap(doc.id, doc.data()!);
      });
});

final restaurantProductsProvider = StreamProvider.family<List<Product>, String>((ref, restaurantId) {
  return ref.read(firestoreProvider)
      .collection('products')
      .where('restaurantId', isEqualTo: restaurantId)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Product.fromMap(doc.id, doc.data())).toList();
      });
});
