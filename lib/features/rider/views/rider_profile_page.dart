import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/features/auth/view_models/current_user_provider.dart';
import 'package:food_delivery_app/features/auth/view_models/auth_controller.dart';
import 'edit_rider_profile.dart';
import '../view_models/rider_stats_provider.dart';
import 'rider_documents_page.dart';
import 'rider_payout_page.dart';

class RiderProfilePage extends ConsumerWidget {
  const RiderProfilePage({super.key});

  void _navigateToEdit(BuildContext context, Map<String, dynamic> data, {bool showOnlyPersonal = false, bool isReadOnly = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RiderEditProfilePage(
          currentData: data,
          showOnlyPersonal: showOnlyPersonal,
          isReadOnly: isReadOnly,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riderId = ref.watch(currentUserIdProvider);
    final db = ref.watch(firestoreProvider);
    final authUser = ref.watch(authProvider).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      body: SafeArea(
        child: StreamBuilder(
        stream: db.collection('riders').doc(riderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.hasData && snapshot.data!.exists
              ? snapshot.data!.data() as Map<String, dynamic>
              : <String, dynamic>{};
          
          final name = data['name'] ?? data['fullName'] ?? 'Unknown Rider';
          final imageUrl = data['imageUrl'] ?? data['profileImageUrl'];
          final isVerified = data['isVerified'] ?? data['status'] == 'approved';
          final email = authUser?.email ?? data['email'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                 const SizedBox(height: 40),
                
                // 1. Rider Header
                Column(
                  children: [
                    // Profile Image
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          )
                        ],
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(70),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Image.asset("assets/profile.png", fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    // Name
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A2C2A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (email.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          email,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A2C2A).withOpacity(0.5),
                          ),
                        ),
                      ),
                    
                    // Badge
                    if (isVerified)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8E5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFFD35400), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              "Verified Pro Rider",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFD35400),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 40),

                Consumer(
                  builder: (context, ref, _) {
                    final statsAsync = ref.watch(riderStatsProvider(riderId));
                    return statsAsync.when(
                      data: (stats) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8E5).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn("Deliveries", stats['totalDeliveries'].toString()),
                            _buildVerticalDivider(),
                            _buildStatColumn("Rating", "${stats['rating']} ★"),
                            _buildVerticalDivider(),
                            _buildStatColumn("Earnings", "৳${stats['totalEarnings'].toStringAsFixed(0)}"),
                          ],
                        ),
                      ),
                      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // 3. Navigation Sections
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Account",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4A2C2A),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProfileTile(
                        icon: Icons.person_outline_rounded,
                        title: "Personal Information",
                        subtitle: "View your personal details",
                        onTap: () => _navigateToEdit(context, data, showOnlyPersonal: true, isReadOnly: true),
                      ),
                      _buildProfileTile(
                        icon: Icons.edit_note_rounded,
                        title: "Edit Profile Information",
                        subtitle: "Update your profile and vehicle",
                        onTap: () => _navigateToEdit(context, data, showOnlyPersonal: false, isReadOnly: false),
                      ),
                      _buildProfileTile(
                        icon: Icons.description_outlined,
                        title: "Documents & Compliance",
                        subtitle: "License and insurance info",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RiderDocumentsPage()));
                        },
                      ),
                      _buildProfileTile(
                        icon: Icons.account_balance_outlined,
                        title: "Payout Settings",
                        subtitle: "Bank account and tax details",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RiderPayoutPage()));
                        },
                      ),

                      const SizedBox(height: 30),
                      Text(
                        "Support",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4A2C2A),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProfileTile(
                        icon: Icons.help_outline_rounded,
                        title: "Rider Support",
                        onTap: () {},
                      ),
                      _buildProfileTile(
                        icon: Icons.security_outlined,
                        title: "Safety Center",
                        onTap: () {},
                      ),

                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () async {
                          await ref.read(authControllerProvider.notifier).logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8E5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout_rounded, color: Color(0xFFD35400), size: 20),
                              const SizedBox(width: 10),
                              Text(
                                "Logout",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFD35400),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A2C2A).withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFD35400),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: const Color(0xFF4A2C2A).withOpacity(0.1),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8E5).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFD35400), size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4A2C2A),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4A2C2A).withOpacity(0.5),
                      ),
                    ),
                  ],
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