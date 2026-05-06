import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_drawer.dart';

class AdminFinancePage extends ConsumerWidget {
  const AdminFinancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const AdminDrawer(),
      backgroundColor: const Color(0xFFFFF4F3),
      body: Builder(
        builder: (context) => SafeArea(
          child: Column(
            children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Color(0xFFD35400)),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  Text(
                    "NazEats Express",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFFD35400),
                    ),
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
                      "Q3 FINANCIAL CYCLE",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD35400),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Revenue & Payouts",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A2C2A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Actions row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8E5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFFD35400)),
                              const SizedBox(width: 8),
                              Text(
                                "Sep 2023",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFD35400),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD35400), Color(0xFFE67E22)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD35400).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.file_download_outlined, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Export Report",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Gross Revenue Card
                    _buildFinanceCard(
                      icon: Icons.account_balance_outlined,
                      title: "Total Gross Revenue",
                      value: "\$142,850.00",
                      trend: "+12.4% vs Last Month",
                      cardColor: Colors.white,
                    ),
                    const SizedBox(height: 20),

                    // Platform Fees Card
                    _buildFinanceCard(
                      icon: Icons.pie_chart_outline,
                      title: "Platform Fees Collected",
                      value: "\$21,427.50",
                      trend: "+8.2% vs Last Month",
                      cardColor: Colors.white,
                    ),
                    const SizedBox(height: 20),

                    // Pending Payouts Card (Dark)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A2C2A),
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A2C2A).withOpacity(0.4),
                            blurRadius: 25,
                            offset: const Offset(0, 15),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.hourglass_empty_rounded, color: Color(0xFFE67E22), size: 24),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Pending Payouts",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "\$45,120.00",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD35400).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Processing in 24h",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFE67E22),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Payment Breakdown
                    Text(
                      "Payment Breakdown",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A2C2A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildBreakdownTile(
                      icon: Icons.credit_card_outlined,
                      title: "Online (SSLCommerz)",
                      subtitle: "65% of total volume",
                    ),
                    const SizedBox(height: 12),
                    _buildBreakdownTile(
                      icon: Icons.payments_outlined,
                      title: "Cash on Delivery",
                      subtitle: "35% of total volume",
                    ),
                    const SizedBox(height: 40),

                    // Platform Fee Tracking (Bar chart placeholder)
                    Text(
                      "Platform Fee Tracking",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A2C2A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildChartBar("Wk 1", 0.45, isHighlighted: false),
                          _buildChartBar("Wk 2", 0.8, isHighlighted: true),
                          _buildChartBar("Wk 3", 0.6, isHighlighted: false),
                          _buildChartBar("Wk 4", 0.3, isHighlighted: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Payout Status Registry
                    Text(
                      "Payout Status Registry",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A2C2A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Manage settlements for partners and riders",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4A2C2A).withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Simple Tab Switch
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8E5).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRegistryTab("Restaurants", true),
                          _buildRegistryTab("Riders", false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    // Partner List
                    _buildPartnerRow(
                      name: "Le Petit Bistro",
                      id: "#RES-8921",
                      type: "Premium Partner",
                      image: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=100&q=80",
                    ),
                    const SizedBox(height: 20),
                    _buildPartnerRow(
                      name: "Sakura Sushi",
                      id: "#RES-4432",
                      type: "Standard",
                      image: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=100&q=80",
                    ),
                    const SizedBox(height: 20),
                    _buildPartnerRow(
                      name: "Napoli Pizzeria",
                      id: "#RES-1709",
                      type: "Standard",
                      image: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=100&q=80",
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

  Widget _buildFinanceCard({
    required IconData icon,
    required String title,
    required String value,
    required String trend,
    required Color cardColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardColor,
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
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF4F3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFD35400), size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A2C2A).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4A2C2A),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.green, size: 14),
              const SizedBox(width: 4),
              Text(
                trend,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownTile({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF4F3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFD35400), size: 20),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A2C2A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4A2C2A).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, double heightFactor, {bool isHighlighted = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 50,
          height: 120 * heightFactor,
          decoration: BoxDecoration(
            color: isHighlighted ? const Color(0xFFD35400) : const Color(0xFFFFD1CC),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4A2C2A).withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistryTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: isSelected ? const Color(0xFFD35400) : const Color(0xFF4A2C2A).withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildPartnerRow({required String name, required String id, required String type, required String image}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(image),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A2C2A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "ID: $id",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4A2C2A).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        Text(
          type,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A2C2A).withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
