import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/features/admin/views/admin_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_finance_page.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

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
                  const Align(
                    alignment: Alignment.centerRight,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage("assets/profile.png"),
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
                      "Overview",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A2C2A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Today's culinary performance metrics.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4A2C2A).withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Buttons
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8E5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Export Report",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFD35400),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD35400),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "View Live Map",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Total Revenue Card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminFinancePage()),
                        );
                      },
                      child: Container(
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
                                Text(
                                  "TOTAL REVENUE",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF4A2C2A).withOpacity(0.5),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFE8E5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFD35400), size: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "\$124,592",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFD35400),
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.trending_up, color: Colors.green, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  "+14.2% vs last week",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Placeholder for mini chart (wave)
                            Container(
                              height: 40,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE8E5).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: CustomPaint(
                                painter: _WavePainter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Total Orders Card
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
                              Text(
                                "TOTAL ORDERS",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4A2C2A).withOpacity(0.5),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE8E5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.receipt_long_outlined, color: Color(0xFFD35400), size: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "1,842",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A2C2A),
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 15),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: 0.75,
                              backgroundColor: const Color(0xFFFFE8E5),
                              color: const Color(0xFFD35400),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "75% to Daily Goal",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4A2C2A).withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats Rows
                    _buildStatTile(title: "Customers", value: "14,209", icon: Icons.person_outline),
                    const SizedBox(height: 15),
                    _buildStatTile(title: "Active Riders", value: "342", icon: Icons.electric_moped_outlined),
                    const SizedBox(height: 15),
                    _buildStatTile(title: "Restaurant Owners", value: "87", icon: Icons.storefront_outlined),
                    const SizedBox(height: 30),

                    // Revenue Growth (Bar Chart Placeholder)
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
                              Text(
                                "Revenue\nGrowth",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4A2C2A),
                                  height: 1.2,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Weekly",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFD35400),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    "Monthly",
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
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBar(height: 40),
                              _buildBar(height: 60),
                              _buildBar(height: 30),
                              _buildBar(height: 80),
                              _buildBar(height: 50),
                              _buildBar(height: 100, isHighlight: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Live Activity
                    Text(
                      "Live Activity",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A2C2A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActivityItem(
                      icon: Icons.restaurant_menu,
                      title: "New Menu Approved",
                      desc: "Le Bernardin updated their tasting menu.",
                      time: "Just now",
                      iconBg: const Color(0xFFFFE8E5),
                      iconColor: const Color(0xFFD35400),
                    ),
                    _buildActivityItem(
                      icon: Icons.warning_amber_rounded,
                      title: "Delivery Delay Alert",
                      desc: "High traffic affecting Zone 4 (Downtown).",
                      time: "12 mins ago",
                      iconBg: const Color(0xFFFFE8E5),
                      iconColor: Colors.red,
                    ),
                    _buildActivityItem(
                      icon: Icons.person_add_alt_1_outlined,
                      title: "New Rider Onboarded",
                      desc: "Marcus T. completed background check.",
                      time: "1 hour ago",
                      iconBg: const Color(0xFFFFE8E5),
                      iconColor: const Color(0xFFD35400),
                    ),
                    
                    const SizedBox(height: 120), // Bottom nav padding
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

  Widget _buildStatTile({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A2C2A).withOpacity(0.6),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4A2C2A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({required double height, bool isHighlight = false}) {
    return Column(
      children: [
        if (isHighlight)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4A2C2A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "\$24k",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            color: isHighlight ? const Color(0xFFD35400) : const Color(0xFFFFD1CC),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String desc,
    required String time,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A2C2A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4A2C2A).withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD35400).withOpacity(0.8),
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

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD1CC)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.8, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.75, 0, size.width, size.height * 0.3);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}