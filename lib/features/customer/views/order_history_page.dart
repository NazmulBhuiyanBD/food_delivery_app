import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/features/auth/view_models/current_user_provider.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final db = ref.watch(firestoreProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF4F3), Color(0xFFFFE8E5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF4A2C2A)),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "Order History",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4A2C2A),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 38),
                  ],
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: db
                      .collection('orders')
                      .where('userId', isEqualTo: userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final orders = snapshot.data?.docs ?? [];
                    
                    // Sort in-memory to avoid needing a Firestore composite index
                    final sortedOrders = orders.toList()
                      ..sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>;
                        final bData = b.data() as Map<String, dynamic>;
                        final aTime = (aData['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
                        final bTime = (bData['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
                        return bTime.compareTo(aTime);
                      });

                    if (sortedOrders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 80, color: const Color(0xFF4A2C2A).withOpacity(0.1)),
                            const SizedBox(height: 20),
                            Text(
                              "No orders yet",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4A2C2A).withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: sortedOrders.length,
                      itemBuilder: (context, index) {
                        final order = sortedOrders[index].data() as Map<String, dynamic>;
                        final date = (order['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                        final status = order['status'] ?? 'pending';
                        final items = order['items'] as List? ?? [];
                        final total = order['totalAmount'] ?? 0.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('MMM dd, yyyy • hh:mm a').format(date),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4A2C2A).withOpacity(0.5),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: _getStatusColor(status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              ...items.map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Text(
                                          "${item['quantity']}x ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFD35400),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            item['name'] ?? 'Item',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF4A2C2A),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "৳${item['price']}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF4A2C2A).withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              const Divider(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total Amount",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4A2C2A),
                                    ),
                                  ),
                                  Text(
                                    "৳${total.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFD35400),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
