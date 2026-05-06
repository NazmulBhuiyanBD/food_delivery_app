import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/theme.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/features/auth/view_models/current_user_provider.dart';
import 'package:food_delivery_app/features/auth/view_models/auth_controller.dart';
import 'package:food_delivery_app/features/rider/view_models/rider_order_provider.dart';
import 'package:intl/intl.dart';

// Provider to fetch active orders assigned to the rider
final activeOrdersProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, riderId) {
  return ref.read(firestoreProvider)
      .collection('orders')
      .where('riderId', isEqualTo: riderId)
      .where('status', isEqualTo: 'ASSIGNED')
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

// Provider to fetch available orders nearby
final nearbyOrdersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(firestoreProvider)
      .collection('orders')
      .where('status', isEqualTo: 'READY')
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

// Provider for Today's Stats
final riderDailyStatsProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, riderId) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  
  return ref.read(firestoreProvider)
      .collection('orders')
      .where('riderId', isEqualTo: riderId)
      .where('status', isEqualTo: 'DELIVERED')
      .snapshots()
      .map((s) {
        double earnings = 0;
        int trips = 0;
        for (var doc in s.docs) {
          final data = doc.data();
          if (data['deliveredAt'] == null) continue;
          
          final deliveredAt = DateTime.parse(data['deliveredAt']);
          if (deliveredAt.isBefore(startOfDay)) continue;

          earnings += (data['deliveryCharge'] as num? ?? 0).toDouble();
          trips++;
        }
        return {
          'earnings': earnings,
          'trips': trips,
        };
      });
});

class RiderOrdersPage extends ConsumerStatefulWidget {
  const RiderOrdersPage({super.key});

  @override
  ConsumerState<RiderOrdersPage> createState() => _RiderOrdersPageState();
}

class _RiderOrdersPageState extends ConsumerState<RiderOrdersPage> {

  @override
  Widget build(BuildContext context) {
    final riderId = ref.watch(currentUserIdProvider);
    final nearbyOrders = ref.watch(nearbyOrdersProvider);
    final activeOrders = ref.watch(activeOrdersProvider(riderId));
    final dailyStats = ref.watch(riderDailyStatsProvider(riderId));
    final onlineStatus = ref.watch(riderOnlineStatusProvider(riderId));
    final isOnline = onlineStatus.value ?? false;

    ref.listen<AsyncValue<List<Map<String, dynamic>>>>(nearbyOrdersProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        final prevCount = previous?.value?.length ?? 0;
        final nextCount = next.value!.length;
        if (nextCount > prevCount) {
          // A new order was marked as ready!
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.white),
                  const SizedBox(width: 10),
                  const Expanded(child: Text("New order ready for pickup!", style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              backgroundColor: const Color(0xFFD35400),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            )
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.refresh(nearbyOrdersProvider),
                color: const Color(0xFFD35400),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // 1. Header
                      _buildHeader(),

                      const SizedBox(height: 30),

                      // 2. Today's Earnings Card
                      dailyStats.when(
                        data: (stats) => _buildEarningsCard(stats['earnings'], stats['trips'], isOnline: isOnline),
                        loading: () => _buildEarningsCard(0, 0, isLoading: true, isOnline: isOnline),
                        error: (_, __) => _buildEarningsCard(0, 0, isOnline: isOnline),
                      ),

                      const SizedBox(height: 35),

                      // 3. Active Orders Section (If any)
                      activeOrders.when(
                        data: (orders) => orders.isNotEmpty 
                          ? _buildActiveOrdersSection(orders) 
                          : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 10),

                      // 4. Available Orders
                      _buildSectionHeader("Available Orders Nearby", "View Map"),

                      const SizedBox(height: 20),

                      if (!isOnline)
                        _buildOfflineState()
                      else
                        nearbyOrders.when(
                          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
                          error: (e, _) => Center(child: Text("Error loading orders: $e")),
                          data: (orders) {
                            if (orders.isEmpty) {
                              return _buildEmptyState();
                            }
                            return Column(
                              children: orders.map((o) => Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _buildOrderCard(
                                  order: o,
                                  restaurant: o['restaurantName'] ?? "Restaurant",
                                  price: (o['totalAmount'] ?? 0).toStringAsFixed(0),
                                  items: "${(o['items'] as List?)?.length ?? 0} Items",
                                  distance: o['distance'] ?? "Available",
                                  time: "New",
                                  priority: o['priority'] ?? false,
                                ),
                              )).toList(),
                            );
                          },
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final riderId = ref.watch(currentUserIdProvider);
    final onlineStatus = ref.watch(riderOnlineStatusProvider(riderId));
    final isOnline = onlineStatus.value ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rider Orders",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A2C2A),
                ),
              ),
              Text(
                "Toggle your status to receive orders",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4A2C2A).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Online Toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD1CC).withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Switch(
                value: isOnline,
                onChanged: (v) {
                  ref.read(riderOnlineStatusControllerProvider).setStatus(riderId, v);
                },
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFFAB2D00),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 8),
              Text(
                isOnline ? "ONLINE" : "OFFLINE",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isOnline ? const Color(0xFFAB2D00) : Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsCard(double earnings, int trips, {bool isLoading = false, bool isOnline = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD35400), Color(0xFFE67E22)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD35400).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TODAY'S EARNINGS",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  isLoading 
                    ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator(color: Colors.white)))
                    : Text(
                        "৳ ${earnings.toStringAsFixed(0)}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                ],
              ),
              const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 50),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem("TRIPS", trips.toString()),
              const SizedBox(width: 30),
              _buildStatItem("ONLINE TIME", isOnline ? "Active Now" : "0h 0m"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Icon(Icons.power_settings_new_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            "You are currently Offline",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4A2C2A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Go online to start receiving new delivery requests in your area.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF4A2C2A).withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {
              final riderId = ref.read(currentUserIdProvider);
              ref.read(riderOnlineStatusControllerProvider).setStatus(riderId, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD35400),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: Text("Go Online Now", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrdersSection(List<Map<String, dynamic>> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Active Deliveries", "Ongoing"),
        const SizedBox(height: 15),
        ...orders.map((o) => Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: _buildOrderCard(
            order: o,
            restaurant: o['customerName'] ?? "Deliver to Customer",
            price: (o['totalAmount'] ?? 0).toStringAsFixed(0),
            items: "${(o['items'] as List?)?.length ?? 0} Items",
            distance: o['address'] ?? "Delivery",
            time: o['status'].toString().replaceAll('_', ' ').toUpperCase(),
            priority: true,
            isActive: true,
          ),
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4A2C2A),
          ),
        ),
        Text(
          action,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFD35400),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Icon(Icons.map_outlined, size: 60, color: const Color(0xFFD35400).withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(
            "No Available Orders",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4A2C2A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Orders will appear here as they are ready for pickup.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF4A2C2A).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard({
    required Map<String, dynamic> order,
    required String restaurant,
    required String price,
    required String items,
    required String distance,
    required String time,
    bool priority = false,
    bool isActive = false,
  }) {
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
        children: [
          // Card Image/Map Area
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              image: const DecorationImage(
                image: NetworkImage("https://st3.depositphotos.com/1000128/15535/v/450/depositphotos_155355604-stock-illustration-map-with-pin-vector-illustration.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFD35400), size: 12),
                        const SizedBox(width: 4),
                        Text(distance, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (priority)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD1CC).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      isActive ? "ACTIVE TASK" : "HIGH PRIORITY",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFAB2D00),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      restaurant,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A2C2A),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "৳ $price",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFAB2D00),
                          ),
                        ),
                        Text(
                          isActive ? time : "Est. $time",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4A2C2A).withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 16, color: Color(0xFFD35400)),
                    const SizedBox(width: 6),
                    Text(items, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF4A2C2A).withOpacity(0.6))),
                    const SizedBox(width: 12),
                    const Icon(Icons.route_outlined, size: 16, color: Color(0xFFD35400)),
                    const SizedBox(width: 6),
                    Text(distance, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF4A2C2A).withOpacity(0.6))),
                  ],
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () async {
                    final firestore = ref.read(firestoreProvider);
                    
                    if (isActive) {
                      // Mark as Delivered
                      try {
                        await firestore.collection('orders').doc(order['id']).update({
                          'status': 'DELIVERED',
                          'deliveredAt': DateTime.now().toIso8601String(),
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order marked as Delivered!")));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                        }
                      }
                      return;
                    }
                    
                    // Accept Order
                    final riderId = ref.read(currentUserIdProvider);
                    try {
                      await firestore.runTransaction((transaction) async {
                        final orderDoc = await transaction.get(firestore.collection('orders').doc(order['id']));
                        if (orderDoc.exists && orderDoc.data()?['status'] == 'READY') {
                          transaction.update(orderDoc.reference, {
                            'status': 'ASSIGNED',
                            'riderId': riderId,
                            'assignedAt': DateTime.now().toIso8601String(),
                          });
                        } else {
                          throw Exception("Already accepted by another rider or status changed.");
                        }
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order accepted!")));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: (priority || isActive) 
                          ? [const Color(0xFFD35400), const Color(0xFFE67E22)]
                          : [const Color(0xFFFFD1CC), const Color(0xFFFFD1CC)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        isActive ? "Mark as Delivered" : "Accept Order",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: (priority || isActive) ? Colors.white : const Color(0xFFAB2D00),
                        ),
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
}