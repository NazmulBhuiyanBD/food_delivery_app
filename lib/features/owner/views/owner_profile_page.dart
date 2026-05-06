import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/features/auth/view_models/auth_controller.dart';
import 'package:food_delivery_app/features/owner/view_models/owner_providers.dart';
import 'package:intl/intl.dart';

class OwnerProfilePage extends ConsumerWidget {
  const OwnerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(ownerProfileProvider);
    final stats = ref.watch(ownerStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    // Restaurant Card
                    Container(
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
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              image: DecorationImage(
                                image: profileAsync.when(
                                  data: (p) => p['bannerImageUrl'] != null 
                                        ? NetworkImage(p['bannerImageUrl']) 
                                      : const NetworkImage("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&q=80"),
                                  loading: () => const NetworkImage("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&q=80"),
                                  error: (_, __) => const NetworkImage("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&q=80"),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      )
                                    ],
                                  ),
                                  child: const Icon(Icons.restaurant, color: Color(0xFFD35400), size: 30),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profileAsync.when(
                                          data: (p) => p['restaurantName'] ?? "Unnamed Restaurant",
                                          loading: () => "...",
                                          error: (_, __) => "Error",
                                        ),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF4A2C2A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        profileAsync.when(
                                          data: (p) => "Managed by ${p['email'] ?? 'Owner'}",
                                          loading: () => "...",
                                          error: (_, __) => "Error",
                                        ),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF4A2C2A).withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Business Settings
                    _buildSettingsTile(
                      icon: Icons.storefront_outlined,
                      title: "Business Settings",
                      subtitle: "Manage operating hours, location details, contact info, and tax settings.",
                      actionText: "Manage Details",
                    ),
                    const SizedBox(height: 20),

                    // Earnings Report Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE8E5).withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.bar_chart_rounded, color: Color(0xFFD35400), size: 20),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD1CC).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "THIS WEEK",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFD35400),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Earnings Report",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A2C2A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                NumberFormat.currency(symbol: "\$").format(stats['totalRevenue']),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4A2C2A),
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.arrow_upward, size: 10, color: Colors.green),
                                    Text(
                                      "12%",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "View detailed financial breakdowns, payouts, and performance metrics.",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF4A2C2A).withOpacity(0.6),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Text(
                                "View Reports",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFD35400),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward, size: 14, color: Color(0xFFD35400)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Reviews Tile
                    _buildSettingsTile(
                      icon: Icons.chat_bubble_outline,
                      title: "Reviews",
                      subtitle: "Read and respond to customer feedback to improve service quality.",
                      actionText: "Manage Reviews",
                      trailingBadge: "4.8",
                    ),
                    const SizedBox(height: 30),


                    const SizedBox(height: 100), // Nav bar padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    String? trailingBadge,
  }) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8E5).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFFD35400), size: 20),
              ),
              if (trailingBadge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4F3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFE67E22), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        trailingBadge,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD35400),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4A2C2A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4A2C2A).withOpacity(0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(
                actionText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD35400),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward, size: 14, color: Color(0xFFD35400)),
            ],
          ),
        ],
      ),
    );
  }
}
