import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/features/auth/view_models/auth_controller.dart';
import 'admin_dashboard.dart';
import 'category_list_page.dart';
import 'provider_approval_page.dart';
import 'admin_finance_page.dart';
import 'admin_orders_monitor_page.dart';
import 'admin_drawer.dart';

class AdminMainLayout extends ConsumerStatefulWidget {
  const AdminMainLayout({super.key});

  @override
  ConsumerState<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends ConsumerState<AdminMainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CategoryListPage(),       // 0: GALLERY / CATEGORIES
    const ProviderApprovalPage(),   // 1: SEARCH / APPROVALS
    const AdminOrdersMonitorPage(), // 2: ORDERS / MONITORING
    const AdminDashboard(),         // 3: PROFILE / OVERVIEW
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          
          // Custom Bottom Navigation Bar
          Positioned(
            left: 15,
            right: 15,
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
                  _buildNavItem(0, Icons.category_outlined, "CATEGORY"),
                  _buildNavItem(1, Icons.how_to_reg_outlined, "APPROVALS"),
                  _buildNavItem(2, Icons.assignment_outlined, "ORDERS"),
                  _buildNavItem(3, Icons.dashboard_outlined, "DASHBOARD"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
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
              borderRadius: BorderRadius.circular(12),
              shape: BoxShape.rectangle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade400,
              size: 22,
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
