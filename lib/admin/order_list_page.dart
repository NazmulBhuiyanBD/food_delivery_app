import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/order_provider.dart';
import '../providers/user_provider.dart';
import '../core/firebase_providers.dart';

class OrderListPage extends ConsumerWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderListProvider);
    final ridersAsync = ref.watch(riderListProvider);
    final db = ref.read(firestoreProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: switch (orders) {
        // 🔹 Loading orders
        AsyncLoading() =>
          const Center(child: CircularProgressIndicator()),

        // 🔹 Error
        AsyncError(:final error) =>
          Center(child: Text(error.toString())),

        // 🔹 Orders loaded
        AsyncData(:final value) =>
          ListView.builder(
            itemCount: value.length,
            itemBuilder: (_, i) {
              final order = value[i];
              final status = order['status'];
              final assignedRiderId = order['riderId'];

              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['id']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 6),
                      Text('Status: $status'),

                      const SizedBox(height: 12),

                      // 🔹 Assign Rider (Admin only)
                      ridersAsync.when(
                        data: (riderList) {
                          return DropdownButtonFormField<String>(
                            value: riderList.any(
                                    (r) => r['id'] == assignedRiderId)
                                ? assignedRiderId
                                : null,
                            hint: const Text('Assign Rider'),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: riderList.map((rider) {
                              return DropdownMenuItem<String>(
                                value: rider['id'],
                                child: Text(
                                  rider['phone'] ??
                                      rider['name'] ??
                                      'Rider',
                                ),
                              );
                            }).toList(),
                            onChanged: status == 'pending'
                                ? (riderId) async {
                                    if (riderId == null) return;

                                    await db
                                        .collection('orders')
                                        .doc(order['id'])
                                        .update({
                                      'riderId': riderId,
                                      'status': 'assigned',
                                    });
                                  }
                                : null,
                          );
                        },
                        loading: () =>
                          const CircularProgressIndicator(),
                        error: (_, __) =>
                          const Text('Failed to load riders'),
                      ),

                      const SizedBox(height: 12),

                      // 🔹 Status text
                      Text(
                        status == 'assigned'
                            ? 'Waiting for rider'
                            : status == 'on_the_way'
                                ? 'Rider on the way'
                                : status == 'delivered'
                                    ? 'Delivered'
                                    : 'Pending',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      },
    );
  }
}
