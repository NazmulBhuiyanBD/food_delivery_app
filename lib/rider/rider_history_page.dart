import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firebase_providers.dart';
import '../providers/current_user_provider.dart';

final historyOrdersProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, riderId) {
  return ref.read(firestoreProvider)
      .collection('orders')
      .where('riderId', isEqualTo: riderId)
      .where('status', isEqualTo: 'delivered')
      .snapshots()
      .map((s) {
        final docs = s.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        
        docs.sort((a, b) {
          final t1 = a['createdAt'] as Timestamp?;
          final t2 = b['createdAt'] as Timestamp?;
          if (t1 == null || t2 == null) return 0;
          return t2.compareTo(t1);
        });
        
        return docs;
      });
});

class RiderHistoryPage extends ConsumerWidget {
  const RiderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riderId = ref.watch(currentUserIdProvider);
    final history = ref.watch(historyOrdersProvider(riderId));

    return Scaffold(
      appBar: AppBar(title: const Text("Delivery History")),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        // Improved Error Display
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("Error loading history: $e", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) return const Center(child: Text("No completed orders yet"));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                title: Text("Order #${order['id'].toString().substring(0, 5)}"),
                subtitle: Text(order['address'] ?? "No Address"),
                trailing: Text(
                  "৳ ${order['totalAmount']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}