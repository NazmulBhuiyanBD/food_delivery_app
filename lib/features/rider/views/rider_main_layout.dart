import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
// Relative imports to the files in the same rider/ folder
import 'rider_dashboard.dart';
import 'rider_history_page.dart';
import 'rider_profile_page.dart';
import 'rider_earnings_page.dart';
import 'new_order_request_page.dart';
import 'rider_orders_page.dart'; // newly added tab
import 'package:food_delivery_app/core/firebase_providers.dart';

class RiderMainLayout extends ConsumerStatefulWidget {
  const RiderMainLayout({super.key});

  @override
  ConsumerState<RiderMainLayout> createState() => _RiderMainLayoutState();
}

class _RiderMainLayoutState extends ConsumerState<RiderMainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const RiderDashboard(),
    const RiderOrdersPage(),
    const RiderEarningsPage(),
    const RiderProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 90,
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard_rounded, "DASHBOARD"),
            _buildNavItem(1, Icons.list_alt_rounded, "ORDERS"),
            _buildNavItem(2, Icons.account_balance_wallet_rounded, "EARNINGS"),
            _buildNavItem(3, Icons.person_outline_rounded, "PROFILE"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFFD35400) : Colors.grey.shade400, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isSelected ? const Color(0xFFD35400) : Colors.grey.shade400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}