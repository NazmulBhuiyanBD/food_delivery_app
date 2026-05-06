import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:food_delivery_app/features/auth/view_models/auth_controller.dart';
import 'package:food_delivery_app/features/auth/view_models/current_user_provider.dart';
import 'package:food_delivery_app/core/view_models/image_upload_provider.dart'; 
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/services/widget_support.dart';
import 'package:food_delivery_app/features/customer/views/order_history_page.dart';
import 'package:food_delivery_app/features/customer/views/saved_addresses_page.dart';
import 'package:food_delivery_app/features/customer/views/payment_methods_page.dart';
import 'package:food_delivery_app/models/app_user.dart';
import 'package:food_delivery_app/features/customer/views/settings_page.dart';

class CustomerProfilePage extends ConsumerWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final db = ref.watch(firestoreProvider);
    final authEmail = ref.watch(authProvider).currentUser?.email;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF4F3), Color(0xFFFFE8E5)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // 1. User Info Section
              StreamBuilder(
                stream: db.collection('customers').doc(userId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                  }

                  final data = snapshot.hasData && snapshot.data!.exists 
                      ? snapshot.data!.data() as Map<String, dynamic> 
                      : <String, dynamic>{};
                      
                  final name = data['name'] ?? 'Set your name';
                  final email = data['email'] ?? authEmail ?? 'No Email';
                  final imageUrl = data['imageUrl'];

                  return Column(
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
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                          border: Border.all(color: Colors.white, width: 5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(70),
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(imageUrl, fit: BoxFit.cover)
                              : Image.asset("assets/profile.png", fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 25),
                      
                      // Name & Email
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4A2C2A),
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        email.toLowerCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A2C2A).withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Edit Profile Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerEditProfilePage(currentData: data),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD35400), Color(0xFFE67E22)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD35400).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                "Edit Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 2. Navigation Container
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Column(
                          children: [
                            if (ref.watch(authControllerProvider).value?.role == UserRole.admin)
                              _buildEditorialTile(
                                icon: Icons.admin_panel_settings_rounded,
                                title: "Administration",
                                subtitle: "Access administrative hub",
                                onTap: () {
                                  Navigator.pushNamed(context, '/admin');
                                },
                              ),
                            _buildEditorialTile(
                              icon: Icons.receipt_long_rounded,
                              title: "Order History",
                              subtitle: "View past culinary experiences",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
                                );
                              },
                            ),
                            _buildEditorialTile(
                              icon: Icons.location_on_rounded,
                              title: "Saved Addresses",
                              subtitle: "Manage delivery locations",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SavedAddressesPage()),
                                );
                              },
                            ),
                            _buildEditorialTile(
                              icon: Icons.credit_card_rounded,
                              title: "Payment Methods",
                              subtitle: "Cards and digital wallets",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PaymentMethodsPage()),
                                );
                              },
                            ),
                            _buildEditorialTile(
                              icon: Icons.settings_rounded,
                              title: "Settings",
                              subtitle: "Notifications and preferences",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                                );
                              },
                            ),
                            _buildEditorialTile(
                              icon: Icons.logout_rounded,
                              title: "Logout",
                              isDestructive: true,
                              onTap: () async {
                                await ref.read(authControllerProvider.notifier).logout();
                                if (context.mounted) {
                                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorialTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
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
                color: const Color(0xFFFF8A00).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                color: isDestructive ? Colors.red : const Color(0xFF4A2C2A),
                size: 22,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDestructive ? Colors.red : const Color(0xFF4A2C2A),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF4A2C2A).withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF4A2C2A).withOpacity(0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerEditProfilePage extends ConsumerStatefulWidget {
  final Map<String, dynamic> currentData;
  const CustomerEditProfilePage({super.key, required this.currentData});

  @override
  ConsumerState<CustomerEditProfilePage> createState() => _CustomerEditProfilePageState();
}

class _CustomerEditProfilePageState extends ConsumerState<CustomerEditProfilePage> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController addressCtrl;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.currentData['name'] ?? '');
    phoneCtrl = TextEditingController(text: widget.currentData['phone'] ?? '');
    addressCtrl = TextEditingController(text: widget.currentData['address'] ?? '');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(imageUploadProvider.notifier).clear();
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imageUploadProvider);
    final currentImageUrl = widget.currentData['imageUrl'];
    final imageProvider = _getImageProvider(imageState, currentImageUrl);
    final isUploading = imageState is AsyncLoading;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF4F3), Color(0xFFFFE8E5)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF4A2C2A)),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4A2C2A),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 38),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(65),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              imageProvider != null
                                  ? Image(image: imageProvider, fit: BoxFit.cover)
                                  : Image.asset(
                                      "assets/profile.png",
                                      fit: BoxFit.cover,
                                    ),
                              if (isUploading)
                                Container(
                                  color: Colors.black.withOpacity(0.4),
                                  child: const Center(
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!isUploading)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => ref.read(imageUploadProvider.notifier).pickAndUpload(),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFD35400), Color(0xFFE67E22)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD35400).withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                if (isUploading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text("Uploading photo...", style: TextStyle(color: Color(0xFFD35400), fontWeight: FontWeight.w500)),
                  ),
                if (imageState is AsyncError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("Upload failed: ${imageState.error}", style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),

                const SizedBox(height: 35),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPremiumField("Full Name", nameCtrl, Icons.person_rounded),
                      const SizedBox(height: 18),
                      _buildPremiumField("Phone Number", phoneCtrl, Icons.phone_rounded, inputType: TextInputType.phone),
                      const SizedBox(height: 18),
                      _buildPremiumField("Delivery Address", addressCtrl, Icons.location_on_rounded, maxLines: 3),
                      const SizedBox(height: 40),

                      GestureDetector(
                        onTap: (isSaving || isUploading) ? null : _saveProfile,
                        child: Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD35400), Color(0xFFE67E22)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD35400).withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Center(
                            child: isSaving
                                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                : const Text(
                                    "Save Changes",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider? _getImageProvider(AsyncValue<String?> imageState, String? currentUrl) {
    if (imageState.value != null) return NetworkImage(imageState.value!);
    if (currentUrl != null && currentUrl.isNotEmpty) return NetworkImage(currentUrl);
    return null;
  }

  Widget _buildPremiumField(String label, TextEditingController ctrl, IconData icon, {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: inputType,
      maxLines: maxLines,
      style: const TextStyle(color: Color(0xFF4A2C2A), fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: const Color(0xFF4A2C2A).withOpacity(0.5)),
        prefixIcon: Icon(icon, color: const Color(0xFFD35400), size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFD35400), width: 1.5)),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => isSaving = true);
    try {
      final userId = ref.read(currentUserIdProvider);
      final newImageUrl = ref.read(imageUploadProvider).value; 
      final Map<String, dynamic> updates = {
        'name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
      };
      if (newImageUrl != null) updates['imageUrl'] = newImageUrl;
      await ref.read(firestoreProvider).collection('customers').doc(userId).set(updates, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }
}