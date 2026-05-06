import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_drawer.dart';
import 'package:food_delivery_app/features/admin/view_models/order_management_provider.dart';
import 'package:intl/intl.dart';

class AdminOrdersMonitorPage extends ConsumerStatefulWidget {
  const AdminOrdersMonitorPage({super.key});

  @override
  ConsumerState<AdminOrdersMonitorPage> createState() => _AdminOrdersMonitorPageState();
}

class _AdminOrdersMonitorPageState extends ConsumerState<AdminOrdersMonitorPage> {
  int _selectedTabIndex = 0; // 0 for Pending, 1 for Previous

  @override
  Widget build(BuildContext context) {
    final allOrders = ref.watch(allOrdersProvider);
    final pendingOrders = ref.watch(pendingOrdersProvider);
    final previousOrders = ref.watch(previousOrdersProvider);

    return Scaffold(
      drawer: const AdminDrawer(),
      backgroundColor: const Color(0xFFFFF4F3),
      body: Builder(
        builder: (context) => SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Color(0xFFD35400)),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    const Spacer(),
                    Text(
                      "NazEats Express",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFFD35400),
                      ),
                    ),
                    const Spacer(),
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage("assets/profile.png"),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Order Master List",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4A2C2A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Real-time monitoring across all culinary\npartners.",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A2C2A).withOpacity(0.6),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Stats Grid (Dynamic)
                      allOrders.when(
                        data: (orders) => _buildStatsGrid(orders),
                        loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      
                      const SizedBox(height: 30),

                      // Tabs
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8E5).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            _buildTab("PENDING ORDERS", _selectedTabIndex == 0, () => setState(() => _selectedTabIndex = 0)),
                            _buildTab("PREVIOUS ORDERS", _selectedTabIndex == 1, () => setState(() => _selectedTabIndex = 1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Order List
                      _buildOrderList(
                        _selectedTabIndex == 0 ? pendingOrders : previousOrders,
                      ),
                      
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
            ] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isSelected ? const Color(0xFFD35400) : const Color(0xFF4A2C2A).withOpacity(0.4),
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(List<Map<String, dynamic>> orders) {
    int total = orders.length;
    int pending = orders.where((o) => o['status'] == 'pending').length;
    int preparing = orders.where((o) => o['status'] == 'preparing').length;
    int onTheWay = orders.where((o) => o['status'] == 'on_the_way').length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        _buildMonitorStat(Icons.receipt_long_outlined, total.toString(), "TOTAL\nORDERS", const Color(0xFFFFE8E5)),
        _buildMonitorStat(Icons.pending_actions_outlined, pending.toString(), "PENDING", const Color(0xFFF3E5F5)),
        _buildMonitorStat(Icons.restaurant_outlined, preparing.toString(), "PREPARING", const Color(0xFFE3F2FD)),
        _buildMonitorStat(Icons.delivery_dining_outlined, onTheWay.toString(), "ON THE WAY", const Color(0xFFE8F5E9)),
      ],
    );
  }

  Widget _buildMonitorStat(IconData icon, String value, String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFFD35400), size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A).withOpacity(0.4), letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(AsyncValue<List<Map<String, dynamic>>> ordersAsync) {
    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  Icon(Icons.receipt_outlined, size: 50, color: const Color(0xFF4A2C2A).withOpacity(0.2)),
                  const SizedBox(height: 15),
                  Text("No orders found.", style: GoogleFonts.plusJakartaSans(color: const Color(0xFF4A2C2A).withOpacity(0.4))),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(orders[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final String id = order['id'].toString().substring(0, 8).toUpperCase();
    final String status = order['status'] ?? 'pending';
    final double total = (order['totalAmount'] ?? 0.0).toDouble();
    final DateTime date = (order['createdAt'] as dynamic)?.toDate() ?? DateTime.now();
    final List items = order['items'] as List? ?? [];
    
    Color statusColor;
    Color textColor;
    switch (status) {
      case 'pending': statusColor = Colors.red.withOpacity(0.1); textColor = Colors.red; break;
      case 'preparing': statusColor = const Color(0xFFD35400).withOpacity(0.1); textColor = const Color(0xFFD35400); break;
      case 'on_the_way': statusColor = const Color(0xFF9B59B6).withOpacity(0.1); textColor = const Color(0xFF9B59B6); break;
      case 'delivered': statusColor = Colors.green.withOpacity(0.1); textColor = Colors.green; break;
      default: statusColor = Colors.grey.withOpacity(0.1); textColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("#$id", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                child: Text(status.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: textColor)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            DateFormat('MMM dd, yyyy • hh:mm a').format(date),
            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF4A2C2A).withOpacity(0.4)),
          ),
          const Divider(height: 30, color: Color(0xFFFFE8E5)),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text("${item['quantity']}x ", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFFD35400))),
                Text(item['name'] ?? 'Item', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4A2C2A))),
                const Spacer(),
                Text("৳${item['price']}", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF4A2C2A))),
              ],
            ),
          )).toList(),
          const Divider(height: 30, color: Color(0xFFFFE8E5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF4A2C2A).withOpacity(0.5))),
              Text("৳${total.toStringAsFixed(2)}", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFFD35400))),
            ],
          ),
          const SizedBox(height: 20),
          if (_selectedTabIndex == 0)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildActionBtn("Preparing", () => _updateStatus(order['id'], 'preparing'), isSelected: status == 'preparing'),
                  const SizedBox(width: 8),
                  _buildActionBtn("Ready", () => _updateStatus(order['id'], 'ready_for_pickup'), isSelected: status == 'ready_for_pickup'),
                  const SizedBox(width: 8),
                  _buildActionBtn("On Way", () => _updateStatus(order['id'], 'on_the_way'), isSelected: status == 'on_the_way'),
                  const SizedBox(width: 8),
                  _buildActionBtn("Done", () => _updateStatus(order['id'], 'delivered'), isPrimary: true),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, VoidCallback onTap, {bool isPrimary = false, bool isSelected = false}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary 
            ? const Color(0xFFD35400) 
            : (isSelected ? const Color(0xFFD35400).withOpacity(0.2) : const Color(0xFFFFE8E5)),
        foregroundColor: isPrimary 
            ? Colors.white 
            : (isSelected ? const Color(0xFFD35400) : const Color(0xFFD35400).withOpacity(0.6)),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }

  void _updateStatus(String orderId, String status) {
    ref.read(orderManagementControllerProvider.notifier).updateOrderStatus(orderId, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order status updated to $status")),
    );
  }
}
