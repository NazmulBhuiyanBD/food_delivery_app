import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/features/auth/view_models/current_user_provider.dart';
import 'package:food_delivery_app/core/view_models/image_upload_provider.dart';

class RiderEditProfilePage extends ConsumerStatefulWidget {
  final Map<String, dynamic> currentData;
  final bool showOnlyPersonal;
  final bool isReadOnly;
  const RiderEditProfilePage({
    super.key, 
    required this.currentData,
    this.showOnlyPersonal = false,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<RiderEditProfilePage> createState() => _RiderEditProfilePageState();
}

class _RiderEditProfilePageState extends ConsumerState<RiderEditProfilePage> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController vehicleTypeCtrl;
  late TextEditingController vehicleNumberCtrl;
  late TextEditingController dobCtrl;
  String? selectedGender;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.currentData['name'] ?? widget.currentData['fullName'] ?? '');
    phoneCtrl = TextEditingController(text: widget.currentData['phone'] ?? '');
    vehicleTypeCtrl = TextEditingController(text: widget.currentData['vehicleType'] ?? '');
    vehicleNumberCtrl = TextEditingController(text: widget.currentData['vehicleNumber'] ?? '');
    dobCtrl = TextEditingController(text: widget.currentData['dob'] ?? '');
    selectedGender = widget.currentData['gender'];
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(imageUploadProvider.notifier).clear();
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    vehicleTypeCtrl.dispose();
    vehicleNumberCtrl.dispose();
    dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imageUploadProvider);
    final currentImageUrl = widget.currentData['imageUrl'] ?? widget.currentData['profileImageUrl'];
    final imageProvider = _getImageProvider(imageState, currentImageUrl);
    final isUploading = imageState is AsyncLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFFFF4F3),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4A2C2A)),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.isReadOnly 
                    ? "Personal Details" 
                    : (widget.showOnlyPersonal ? "Personal Info" : "Edit Profile"),
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A2C2A),
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  
                  // Profile Image Upload
                  Center(
                    child: Stack(
                      children: [
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
                            child: imageProvider != null
                                ? Image(image: imageProvider, fit: BoxFit.cover)
                                : Image.asset("assets/profile.png", fit: BoxFit.cover),
                          ),
                        ),
                        if (isUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                            ),
                          ),
                        if (!widget.isReadOnly)
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () => ref.read(imageUploadProvider.notifier).pickAndUpload(),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD35400),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Personal Info Section
                  _buildSectionHeader("Personal Information"),
                  const SizedBox(height: 20),
                  _buildPremiumField("Full Name", nameCtrl, Icons.person_outline_rounded, isReadOnly: widget.isReadOnly),
                  const SizedBox(height: 15),
                  _buildPremiumField("Phone Number", phoneCtrl, Icons.phone_outlined, inputType: TextInputType.phone, isReadOnly: widget.isReadOnly),
                  const SizedBox(height: 15),
                  _buildPremiumField("Date of Birth", dobCtrl, Icons.calendar_today_outlined, isReadOnly: true, onTap: widget.isReadOnly ? null : _selectDate),
                  const SizedBox(height: 15),
                  _buildGenderDropdown(isReadOnly: widget.isReadOnly),

                  if (!widget.showOnlyPersonal) ...[
                    const SizedBox(height: 40),

                    // Vehicle Details Section
                    _buildSectionHeader("Vehicle Details"),
                    const SizedBox(height: 20),
                    _buildPremiumField("Vehicle Type", vehicleTypeCtrl, Icons.directions_bike_rounded),
                    const SizedBox(height: 15),
                    _buildPremiumField("Vehicle Number", vehicleNumberCtrl, Icons.numbers_rounded),
                  ],

                  const SizedBox(height: 50),

                  // Save Button
                  if (!widget.isReadOnly)
                    GestureDetector(
                      onTap: (isSaving || isUploading) ? null : _saveProfile,
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD35400), Color(0xFFE67E22)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD35400).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Center(
                          child: isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Save Profile",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF4A2C2A),
      ),
    );
  }

  Widget _buildPremiumField(String label, TextEditingController ctrl, IconData icon, {TextInputType inputType = TextInputType.text, bool isReadOnly = false, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextFormField(
        controller: ctrl,
        keyboardType: inputType,
        readOnly: isReadOnly,
        onTap: onTap,
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFF4A2C2A)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF4A2C2A).withOpacity(0.4), fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: const Color(0xFFD35400), size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown({bool isReadOnly = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: InputDecoration(
          labelText: "Gender",
          labelStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF4A2C2A).withOpacity(0.4), fontWeight: FontWeight.w500),
          prefixIcon: const Icon(Icons.people_outline_rounded, color: Color(0xFFD35400), size: 20),
          border: InputBorder.none,
        ),
        items: ['Male', 'Female', 'Other']
            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
            .toList(),
        onChanged: isReadOnly ? null : (v) => setState(() => selectedGender = v),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD35400),
              onPrimary: Colors.white,
              onSurface: Color(0xFF4A2C2A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => dobCtrl.text = "${picked.day}/${picked.month}/${picked.year}");
    }
  }

  ImageProvider? _getImageProvider(AsyncValue<String?> imageState, String? currentUrl) {
    if (imageState.value != null) return NetworkImage(imageState.value!);
    if (currentUrl != null && currentUrl.isNotEmpty) return NetworkImage(currentUrl);
    return null;
  }

  Future<void> _saveProfile() async {
    setState(() => isSaving = true);
    try {
      final userId = ref.read(currentUserIdProvider);
      final newImageUrl = ref.read(imageUploadProvider).value; 
      
      final Map<String, dynamic> updates = {
        'name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'vehicleType': vehicleTypeCtrl.text.trim(),
        'vehicleNumber': vehicleNumberCtrl.text.trim(),
        'dob': dobCtrl.text.trim(),
        'gender': selectedGender,
      };

      if (newImageUrl != null) updates['imageUrl'] = newImageUrl;

      await ref.read(firestoreProvider).collection('riders').doc(userId).set(
        updates, SetOptions(merge: true)
      );

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