import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Adjust these imports based on your actual path, usually relative or package:
import '../core/firebase_providers.dart';
import '../providers/current_user_provider.dart';
import '../providers/image_upload_provider.dart';

class RiderEditProfilePage extends ConsumerStatefulWidget {
  final Map<String, dynamic> currentData;
  const RiderEditProfilePage({super.key, required this.currentData});

  @override
  ConsumerState<RiderEditProfilePage> createState() => _RiderEditProfilePageState();
}

class _RiderEditProfilePageState extends ConsumerState<RiderEditProfilePage> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.currentData['name'] ?? '');
    phoneCtrl = TextEditingController(text: widget.currentData['phone'] ?? '');
    
    // Clear previous upload state so we don't show old uploaded images
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(imageUploadProvider.notifier).clear();
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imageUploadProvider);
    final currentImageUrl = widget.currentData['imageUrl'];
    final imageProvider = _getImageProvider(imageState, currentImageUrl);
    final isUploading = imageState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Rider Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- Image Upload Section ---
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                      border: Border.all(color: const Color(0xFFFF8A00), width: 2),
                      image: imageProvider != null 
                          ? DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                              // Dim image while uploading
                              colorFilter: isUploading 
                                  ? ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken)
                                  : null,
                            )
                          : null,
                    ),
                    child: imageProvider == null 
                        ? const Icon(Icons.person, size: 60, color: Colors.grey) 
                        : null,
                  ),

                  // Loading Spinner
                  if (isUploading)
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                    ),

                  // Camera Icon
                  if (!isUploading)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: () => ref.read(imageUploadProvider.notifier).pickAndUpload(),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8A00),
                          padding: const EdgeInsets.all(8),
                        ),
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    )
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            if (isUploading)
              const Text("Uploading image...", style: TextStyle(color: Colors.grey, fontSize: 12)),
            if (imageState is AsyncError)
               Text("Upload failed: ${imageState.error}", style: const TextStyle(color: Colors.red, fontSize: 12)),
            
            const SizedBox(height: 30),

            // --- Form Fields ---
            _buildTextField("Full Name", nameCtrl, Icons.person),
            const SizedBox(height: 20),
            _buildTextField("Phone Number", phoneCtrl, Icons.phone, inputType: TextInputType.phone),

            const SizedBox(height: 40),

            // --- Save Button ---
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
    if (imageState.value != null) return NetworkImage(imageState.value!);
    if (currentUrl != null && currentUrl.isNotEmpty) return NetworkImage(currentUrl);
    return null;
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: inputType,
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
      };

      if (newImageUrl != null) updates['imageUrl'] = newImageUrl;

      // Use SetOptions(merge: true) to create the document if it doesn't exist
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