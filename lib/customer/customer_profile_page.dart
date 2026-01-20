import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../auth/auth_controller.dart';
import '../providers/current_user_provider.dart';
import '../providers/image_upload_provider.dart'; 
import '../core/firebase_providers.dart';
import '../services/widget_support.dart';

class CustomerProfilePage extends ConsumerWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final db = ref.watch(firestoreProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // -----------------------------------------------------------
            // A. USER INFO SECTION
            // -----------------------------------------------------------
            StreamBuilder(
              stream: db.collection('customers').doc(userId).snapshots(),
              builder: (context, snapshot) {
                // 1. Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                }

                // 2. Profile Missing State (Show Create Button)
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.warning_amber, size: 50, color: Colors.orange),
                        const SizedBox(height: 10),
                        const Text("Profile incomplete", style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CustomerEditProfilePage(currentData: {}),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A00)),
                          child: const Text("Create Profile", style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  );
                }

                // 3. Data Loaded State
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final name = data['name'] ?? 'Set your name';
                final email = data['email'] ?? 'No Email';
                final phone = data['phone'] ?? 'No Phone';
                final address = data['address'] ?? 'No Address Set';
                final imageUrl = data['imageUrl'];

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Profile Image Circle
                    Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFF8A00), width: 3),
                            image: imageUrl != null && imageUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: imageUrl == null || imageUrl.isEmpty 
                              ? const Icon(Icons.person, size: 60, color: Colors.grey) 
                              : null,
                        ),
                        // Edit Icon Button
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CustomerEditProfilePage(currentData: data),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF8A00),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 20),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    // Name & Email
                    Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(email, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 25),

                    // Details Card (Phone/Address)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.phone, "Phone", phone),
                            const Divider(height: 30),
                            _buildInfoRow(Icons.location_on, "Address", address),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.history, color: Color(0xFFFF8A00)),
                  const SizedBox(width: 10),
                  Text("Recent Orders", style: AppWidget.HeadlineTextField().copyWith(fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder(
              stream: db.collection('orders')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
                }
                
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(padding: EdgeInsets.all(20), child: Text("No orders yet"));
                }
                final orders = snapshot.data!.docs;
                orders.sort((a, b) {
                  Timestamp t1 = a.data()['createdAt'] ?? Timestamp.now();
                  Timestamp t2 = b.data()['createdAt'] ?? Timestamp.now();
                  return t2.compareTo(t1); 
                });

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) {
                    final order = orders[i].data();
                    final status = order['status'] ?? 'pending';
                    final total = order['totalAmount'] ?? 0;
                    final orderId = orders[i].id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        title: Text("Order #${orderId.substring(0, 5)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(order['items'] != null 
                             ? "${(order['items'] as List).length} items" 
                             : "Details unavailable"),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("৳ $total", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5)
                              ),
                              child: Text(
                                status.toUpperCase(), 
                                style: TextStyle(
                                  fontSize: 10, 
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(status)
                                )
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'delivered') return Colors.green;
    if (status == 'pending') return Colors.red;
    if (status == 'on_the_way') return Colors.orange;
    return Colors.grey;
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFFFF8A00)),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(
              width: 200,
              child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ],
        )
      ],
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
    
    // Reset upload provider state
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
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                      image: imageProvider != null 
                          ? DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                              colorFilter: isUploading 
                                ? ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken)
                                : null
                            )
                          : null,
                    ),
                    child: imageProvider == null 
                        ? const Icon(Icons.person, size: 60, color: Colors.grey) 
                        : null,
                  ),
                  
                  // Spinner
                  if (isUploading)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  if (!isUploading)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          ref.read(imageUploadProvider.notifier).pickAndUpload();
                        },
                        style: IconButton.styleFrom(backgroundColor: const Color(0xFFFF8A00)),
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    )
                ],
              ),
            ),
            
            if (isUploading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Uploading image...", style: TextStyle(color: Colors.orange)),
              ),
            if (imageState is AsyncError)
               Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Upload failed: ${imageState.error}", style: const TextStyle(color: Colors.red)),
              ),

            const SizedBox(height: 30),
            _buildTextField("Full Name", nameCtrl, Icons.person),
            const SizedBox(height: 20),
            _buildTextField("Phone Number", phoneCtrl, Icons.phone, inputType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildTextField("Delivery Address", addressCtrl, Icons.location_on, maxLines: 3),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: (isSaving || isUploading) ? null : _saveProfile,
                child: isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SAVE CHANGES", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getImageProvider(AsyncValue<String?> imageState, String? currentUrl) {
    if (imageState.value != null) {
      return NetworkImage(imageState.value!);
    }
    if (currentUrl != null && currentUrl.isNotEmpty) {
      return NetworkImage(currentUrl);
    }
    return null;
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF8A00)),
        filled: true,
        fillColor: const Color(0xFFF4F4F4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
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

      if (newImageUrl != null) {
        updates['imageUrl'] = newImageUrl;
      }
      await ref.read(firestoreProvider).collection('customers').doc(userId).set(
        updates, 
        SetOptions(merge: true),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }
}