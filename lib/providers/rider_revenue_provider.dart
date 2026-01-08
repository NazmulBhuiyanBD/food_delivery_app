import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/firebase_providers.dart';

final riderRevenueProvider =
    StreamProvider.family<double, String>((ref, riderId) {
  return ref
      .read(firestoreProvider)
      .collection('orders')
      .where('riderId', isEqualTo: riderId)
      .where('status', isEqualTo: 'delivered')
      .snapshots()
      .map((snapshot) {
        double total = 0;
        for (var doc in snapshot.docs) {
          total += (doc['totalAmount'] as num).toDouble();
        }
        return total;
      });
});
