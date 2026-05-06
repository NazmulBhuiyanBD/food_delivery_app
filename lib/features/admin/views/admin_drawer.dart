import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/features/auth/view_models/auth_controller.dart';

class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: const Color(0xFFFFF4F3),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFFFF4F3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage("assets/profile.png"),
                ),
                const SizedBox(height: 10),
                Text(
                  "Admin Portal",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF4A2C2A),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined, color: Color(0xFF4A2C2A)),
            title: Text("Dashboard", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Color(0xFF4A2C2A)),
            title: Text("Settings", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Divider(color: Color(0xFFFFD1CC)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80), // Extra space for bottom nav
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: Text(
                  "Logout",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
                onTap: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
