import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/features/auth/view_models/current_user_provider.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';

class SavedAddressesPage extends ConsumerWidget {
  const SavedAddressesPage({super.key});

  void _showAddressModal(BuildContext context, WidgetRef ref, {String? docId, Map<String, dynamic>? existingData}) {
    final labelCtrl = TextEditingController(text: existingData?['label'] ?? '');
    final addressCtrl = TextEditingController(text: existingData?['address'] ?? '');
    bool isPrimary = existingData?['isPrimary'] ?? false;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            margin: EdgeInsets.only(bottom: bottomInset),
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF4F3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A2C2A).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    docId == null ? "Add New Address" : "Edit Address",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4A2C2A),
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Label Field
                  TextFormField(
                    controller: labelCtrl,
                    style: const TextStyle(color: Color(0xFF4A2C2A), fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: "Label (e.g., Home, Office)",
                      labelStyle: TextStyle(color: const Color(0xFF4A2C2A).withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.label_outline_rounded, color: Color(0xFFD35400), size: 22),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFD35400), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Address Field
                  TextFormField(
                    controller: addressCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Color(0xFF4A2C2A), fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: "Full Address",
                      labelStyle: TextStyle(color: const Color(0xFF4A2C2A).withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFFD35400), size: 22),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFD35400), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Primary Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: isPrimary,
                        activeColor: const Color(0xFFD35400),
                        onChanged: (val) {
                          setState(() => isPrimary = val ?? false);
                        },
                      ),
                      const Text(
                        "Set as Primary Address",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A2C2A),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Save Button
                  GestureDetector(
                    onTap: isSaving ? null : () async {
                      if (labelCtrl.text.isEmpty || addressCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.red));
                        return;
                      }
                      setState(() => isSaving = true);
                      
                      try {
                        final userId = ref.read(currentUserIdProvider);
                        final db = ref.read(firestoreProvider);
                        final userRef = db.collection('customers').doc(userId);
                        final addressesRef = userRef.collection('addresses');
                        
                        // If setting as primary, unset others
                        if (isPrimary) {
                          final allDocs = await addressesRef.get();
                          final batch = db.batch();
                          for (var doc in allDocs.docs) {
                            if (doc.id != docId && doc.data()['isPrimary'] == true) {
                              batch.update(doc.reference, {'isPrimary': false});
                            }
                          }
                          await batch.commit();
                          
                          // Also update the main address in the customer document
                          await userRef.update({'address': addressCtrl.text.trim()});
                        }
                        
                        final data = {
                          'label': labelCtrl.text.trim(),
                          'address': addressCtrl.text.trim(),
                          'isPrimary': isPrimary,
                          'updatedAt': FieldValue.serverTimestamp(),
                        };
                        
                        if (docId == null) {
                          data['createdAt'] = FieldValue.serverTimestamp();
                          await addressesRef.add(data);
                        } else {
                          await addressesRef.doc(docId).update(data);
                        }
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Address saved successfully"), backgroundColor: Colors.green));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => isSaving = false);
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD35400), Color(0xFFE67E22)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD35400).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Center(
                        child: isSaving 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Save Address",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteAddress(BuildContext context, WidgetRef ref, String docId, bool isPrimary) async {
    final userId = ref.read(currentUserIdProvider);
    final db = ref.read(firestoreProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Address", style: TextStyle(color: Color(0xFF4A2C2A), fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this address?", style: TextStyle(color: Color(0xFF4A2C2A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await db.collection('customers').doc(userId).collection('addresses').doc(docId).delete();
                if (isPrimary) {
                  await db.collection('customers').doc(userId).update({'address': FieldValue.delete()});
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Address deleted"), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final db = ref.watch(firestoreProvider);

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
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                      "Saved Addresses",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4A2C2A),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 38),
                  ],
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: db.collection('customers').doc(userId).collection('addresses').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];

                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        if (docs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                "No saved addresses yet.\nAdd one below!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          
                        for (var doc in docs)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: _buildAddressCard(
                              context: context,
                              ref: ref,
                              docId: doc.id,
                              data: doc.data() as Map<String, dynamic>,
                            ),
                          ),
                        
                        const SizedBox(height: 20),
                        
                        // Add New Address Button
                        GestureDetector(
                          onTap: () => _showAddressModal(context, ref),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFFD35400).withOpacity(0.2),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_location_alt_rounded, color: Color(0xFFD35400)),
                                SizedBox(width: 10),
                                Text(
                                  "Add New Address",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFD35400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    required BuildContext context,
    required WidgetRef ref,
    required String docId,
    required Map<String, dynamic> data,
  }) {
    final label = data['label'] ?? 'Address';
    final address = data['address'] ?? '';
    final isPrimary = data['isPrimary'] ?? false;
    
    IconData icon = Icons.location_on_rounded;
    if (label.toString().toLowerCase().contains('home')) icon = Icons.home_rounded;
    if (label.toString().toLowerCase().contains('work') || label.toString().toLowerCase().contains('office')) icon = Icons.work_rounded;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
        border: isPrimary ? Border.all(color: const Color(0xFFD35400).withOpacity(0.5), width: 1.5) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD35400).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFD35400), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4A2C2A),
                      ),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "PRIMARY",
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.green),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF4A2C2A).withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF4A2C2A)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) {
              if (value == 'edit') {
                _showAddressModal(context, ref, docId: docId, existingData: data);
              } else if (value == 'delete') {
                _deleteAddress(context, ref, docId, isPrimary);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 18, color: Color(0xFFD35400)),
                    SizedBox(width: 10),
                    Text("Edit"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Delete", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
