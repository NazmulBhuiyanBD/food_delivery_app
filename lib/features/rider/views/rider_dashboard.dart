import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/features/auth/view_models/current_user_provider.dart';
import 'package:intl/intl.dart';

// Provider for Lifetime Stats
final riderLifetimeStatsProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, riderId) {
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
          earnings += (data['deliveryCharge'] as num? ?? 0).toDouble();
          trips++;
        }
        return {
          'earnings': earnings,
          'trips': trips,
        };
      });
});

// Provider for Completed Orders
final completedOrdersProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, riderId) {
  return ref.read(firestoreProvider)
      .collection('orders')
      .where('riderId', isEqualTo: riderId)
      .where('status', isEqualTo: 'DELIVERED')
      .snapshots()
      .map((s) {
        final docs = s.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        // Sort manually because orderBy needs a composite index
        docs.sort((a, b) {
          final aDate = a['deliveredAt'] != null ? DateTime.parse(a['deliveredAt']) : DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b['deliveredAt'] != null ? DateTime.parse(b['deliveredAt']) : DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
        return docs;
      });
});

class RiderDashboard extends ConsumerStatefulWidget {
  const RiderDashboard({super.key});

  @override
  ConsumerState<RiderDashboard> createState() => _RiderDashboardState();
}

class _RiderDashboardState extends ConsumerState<RiderDashboard> {
  @override
  Widget build(BuildContext context) {
    final riderId = ref.watch(currentUserIdProvider);
    final lifetimeStats = ref.watch(riderLifetimeStatsProvider(riderId));
    final completedOrders = ref.watch(completedOrdersProvider(riderId));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.refresh(riderLifetimeStatsProvider(riderId));
                  ref.refresh(completedOrdersProvider(riderId));
                },
                color: const Color(0xFFD35400),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // 1. Header
                      Text(
                        "Dashboard",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4A2C2A),
                        ),
                      ),
                      Text(
                        "Your lifetime delivery metrics",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A2C2A).withOpacity(0.5),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 2. Lifetime Earnings Card
                      lifetimeStats.when(
                        data: (stats) => _buildEarningsCard(stats['earnings'], stats['trips']),
                        loading: () => _buildEarningsCard(0, 0, isLoading: true),
                        error: (_, __) => _buildEarningsCard(0, 0),
                      ),

                      const SizedBox(height: 35),

                      // 3. Completed Orders Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Previous Orders",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A2C2A),
                            ),
                          ),
                          Text(
                            "Completed",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      completedOrders.when(
                        data: (orders) {
                          if (orders.isEmpty) {
                            return _buildEmptyState();
                          }
                          return Column(
                            children: orders.map((o) => Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: _buildOrderHistoryCard(o),
                            )).toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
                        error: (e, _) => Center(child: Text("Error loading history: $e")),
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

  Widget _buildEarningsCard(double earnings, int trips, {bool isLoading = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF4A2C2A), // Dark elegant background
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A2C2A).withOpacity(0.3),
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
                    "TOTAL EARNINGS",
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
              const Icon(Icons.show_chart_rounded, color: Color(0xFFD35400), size: 50),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem("TOTAL DELIVERIES", trips.toString()),
            ],
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
          Icon(Icons.history, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            "No Deliveries Yet",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4A2C2A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your completed orders will appear here.",
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

  Widget _buildOrderHistoryCard(Map<String, dynamic> order) {
    final deliveredAt = order['deliveredAt'] != null 
        ? DateTime.parse(order['deliveredAt']) 
        : DateTime.now();
    final timeStr = DateFormat('MMM d, yyyy • h:mm a').format(deliveredAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['restaurantName'] ?? "Restaurant",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A2C2A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4A2C2A).withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "+৳ ${(order['deliveryCharge'] ?? 0).toStringAsFixed(0)}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Earned",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}