import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/features/auth/view_models/auth_controller.dart';
import 'package:food_delivery_app/features/owner/view_models/owner_providers.dart';
import 'package:food_delivery_app/features/auth/views/loading_screen.dart';
import 'owner_edit_profile_page.dart';

class OwnerDrawer extends ConsumerWidget {
  const OwnerDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(ownerProfileProvider);

    return Drawer(
      backgroundColor: const Color(0xFFFFF4F3),
      child: Column(
        children: [
          // Drawer Header
          profileAsync.when(
            data: (p) => UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD35400), Color(0xFFE67E22)],
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: p['bannerImageUrl'] != null ? NetworkImage(p['bannerImageUrl']) : null,
                child: p['bannerImageUrl'] == null ? const Icon(Icons.restaurant, color: Color(0xFFD35400)) : null,
              ),
              accountName: Text(
                p['restaurantName'] ?? "NazEats Express",
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
              ),
              accountEmail: Text(
                p['email'] ?? "Partner Portal",
                style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
            ),
            loading: () => const DrawerHeader(child: Center(child: CircularProgressIndicator(color: Color(0xFFD35400)))),
            error: (_, __) => const DrawerHeader(child: Center(child: Icon(Icons.error))),
          ),

          // Drawer Items
          ListTile(
            leading: const Icon(Icons.edit_note_rounded, color: Color(0xFFD35400)),
            title: Text(
              "Update Restaurant Info",
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF4A2C2A)),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OwnerEditProfilePage()),
              );
            },
          ),
          
          const Divider(indent: 20, endIndent: 20),
          
          const Spacer(),
          
          const Divider(indent: 20, endIndent: 20),
          
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(
              "Sign Out",
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.redAccent),
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Sign Out?"),
                  content: const Text("Are you sure you want to exit the partner portal?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Logout", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoadingScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
