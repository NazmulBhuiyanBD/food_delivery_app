import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/features/auth/view_models/current_user_provider.dart';
import 'package:intl/intl.dart';

final riderWeeklyEarningsProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, riderId) {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  
  return ref.read(firestoreProvider)
      .collection('orders')
      .where('riderId', isEqualTo: riderId)
      .where('status', isEqualTo: 'delivered')
      .snapshots()
      .map((s) {
        double total = 0;
        List<double> daily = List.filled(7, 0.0);
        for (var doc in s.docs) {
          final data = doc.data();
          if (data['deliveredAt'] == null) continue;
          
          final deliveredAt = DateTime.parse(data['deliveredAt']);
          if (deliveredAt.isBefore(startOfWeekDay)) continue;

          final amount = (data['deliveryCharge'] as num? ?? 0).toDouble();
          total += amount;
          
          final dayIndex = deliveredAt.weekday - 1; // 0 for Monday
          if (dayIndex >= 0 && dayIndex < 7) {
            daily[dayIndex] += amount;
          }
        }
        return {
          'total': total,
          'daily': daily,
          'count': daily.where((e) => e > 0).length,
          'range': "${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d').format(now)}",
        };
      });
});

final recentDeliveriesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, riderId) {
  return ref.read(firestoreProvider)
      .collection('orders')
      .where('riderId', isEqualTo: riderId)
      .where('status', isEqualTo: 'delivered')
      .snapshots()
      .map((s) {
        final docs = s.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        // Sort client-side to avoid index error
        docs.sort((a, b) {
          final timeA = a['deliveredAt'] ?? '';
          final timeB = b['deliveredAt'] ?? '';
          return timeB.compareTo(timeA);
        });
        return docs.take(10).toList();
      });
});

class RiderEarningsPage extends ConsumerWidget {
  const RiderEarningsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riderId = ref.watch(currentUserIdProvider);
    final weeklyStats = ref.watch(riderWeeklyEarningsProvider(riderId));
    final recentDeliveries = ref.watch(recentDeliveriesProvider(riderId));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),

              // 2. Title Section
              Text(
                "FINANCIAL OVERVIEW",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD35400),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your Earnings",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A2C2A),
                ),
              ),
              const SizedBox(height: 18),

              // Cash Out Button
              _buildCashOutButton(),

              const SizedBox(height: 35),

              // 3. Weekly Earnings Card
              weeklyStats.when(
                data: (stats) => _buildWeeklyCard(stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text("Error: $e"),
              ),

              const SizedBox(height: 25),

              // 4. Recent Deliveries
              Text(
                "Recent Deliveries",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF4A2C2A),
                ),
              ),
              const SizedBox(height: 20),

              recentDeliveries.when(
                data: (deliveries) {
                  if (deliveries.isEmpty) {
                    return _buildEmptyState();
                  }
                  return Column(
                    children: deliveries.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildDeliveryItem(
                        name: d['restaurantName'] ?? "Restaurant",
                        time: d['deliveredAt'] != null 
                            ? DateFormat('HH:mm').format(DateTime.parse(d['deliveredAt']))
                            : "Recently",
                        distance: d['distance'] ?? "Delivered",
                        amount: "৳ ${(d['deliveryCharge'] ?? 0).toStringAsFixed(0)}",
                        tipNote: "Completed",
                        color: const Color(0xFFD35400),
                      ),
                    )).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text("Error: $e"),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCashOutButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD35400), Color(0xFFE67E22)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD35400).withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              "Cash Out Now",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyCard(Map<String, dynamic> stats) {
    final double total = stats['total'];
    final List<double> daily = stats['daily'];
    final double maxVal = daily.isEmpty ? 1 : daily.reduce((a, b) => a > b ? a : b);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                "This Week",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A2C2A).withOpacity(0.6),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD1CC).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stats['range'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD35400),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "৳ ${total.toStringAsFixed(0)}",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4A2C2A),
              height: 1,
            ),
          ),
          const SizedBox(height: 30),

          // Bar Chart
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar("M", daily[0] / (maxVal == 0 ? 1 : maxVal), DateTime.now().weekday == 1),
                _buildBar("T", daily[1] / (maxVal == 0 ? 1 : maxVal), DateTime.now().weekday == 2),
                _buildBar("W", daily[2] / (maxVal == 0 ? 1 : maxVal), DateTime.now().weekday == 3),
                _buildBar("T", daily[3] / (maxVal == 0 ? 1 : maxVal), DateTime.now().weekday == 4),
                _buildBar("F", daily[4] / (maxVal == 0 ? 1 : maxVal), DateTime.now().weekday == 5),
                _buildBar("S", daily[5] / (maxVal == 0 ? 1 : maxVal), DateTime.now().weekday == 6),
                _buildBar("S", daily[6] / (maxVal == 0 ? 1 : maxVal), DateTime.now().weekday == 7),
              ],
            ),
          ),
        ],
      ),
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
          Icon(Icons.history_rounded, size: 50, color: const Color(0xFFD35400).withOpacity(0.2)),
          const SizedBox(height: 15),
          Text(
            "No Recent Deliveries",
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF4A2C2A)),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double heightFactor, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 22,
          height: (80 * heightFactor).clamp(5.0, 80.0),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFD35400) : const Color(0xFFFFD1CC),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isActive ? const Color(0xFFD35400) : const Color(0xFF4A2C2A).withOpacity(0.35),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryItem({
    required String name,
    required String time,
    required String distance,
    required String amount,
    required String tipNote,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.restaurant_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A2C2A),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: const Color(0xFF4A2C2A).withOpacity(0.4)),
                    const SizedBox(width: 4),
                    Text(
                      "$time • $distance",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A2C2A).withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A2C2A),
                ),
              ),
              Text(
                tipNote,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD35400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

