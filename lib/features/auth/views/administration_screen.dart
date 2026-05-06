import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../admin/views/admin_drawer.dart';
import '../../admin/views/admin_main_layout.dart';
import 'admin_login_page.dart';
import 'owner_login_page.dart';
import 'rider_login_page.dart';

class AdministrationScreen extends StatelessWidget {
  const AdministrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu, color: Color(0xFFD35400), size: 24),
                    const SizedBox(width: 10),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline, color: Color(0xFF4A2C2A), size: 20),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        "Select Your\nPortal",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4A2C2A),
                          height: 1.1,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Access the NazEats Express administration tools customized for your specific role.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4A2C2A).withOpacity(0.6),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Portal Cards
                      _buildPortalCard(
                        title: "System Administrator",
                        subtitle: "Manage global settings and users",
                        icon: Icons.security_outlined,
                        iconBg: const Color(0xFFD35400),
                        cardBg: const Color(0xFFFFE8E5).withOpacity(0.7),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminLoginPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildPortalCard(
                        title: "Restaurant Owner",
                        subtitle: "Manage menus and incoming orders",
                        icon: Icons.storefront_outlined,
                        iconBg: const Color(0xFFFFE8E5),
                        iconColor: const Color(0xFFD35400),
                        cardBg: const Color(0xFFF3E5F5).withOpacity(0.3),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OwnerLoginPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildPortalCard(
                        title: "Delivery Rider",
                        subtitle: "View routes and delivery tasks",
                        icon: Icons.electric_moped_outlined,
                        iconBg: const Color(0xFFF3E5F5),
                        iconColor: const Color(0xFF9B59B6),
                        cardBg: const Color(0xFFFFE8E5).withOpacity(0.3),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RiderLoginPage()),
                          );
                        },
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

  Widget _buildPortalCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color cardBg,
    Color iconColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconBg.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4A2C2A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4A2C2A).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: const Color(0xFF4A2C2A).withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
