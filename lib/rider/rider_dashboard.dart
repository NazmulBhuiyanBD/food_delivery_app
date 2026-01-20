import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/firebase_providers.dart';
import '../providers/current_user_provider.dart';

// Provider to fetch active orders
final activeOrdersProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, riderId) {
  return ref.read(firestoreProvider)
      .collection('orders')
      .where('riderId', isEqualTo: riderId)
      .where('status', whereIn: ['assigned', 'on_the_way'])
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

class RiderDashboard extends ConsumerWidget {
  const RiderDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riderId = ref.watch(currentUserIdProvider);
    final activeOrders = ref.watch(activeOrdersProvider(riderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rider Dashboard"),
        backgroundColor: const Color(0xFFFF8A00),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Hides back button
      ),
      body: activeOrders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.moped, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 20),
                  const Text("No active orders", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(context, ref, order);
            },
          );
        },
      ),
    );
  }

  // Helper Widget for Order Card
  Widget _buildOrderCard(BuildContext context, WidgetRef ref, Map<String, dynamic> order) {
    final status = order['status'];
    final isAssigned = status == 'assigned';
    final address = order['address'] ?? 'No Address';
    final phone = order['phone'] ?? 'No Phone';
    final items = (order['items'] as List<dynamic>?) ?? [];
    final total = order['totalAmount'];

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAssigned ? Colors.blue.shade50 : Colors.orange.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #${order['id'].toString().substring(0, 5)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAssigned ? Colors.blue : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAssigned ? "PICKUP PENDING" : "ON THE WAY",
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFFFF8A00), size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(address, style: const TextStyle(fontSize: 16))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.grey, size: 20),
                    const SizedBox(width: 10),
                    Text(phone, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
                const Divider(height: 20),
                Text("${items.length} Items • Total: ৳ $total", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(
                  items.map((i) => "${i['quantity']}x ${i['name']}").join(", "),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAssigned ? const Color(0xFFFF8A00) : Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final newStatus = isAssigned ? 'on_the_way' : 'delivered';
                      await ref.read(firestoreProvider).collection('orders').doc(order['id']).update({'status': newStatus});
                    },
                    child: Text(
                      isAssigned ? "START DELIVERY" : "MARK AS DELIVERED",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}