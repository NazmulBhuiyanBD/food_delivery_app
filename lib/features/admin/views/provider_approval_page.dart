import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_drawer.dart';
import 'package:food_delivery_app/features/admin/view_models/approval_provider.dart';
import 'package:food_delivery_app/models/app_user.dart';
import 'provider_details_page.dart';

class ProviderApprovalPage extends ConsumerStatefulWidget {
  const ProviderApprovalPage({super.key});

  @override
  ConsumerState<ProviderApprovalPage> createState() => _ProviderApprovalPageState();
}

class _ProviderApprovalPageState extends ConsumerState<ProviderApprovalPage> {
  int _selectedTypeIndex = 0; // 0 for Restaurants, 1 for Riders
  int _selectedStatusIndex = 0; // 0 for Pending, 1 for Active

  @override
  Widget build(BuildContext context) {
    final pendingOwners = ref.watch(pendingOwnersProvider);
    final pendingRiders = ref.watch(pendingRidersProvider);
    final activeOwners = ref.watch(activeOwnersProvider);
    final activeRiders = ref.watch(activeRidersProvider);

    return Scaffold(
      drawer: const AdminDrawer(),
      backgroundColor: const Color(0xFFFFF4F3),
      body: Builder(
        builder: (context) => SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Color(0xFFD35400)),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    const Spacer(),
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
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage("assets/profile.png"),
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
                        _selectedStatusIndex == 0 ? "Pending Approvals" : "Active Partners",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4A2C2A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedStatusIndex == 0 
                          ? "Review and manage new provider\napplications."
                          : "Manage your approved culinary partners\nand logistics experts.",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A2C2A).withOpacity(0.6),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Status Toggle (Pending vs Active)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8E5).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMiniTab("PENDING", _selectedStatusIndex == 0, () => setState(() => _selectedStatusIndex = 0)),
                            _buildMiniTab("ACTIVE", _selectedStatusIndex == 1, () => setState(() => _selectedStatusIndex = 1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Type Tabs (Restaurants vs Riders)
                      Row(
                        children: [
                          _buildTypeTab("Restaurants", _selectedTypeIndex == 0, () => setState(() => _selectedTypeIndex = 0)),
                          const SizedBox(width: 20),
                          _buildTypeTab("Riders", _selectedTypeIndex == 1, () => setState(() => _selectedTypeIndex = 1)),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Dynamic List
                      _buildDynamicList(
                        pendingOwners: pendingOwners,
                        pendingRiders: pendingRiders,
                        activeOwners: activeOwners,
                        activeRiders: activeRiders,
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

  Widget _buildMiniTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
          ] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isSelected ? const Color(0xFFD35400) : const Color(0xFF4A2C2A).withOpacity(0.4),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? const Color(0xFF4A2C2A) : const Color(0xFF4A2C2A).withOpacity(0.4),
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFD35400),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDynamicList({
    required AsyncValue<List<Map<String, dynamic>>> pendingOwners,
    required AsyncValue<List<Map<String, dynamic>>> pendingRiders,
    required AsyncValue<List<Map<String, dynamic>>> activeOwners,
    required AsyncValue<List<Map<String, dynamic>>> activeRiders,
  }) {
    final currentAsync = (_selectedTypeIndex == 0) 
        ? (_selectedStatusIndex == 0 ? pendingOwners : activeOwners)
        : (_selectedStatusIndex == 0 ? pendingRiders : activeRiders);

    return currentAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 50, color: const Color(0xFF4A2C2A).withOpacity(0.2)),
                  const SizedBox(height: 15),
                  Text(
                    "No ${(_selectedTypeIndex == 0 ? "restaurants" : "riders")} found.",
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFF4A2C2A).withOpacity(0.4)),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildApprovalCard(item);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> item) {
    final bool isRestaurant = _selectedTypeIndex == 0;
    final bool isPending = _selectedStatusIndex == 0;
    final String title = isRestaurant ? (item['restaurantName'] ?? 'Unnamed') : (item['fullName'] ?? 'Unnamed Rider');
    final String subtitle = isRestaurant ? (item['foodCategory'] ?? 'General') : (item['phone'] ?? 'No phone');
    final String location = item['address'] ?? 'No address provided';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProviderDetailsPage(
              providerData: item,
              isRestaurant: isRestaurant,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE8E5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    isRestaurant ? Icons.restaurant_outlined : Icons.delivery_dining_outlined,
                    color: const Color(0xFFD35400),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A)),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFFD35400)),
                      ),
                    ],
                  ),
                ),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFFD1CC), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      "PENDING",
                      style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFFD35400)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "LOCATED AT",
              style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 1),
            ),
            const SizedBox(height: 5),
            Text(
              location,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF4A2C2A).withOpacity(0.7)),
            ),
            const SizedBox(height: 25),
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(isRestaurant ? 'owners' : 'riders', item['id'], UserStatus.approved),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD35400),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text("Approve"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(isRestaurant ? 'owners' : 'riders', item['id'], UserStatus.rejected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD1CC),
                        foregroundColor: const Color(0xFFD35400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text("Reject"),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _updateStatus(isRestaurant ? 'owners' : 'riders', item['id'], UserStatus.pending),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFFD35400).withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text("Move to Pending", style: GoogleFonts.plusJakartaSans(color: const Color(0xFFD35400))),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(String collection, String id, UserStatus status) {
    ref.read(approvalControllerProvider.notifier).updateStatus(collection, id, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Status updated to ${status.name}")),
    );
  }
}
