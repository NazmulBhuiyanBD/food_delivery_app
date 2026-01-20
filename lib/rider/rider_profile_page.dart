import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/firebase_providers.dart';
import '../providers/current_user_provider.dart';
import '../auth/auth_controller.dart';
import 'edit_rider_profile.dart';

class RiderProfilePage extends ConsumerWidget {
  const RiderProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riderId = ref.watch(currentUserIdProvider);
    final db = ref.watch(firestoreProvider);
    
    // ✅ FIX: Get the logged-in user to access email directly
    final authUser = ref.watch(authProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Rider Info
            StreamBuilder(
              stream: db.collection('riders').doc(riderId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // If no profile exists yet
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Column(
                    children: [
                      const CircleAvatar(radius: 50, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 50, color: Colors.white)),
                      const SizedBox(height: 10),
                      const Text("Profile incomplete"),
                      TextButton(
                        onPressed: () => _navigateToEdit(context, {}),
                        child: const Text("Create Profile"),
                      ),
                    ],
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final name = data['name'] ?? 'Rider Name';
                final phone = data['phone'] ?? 'No Phone';
                final imageUrl = data['imageUrl'];
                
                final email = data['email'] ?? authUser?.email ?? 'No Email';

                return Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFF8A00), width: 3),
                            image: imageUrl != null && imageUrl.isNotEmpty
                                ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                                : null,
                          ),
                          child: imageUrl == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _navigateToEdit(context, data),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF8A00),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 20),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(phone, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    Text(email, style: const TextStyle(color: Colors.grey)),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            // 2. Earnings Stats
            StreamBuilder(
              stream: db.collection('orders')
                  .where('riderId', isEqualTo: riderId)
                  .where('status', isEqualTo: 'delivered')
                  .snapshots(),
              builder: (context, snapshot) {
                double total = 0;
                int count = 0;
                if (snapshot.hasData) {
                  count = snapshot.data!.docs.length;
                  for (var doc in snapshot.data!.docs) {
                    total += (doc['totalAmount'] as num).toDouble();
                  }
                }
                
                return Row(
                  children: [
                    Expanded(child: _statCard("Total Earnings", "৳ ${total.toStringAsFixed(0)}", Colors.green)),
                    const SizedBox(width: 15),
                    Expanded(child: _statCard("Delivered", "$count", Colors.blue)),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),
            const Align(alignment: Alignment.centerLeft, child: Text("Customer Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),

            // 3. Reviews List
            StreamBuilder(
              stream: db.collection('reviews').where('riderId', isEqualTo: riderId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final reviews = snapshot.data!.docs;

                if (reviews.isEmpty) return const Text("No reviews yet.");

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (ctx, i) {
                    final review = reviews[i].data();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(Icons.star, color: Colors.amber),
                        title: Text("Rating: ${review['rating']}"),
                        subtitle: Text(review['comment'] ?? ""),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RiderEditProfilePage(currentData: data)),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}