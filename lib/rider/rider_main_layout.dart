import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Relative imports to the files in the same rider/ folder
import 'rider_dashboard.dart';
import 'rider_history_page.dart';
import 'rider_profile_page.dart';

class RiderMainLayout extends ConsumerStatefulWidget {
  const RiderMainLayout({super.key});

  @override
  ConsumerState<RiderMainLayout> createState() => _RiderMainLayoutState();
}

class _RiderMainLayoutState extends ConsumerState<RiderMainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const RiderDashboard(),
    const RiderHistoryPage(),
    const RiderProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFFFF8A00),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}