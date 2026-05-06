import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/features/owner/view_models/owner_providers.dart';
import 'package:intl/intl.dart';

class OwnerDashboard extends ConsumerWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(ownerProfileProvider);
    final stats = ref.watch(ownerStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Header
              Row(
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
              const SizedBox(height: 30),

              // Today Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD1CC).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFFD35400)),
                    const SizedBox(width: 8),
                    Text(
                      "Today",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD35400),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Revenue Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
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
                    Text(
                      "TOTAL REVENUE",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: "\$").format(stats['totalRevenue']),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            "+14% vs yesterday",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Active Orders Card
              _buildStatCard(
                icon: Icons.receipt_long_outlined,
                title: "ACTIVE ORDERS",
                value: "${stats['activeOrders']}",
                subtitle: "${stats['pendingPreparation']} awaiting preparation",
                iconColor: const Color(0xFFD35400),
                bgColor: Colors.white,
              ),
              const SizedBox(height: 20),

              // Avg Prep Time Card
              _buildStatCard(
                icon: Icons.access_time_rounded,
                title: "AVG. PREP TIME",
                value: "18",
                unit: "min",
                subtitle: "- 2 min from average",
                iconColor: const Color(0xFFD35400),
                bgColor: Colors.white,
                trendIcon: Icons.trending_down_rounded,
              ),
              const SizedBox(height: 20),

              // Refine Menu Promo Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const NetworkImage(
                      "https://www.staffingattiffanies.com/wp-content/uploads/2021/08/happy-male-indian-chef.jpg",
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.6),
                      BlendMode.darken,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Refine the Experience",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Update seasonal offerings or adjust pricing directly from the master menu.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.restaurant_menu, size: 16, color: Colors.white),
                      label: Text(
                        "Manage Menu",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD35400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    String? unit,
    required String subtitle,
    required Color iconColor,
    required Color bgColor,
    IconData? trendIcon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: bgColor,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8E5).withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4A2C2A).withOpacity(0.6),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A2C2A),
                  height: 1,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    unit,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4A2C2A),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (trendIcon != null) ...[
                Icon(trendIcon, size: 14, color: const Color(0xFF4A2C2A).withOpacity(0.5)),
                const SizedBox(width: 4),
              ],
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A2C2A).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
