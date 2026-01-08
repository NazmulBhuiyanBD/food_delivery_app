import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/user_provider.dart';

class UserListPage extends ConsumerWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerListProvider);
    final riders = ref.watch(riderListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Customers Section
          const Text(
            'Customers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          customers.when(
            data: (list) => list.isEmpty
                ? const Text('No customers found')
                : Column(
                    children: list.map((user) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(user['name'] ?? 'Customer'),
                          subtitle: Text(user['phone'] ?? user['email'] ?? ''),
                        ),
                      );
                    }).toList(),
                  ),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(e.toString()),
          ),

          const SizedBox(height: 30),

          // Riders Section
          const Text(
            'Riders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          riders.when(
            data: (list) => list.isEmpty
                ? const Text('No riders found')
                : Column(
                    children: list.map((rider) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.delivery_dining),
                          title: Text(rider['name'] ?? 'Rider'),
                          subtitle: Text(
                            rider['phone'] ?? rider['email'] ?? '',
                          ),
                          trailing: const Chip(
                            label: Text('Rider'),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(e.toString()),
          ),
        ],
      ),
    );
  }
}
