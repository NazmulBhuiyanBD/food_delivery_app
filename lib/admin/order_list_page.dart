import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';// Add intl to pubspec.yaml for date formatting if needed, or use simple string

import '../core/firebase_providers.dart';
import '../providers/order_provider.dart'; 
import '../services/widget_support.dart';

final adminOrderStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, statusFilter) {
  final db = ref.read(firestoreProvider);
  var query = db.collection('orders').orderBy('createdAt', descending: true);
  return query.snapshots().map((s) {
    final docs = s.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    if (statusFilter == 'pending') {
      return docs.where((o) => o['status'] == 'pending').toList();
    } else if (statusFilter == 'active') {
      return docs.where((o) => ['assigned', 'on_the_way'].contains(o['status'])).toList();
    } else {
      return docs.where((o) => ['delivered', 'cancelled'].contains(o['status'])).toList();
    }
  });
});

final availableRidersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(firestoreProvider).collection('riders').snapshots().map(
      (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Manage Orders"),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Active"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OrderListTab(filter: 'pending'),
            _OrderListTab(filter: 'active'),
            _OrderListTab(filter: 'history'),
          ],
        ),
      ),
    );
  }
}

class _OrderListTab extends ConsumerWidget {
  final String filter;
  const _OrderListTab({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrderStreamProvider(filter));

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
      data: (orders) {
        if (orders.isEmpty) {
          return Center(
              child: Text("No $filter orders",
                  style: const TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (ctx, i) => _AdminOrderCard(order: orders[i]),
        );
      },
    );
  }
}

class _AdminOrderCard extends ConsumerWidget {
  final Map<String, dynamic> order;
  const _AdminOrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = (order['items'] as List<dynamic>?) ?? [];
    final status = order['status'] ?? 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #${order['id'].toString().substring(0, 5)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status.toUpperCase(),
                      style: TextStyle(
                          color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text("📍 ${order['address']}"),
            const SizedBox(height: 5),
            Text("Items: ${items.map((i) => i['name']).join(', ')}",
                style: const TextStyle(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total: ৳ ${order['totalAmount']}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (status == 'pending')
                  ElevatedButton(
                    onPressed: () => _showAssignRiderDialog(context, ref, order['id']),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8A00),
                        foregroundColor: Colors.white),
                    child: const Text("Assign Rider"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.red;
      case 'assigned': return Colors.blue;
      case 'on_the_way': return Colors.orange;
      case 'delivered': return Colors.green;
      default: return Colors.grey;
    }
  }

void _showAssignRiderDialog(BuildContext context, WidgetRef ref, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Select Rider"),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer(
            builder: (context, ref, _) {
              final ridersAsync = ref.watch(availableRidersProvider);
              return ridersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(e.toString()),
                data: (riders) {
                  if (riders.isEmpty) return const Text("No riders found.");
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: riders.length,
                    itemBuilder: (context, index) {
                      final rider = riders[index];
                      
                      // ✅ Get Name, Phone, and Email
                      final name = rider['name'] ?? 'Unknown Rider';
                      final phone = rider['phone'] ?? 'No Phone';
                      final email = rider['email'] ?? '';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: rider['imageUrl'] != null 
                              ? NetworkImage(rider['imageUrl']) 
                              : null,
                          child: rider['imageUrl'] == null 
                              ? const Icon(Icons.two_wheeler, color: Colors.black54) 
                              : null,
                        ),
                        // ✅ Show Name here
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        // ✅ Show Phone/Email as subtitle
                        subtitle: Text(phone.isNotEmpty ? phone : email),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          await ref.read(firestoreProvider)
                              .collection('orders')
                              .doc(orderId)
                              .update({
                            'riderId': rider['id'],
                            'status': 'assigned',
                          });
                          if (context.mounted) Navigator.pop(ctx);
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}