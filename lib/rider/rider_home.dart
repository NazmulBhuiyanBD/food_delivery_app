import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/firebase_providers.dart';
import '../providers/current_user_provider.dart';
import '../providers/rider_order_provider.dart';
import '../providers/rider_revenue_provider.dart';
import '../providers/rider_review_provider.dart';

class RiderHome extends ConsumerWidget {
  const RiderHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ FIX: get logged-in rider id
    final riderId = ref.watch(currentUserIdProvider);

    final orders = ref.watch(riderOrdersProvider(riderId));
    final revenue = ref.watch(riderRevenueProvider(riderId));
    final reviews = ref.watch(riderReviewProvider(riderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Rider Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔹 Revenue
          revenue.when(
            data: (value) => Text(
              'Total Revenue: ৳ $value',
              style: const TextStyle(fontSize: 18),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Error loading revenue'),
          ),

          const SizedBox(height: 20),

          // 🔹 Assigned Orders
          const Text(
            'Assigned Orders',
            style: TextStyle(fontSize: 18),
          ),
          orders.when(
            data: (list) => Column(
              children: list.map((order) {
                return Card(
                  child: ListTile(
                    title: Text('Order ${order['id']}'),
                    subtitle: Text('Status: ${order['status']}'),
                    trailing: DropdownButton<String>(
                      value: order['status'],
                      items: const [
                        DropdownMenuItem(
                          value: 'assigned',
                          child: Text('Assigned'),
                        ),
                        DropdownMenuItem(
                          value: 'on_the_way',
                          child: Text('On the way'),
                        ),
                        DropdownMenuItem(
                          value: 'delivered',
                          child: Text('Delivered'),
                        ),
                      ],
                      onChanged: (status) {
                        if (status == null) return;

                        ref
                            .read(firestoreProvider)
                            .collection('orders')
                            .doc(order['id'])
                            .update({
                          'status': status,
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Error loading orders'),
          ),

          const SizedBox(height: 20),

          // 🔹 Reviews
          const Text(
            'Reviews',
            style: TextStyle(fontSize: 18),
          ),
          reviews.when(
            data: (list) => Column(
              children: list.map((r) {
                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.orange),
                  title: Text('Rating: ${r['rating']}'),
                  subtitle: Text(r['comment']),
                );
              }).toList(),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Error loading reviews'),
          ),
        ],
      ),
    );
  }
}
