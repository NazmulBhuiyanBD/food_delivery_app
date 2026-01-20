import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/firebase_providers.dart';

// 1. Total Revenue Provider (Real-time)
final totalRevenueProvider = StreamProvider<double>((ref) {
  final db = ref.read(firestoreProvider);
  return db
      .collection('orders')
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

// 2. Voucher List Provider
final voucherListProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final db = ref.read(firestoreProvider);
  return db.collection('vouchers').snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  });
});