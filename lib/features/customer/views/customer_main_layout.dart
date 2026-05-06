import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/core/theme.dart';
import 'customer_home.dart';
import 'favorites_page.dart';
import 'cart_page.dart';
import 'customer_profile_page.dart';

class CustomerMainLayout extends ConsumerStatefulWidget {
  const CustomerMainLayout({super.key});

  @override
  ConsumerState<CustomerMainLayout> createState() => _CustomerMainLayoutState();
}

class _CustomerMainLayoutState extends ConsumerState<CustomerMainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CustomerHomePage(),
    const FavoritesPage(),
    const CartPage(),
    const CustomerProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows the body to go behind the bottom bar
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
        height: 70,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest.withOpacity(0.9),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: AppTheme.onSurface.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Icons.auto_awesome_mosaic_rounded, 
              isSelected: _selectedIndex == 0, 
              onTap: () => setState(() => _selectedIndex = 0),
            ),
            _NavItem(
              icon: Icons.favorite_rounded, 
              isSelected: _selectedIndex == 1, 
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            _NavItem(
              icon: Icons.shopping_basket_rounded, 
              isSelected: _selectedIndex == 2, 
              onTap: () => setState(() => _selectedIndex = 2),
            ),
            _NavItem(
              icon: Icons.person_rounded, 
              isSelected: _selectedIndex == 3, 
              onTap: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppTheme.onSurface.withOpacity(0.4),
          size: 26,
        ),
      ),
    );
  }
}