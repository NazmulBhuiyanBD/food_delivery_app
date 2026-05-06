import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/features/owner/view_models/owner_providers.dart';
import 'package:food_delivery_app/core/view_models/image_upload_provider.dart';

class OwnerEditProfilePage extends ConsumerStatefulWidget {
  const OwnerEditProfilePage({super.key});

  @override
  ConsumerState<OwnerEditProfilePage> createState() => _OwnerEditProfilePageState();
}

class _OwnerEditProfilePageState extends ConsumerState<OwnerEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();

    // Initialize with current data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(ownerProfileProvider).value;
      if (profile != null) {
        _nameController.text = profile['restaurantName'] ?? "";
        _descController.text = profile['description'] ?? "";
        _addressController.text = profile['address'] ?? "";
        _phoneController.text = profile['phone'] ?? "";
        if (profile['bannerImageUrl'] != null) {
          ref.read(imageUploadProvider.notifier).setImageUrl(profile['bannerImageUrl']);
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final imageUrl = ref.read(imageUploadProvider).value;
      await ref.read(ownerProfileControllerProvider.notifier).updateProfile(
        restaurantName: _nameController.text.trim(),
        description: _descController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        bannerImageUrl: imageUrl,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imageUploadProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4A2C2A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Update Identity",
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF4A2C2A),
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image
              _buildSectionTitle("Restaurant Banner"),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => ref.read(imageUploadProvider.notifier).pickAndUpload(),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFFFFE8E5), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: imageState.when(
                      data: (url) => url != null 
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(url, fit: BoxFit.cover),
                                Container(color: Colors.black26, child: const Icon(Icons.camera_alt, color: Colors.white, size: 30)),
                              ],
                            )
                          : const Center(child: Icon(Icons.add_a_photo_outlined, size: 40, color: Color(0xFFD35400))),
                      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
                      error: (e, _) => Center(child: Text("Error: $e")),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),
              _buildSectionTitle("Business Information"),
              const SizedBox(height: 20),

              _buildLabel("RESTAURANT NAME"),
              _buildTextField(controller: _nameController, hint: "e.g. NazEats Express"),

              _buildLabel("DESCRIPTION"),
              _buildTextField(controller: _descController, hint: "A brief about your kitchen...", maxLines: 3),

              _buildLabel("ADDRESS"),
              _buildTextField(controller: _addressController, hint: "Physical location..."),

              _buildLabel("CONTACT PHONE"),
              _buildTextField(controller: _phoneController, hint: "+1 (555) 000-0000", keyboardType: TextInputType.phone),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: (_isLoading || imageState.isLoading) ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD35400),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          "Save Changes",
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A)),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A).withOpacity(0.5), letterSpacing: 1),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1, TextInputType? keyboardType}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF4A2C2A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
        ),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
    );
  }
}
