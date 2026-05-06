import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';

final ownerProfileProvider = StreamProvider.autoDispose((ref) {
  final user = ref.watch(authProvider).currentUser;
  if (user == null) return const Stream.empty();
  
  return ref.read(firestoreProvider)
      .collection('owners')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.data() ?? {});
});

final ownerOrdersProvider = StreamProvider.autoDispose((ref) {
  final user = ref.watch(authProvider).currentUser;
  if (user == null) return const Stream.empty();
  
  return ref.read(firestoreProvider)
      .collection('orders')
      .where('restaurantId', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) {
        final docs = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        
        // Sort in memory to avoid needing a composite index in Firestore
        docs.sort((a, b) {
          final aTime = a['createdAt'] as Timestamp?;
          final bTime = b['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });
        
        return docs;
      });
});

final ownerStatsProvider = Provider.autoDispose((ref) {
  final ordersAsync = ref.watch(ownerOrdersProvider);
  
  return ordersAsync.when(
    data: (orders) {
      double totalRevenue = 0;
      int activeOrders = 0;
      int pendingPreparation = 0;
      
      for (var order in orders) {
        final status = (order['status'] as String).toUpperCase();
        final amount = (order['totalAmount'] ?? order['amount'] ?? 0).toDouble();
        
        if (status == 'COMPLETED' || status == 'DELIVERED') {
          totalRevenue += amount;
        }
        
        if (status == 'PENDING' || status == 'PREPARING') {
          activeOrders++;
          if (status == 'PENDING') {
            pendingPreparation++;
          }
        }
      }
      
      return {
        'totalRevenue': totalRevenue,
        'activeOrders': activeOrders,
        'pendingPreparation': pendingPreparation,
      };
    },
    loading: () => {
      'totalRevenue': 0.0,
      'activeOrders': 0,
      'pendingPreparation': 0,
    },
    error: (_, __) => {
      'totalRevenue': 0.0,
      'activeOrders': 0,
      'pendingPreparation': 0,
    },
  );
});
final ownerProfileControllerProvider = NotifierProvider<OwnerProfileController, void>(OwnerProfileController.new);

class OwnerProfileController extends Notifier<void> {
  @override
  void build() {}

  Future<void> updateProfile({
    required String restaurantName,
    required String description,
    required String address,
    required String phone,
    String? bannerImageUrl,
  }) async {
    final user = ref.read(authProvider).currentUser;
    if (user == null) return;

    await ref.read(firestoreProvider).collection('owners').doc(user.uid).update({
      'restaurantName': restaurantName,
      'description': description,
      'address': address,
      'phone': phone,
      if (bannerImageUrl != null) 'bannerImageUrl': bannerImageUrl,
    });
  }
}
