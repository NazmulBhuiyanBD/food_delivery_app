import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/features/owner/view_models/owner_providers.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:intl/intl.dart';

class OwnerOrdersPage extends ConsumerStatefulWidget {
  const OwnerOrdersPage({super.key});

  @override
  ConsumerState<OwnerOrdersPage> createState() => _OwnerOrdersPageState();
}

class _OwnerOrdersPageState extends ConsumerState<OwnerOrdersPage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Preparing'];

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      await ref.read(firestoreProvider).collection('orders').doc(orderId).update({
        'status': newStatus,
      });
      if (newStatus == 'READY' && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 10),
                Text("Order Ready", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: Text(
              "The order has been marked as READY and broadcasted to nearby riders. A rider will accept it shortly.",
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK", style: GoogleFonts.plusJakartaSans(color: const Color(0xFFD35400), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update status: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(ownerProfileProvider);
    final ordersAsync = ref.watch(ownerOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFFD35400)),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  const Spacer(),
                  Text(
                    profileAsync.when(
                      data: (p) => p['restaurantName'] ?? "NazEats Express",
                      loading: () => "...",
                      error: (_, __) => "NazEats Express",
                    ),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFFD35400),
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: profileAsync.when(
                      data: (p) => p['bannerImageUrl'] != null ? NetworkImage(p['bannerImageUrl']) : null,
                      loading: () => null,
                      error: (_, __) => null,
                    ) as ImageProvider?,
                    child: profileAsync.when(
                      data: (p) => p['bannerImageUrl'] == null ? const Icon(Icons.person, size: 20, color: Colors.grey) : null,
                      loading: () => const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
                      error: (_, __) => const Icon(Icons.error),
                    ),
                  ),
                ],
              ),
            ),

            // Title Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Active Orders",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFD35400),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Filters
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;
                  
                  return ordersAsync.when(
                    data: (orders) {
                      final count = orders.where((o) => (o['status'] as String).toLowerCase() == filter.toLowerCase()).length;
                      
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFD35400) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFD35400) : const Color(0xFFFFE8E5),
                            ),
                          ),
                          child: Center(
                            child: Row(
                              children: [
                                Text(
                                  filter,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : const Color(0xFF4A2C2A).withOpacity(0.6),
                                  ),
                                ),
                                if (count > 0 && filter != 'All') ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      "$count",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Order List
            Expanded(
              child: ordersAsync.when(
                data: (orders) {
                  final filteredOrders = _selectedFilter == 'All'
                      ? orders
                      : orders.where((o) => (o['status'] as String).toLowerCase() == _selectedFilter.toLowerCase()).toList();

                  if (filteredOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            "No orders found",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final itemsData = (order['items'] as List? ?? []);
                      final createdAt = order['createdAt'] as Timestamp?;
                      final now = DateTime.now();
                      String timeText = "Recently";
                      
                      if (createdAt != null) {
                        final diff = now.difference(createdAt.toDate()).inMinutes;
                        if (diff < 1) {
                          timeText = "Just now";
                        } else if (diff < 60) {
                          timeText = "Placed $diff mins ago";
                        } else {
                          timeText = DateFormat('hh:mm a').format(createdAt.toDate());
                        }
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: _buildOrderCard(
                          id: "#${order['id'].toString().substring(0, 4).toUpperCase()}",
                          timeInfo: timeText,
                          amount: NumberFormat.currency(symbol: "\$").format(order['totalAmount'] ?? order['amount'] ?? 0),
                          type: order['deliveryType'] ?? "Delivery",
                          status: (order['status'] as String).toUpperCase(),
                          customerName: order['customerName'] ?? "Guest",
                          customerPhone: order['customerPhone'] ?? "No Phone",
                          items: itemsData.map((item) => _OrderItem(
                            qty: item['quantity'] ?? 1,
                            name: item['name'] ?? "Item",
                            notes: item['notes'],
                          )).toList(),
                          onReject: () => _updateStatus(order['id'], 'REJECTED'),
                          onAccept: () => _updateStatus(order['id'], 'PREPARING'),
                          onReady: () => _updateStatus(order['id'], 'READY'),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
                error: (e, _) => Center(child: Text("Error: $e")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard({
    required String id,
    required String timeInfo,
    required String amount,
    required String type,
    required String status,
    required String customerName,
    required String customerPhone,
    required List<_OrderItem> items,
    VoidCallback? onReject,
    VoidCallback? onAccept,
    VoidCallback? onReady,
  }) {
    final isPending = status == "PENDING";
    final isPreparing = status == "PREPARING";
    final badgeColor = isPending ? const Color(0xFFC0392B) : (isPreparing ? const Color(0xFF9B59B6) : Colors.green);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with Status Badge
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: Text(
                status,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          id,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFD35400),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeInfo,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A2C2A).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amount,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4A2C2A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8E5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            type,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFD35400),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Customer Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFE0E0E0),
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A2C2A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 10, color: const Color(0xFFD35400).withOpacity(0.8)),
                              const SizedBox(width: 4),
                              Text(
                                customerPhone,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4A2C2A).withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Order Items
                Text(
                  "ORDER ITEMS",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF9B59B6),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 15),
                ...items.map((item) => _buildItemRow(item)).toList(),
                const SizedBox(height: 25),

                // Action Buttons
                if (isPending)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFD1CC), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            "Reject",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A2C2A).withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD35400),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                            shadowColor: const Color(0xFFD35400).withOpacity(0.5),
                          ),
                          child: Text(
                            "Accept",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onReady,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD1CC).withOpacity(0.6),
                        foregroundColor: const Color(0xFFD35400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Text(
                        "Mark as Ready",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD35400),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(_OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8E5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "${item.qty}",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFD35400),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A2C2A),
                  ),
                ),
                if (item.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.notes!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4A2C2A).withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItem {
  final int qty;
  final String name;
  final String? notes;

  _OrderItem({required this.qty, required this.name, this.notes});
}
