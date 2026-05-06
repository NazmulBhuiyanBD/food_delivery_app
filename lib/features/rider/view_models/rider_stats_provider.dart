import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final riderStatsProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, riderId) {
  return ref.read(firestoreProvider)
      .collection('orders')
      .where('riderId', isEqualTo: riderId)
      .where('status', isEqualTo: 'delivered')
      .snapshots()
      .map((s) {
        double totalEarnings = 0;
        int totalDeliveries = s.docs.length;
        
        for (var doc in s.docs) {
          totalEarnings += (doc.data()['totalAmount'] as num? ?? 0).toDouble();
        }
        
        return {
          'totalEarnings': totalEarnings,
          'totalDeliveries': totalDeliveries,
          'rating': 4.9, // Default for now
        };
      });
});
