import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';

/// Stream of all orders sorted by date
final allOrdersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(firestoreProvider)
      .collection('orders')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

/// Stream of pending orders (pending, preparing, on_the_way)
final pendingOrdersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(firestoreProvider)
      .collection('orders')
      .where('status', whereIn: ['pending', 'preparing', 'on_the_way'])
      .snapshots()
      .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

/// Stream of previous orders (delivered, cancelled)
final previousOrdersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(firestoreProvider)
      .collection('orders')
      .where('status', whereIn: ['delivered', 'cancelled'])
      .snapshots()
      .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

/// Controller for order actions
final orderManagementControllerProvider = NotifierProvider<OrderManagementController, void>(OrderManagementController.new);

class OrderManagementController extends Notifier<void> {
  @override
  void build() {}

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final updates = <String, dynamic>{'status': newStatus};
    if (newStatus == 'delivered') {
      updates['deliveredAt'] = DateTime.now().toIso8601String();
    } else if (newStatus == 'picked_up') {
      updates['pickedUpAt'] = DateTime.now().toIso8601String();
    }
    await ref.read(firestoreProvider)
        .collection('orders')
        .doc(orderId)
        .update(updates);
  }
}
