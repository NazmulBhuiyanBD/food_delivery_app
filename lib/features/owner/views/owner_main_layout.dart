import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'owner_dashboard.dart';
import 'owner_orders_page.dart';
import 'owner_menu_page.dart';
import 'owner_profile_page.dart';
import 'owner_drawer.dart';

class OwnerMainLayout extends ConsumerStatefulWidget {
  const OwnerMainLayout({super.key});

  @override
  ConsumerState<OwnerMainLayout> createState() => _OwnerMainLayoutState();
}

class _OwnerMainLayoutState extends ConsumerState<OwnerMainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const OwnerDashboard(),    // 0: Dashboard
    const OwnerMenuPage(),     // 1: Gallery (Menu)
    const OwnerOrdersPage(),   // 2: Orders
    const OwnerProfilePage(),  // 3: Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const OwnerDrawer(),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          
          // Custom Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: Icons.dashboard_rounded,
                    label: "DASHBOARD",
                    activeShape: BoxShape.circle,
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.restaurant_menu_outlined,
                    label: "GALLERY",
                    activeShape: BoxShape.rectangle,
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: Icons.receipt_long_outlined,
                    label: "ORDERS",
                    activeShape: BoxShape.rectangle,
                  ),
                  _buildNavItem(
                    index: 3,
                    icon: Icons.person_outline_rounded,
                    label: "PROFILE",
                    activeShape: BoxShape.circle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required BoxShape activeShape,
  }) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFD35400) : Colors.transparent,
              borderRadius: isSelected && activeShape == BoxShape.rectangle ? BorderRadius.circular(12) : null,
              shape: isSelected && activeShape == BoxShape.circle ? BoxShape.circle : BoxShape.rectangle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade400,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8,
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
