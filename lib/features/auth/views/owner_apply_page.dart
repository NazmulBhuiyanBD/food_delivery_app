import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../view_models/auth_controller.dart';
import 'package:food_delivery_app/models/app_user.dart';
import 'package:food_delivery_app/services/cloudinary_service.dart';

class OwnerApplyPage extends ConsumerStatefulWidget {
  const OwnerApplyPage({super.key});

  @override
  ConsumerState<OwnerApplyPage> createState() => _OwnerApplyPageState();
}

class _OwnerApplyPageState extends ConsumerState<OwnerApplyPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Step 1 Controllers
  final restaurantNameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  String? licenseImageUrl;
  bool _isLicenseUploading = false;

  // Step 2 Controllers
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController(); 
  String? bannerImageUrl;
  bool _isBannerUploading = false;

  int _currentStep = 1;

  @override
  void dispose() {
    restaurantNameCtrl.dispose();
    addressCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage({required bool isLicense}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile == null) return;

    setState(() {
      if (isLicense) _isLicenseUploading = true;
      else _isBannerUploading = true;
    });

    try {
      final url = await CloudinaryService.uploadImage(File(pickedFile.path));
      setState(() {
        if (isLicense) licenseImageUrl = url;
        else bannerImageUrl = url;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (isLicense) _isLicenseUploading = false;
          else _isBannerUploading = false;
        });
      }
    }
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep == 1 && licenseImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload your operating license")),
        );
        return;
      }
      if (_currentStep == 2 && bannerImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload a restaurant banner")),
        );
        return;
      }

      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        // Submit all details to Firestore
        ref.read(authControllerProvider.notifier).signUp(
              emailCtrl.text.trim(),
              passCtrl.text.trim(),
              UserRole.owner,
              extraData: {
                'restaurantName': restaurantNameCtrl.text.trim(),
                'address': addressCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'licenseImageUrl': licenseImageUrl,
                'bannerImageUrl': bannerImageUrl,
                'status': 'pending',
                'createdAt': DateTime.now().toIso8601String(),
              },
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<AppUser?>>(
      authControllerProvider,
      (previous, next) {
        next.when(
          data: (user) {
            if (user != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Application successfully saved! Redirecting to login..."),
                  backgroundColor: Colors.green,
                ),
              );
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            }
          },
          loading: () {},
          error: (e, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
            );
          },
        );
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Clean Header with Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD35400), size: 20),
                    onPressed: () {
                      if (_currentStep > 1) {
                        setState(() => _currentStep--);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    // Step Indicator Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(1),
                        const SizedBox(width: 8),
                        _buildDot(2),
                        const SizedBox(width: 8),
                        _buildDot(3),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Main Application Card
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          )
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStepTitle(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF4A2C2A),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              _getStepSubtitle(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4A2C2A).withOpacity(0.6),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Dynamic Step Content
                            if (_currentStep == 1) _buildStep1(),
                            if (_currentStep == 2) _buildStep2(),
                            if (_currentStep == 3) _buildStep3(),

                            const SizedBox(height: 40),

                            // Submit / Continue Button
                            switch (authState) {
                              AsyncLoading() => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
                              _ => GestureDetector(
                                  onTap: (_isLicenseUploading || _isBannerUploading) ? null : _nextStep,
                                  child: Container(
                                    width: double.infinity,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: (_isLicenseUploading || _isBannerUploading)
                                            ? [Colors.grey, Colors.grey.shade400]
                                            : [const Color(0xFFD35400), const Color(0xFFE67E22)],
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        if (!(_isLicenseUploading || _isBannerUploading))
                                          BoxShadow(
                                            color: const Color(0xFFD35400).withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _currentStep == 3 ? "SUBMIT APPLICATION" : "CONTINUE",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                            },
                          ],
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
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InputField(
          label: "RESTAURANT NAME",
          hint: "e.g. NazEats Bistro",
          controller: restaurantNameCtrl,
          icon: Icons.restaurant_outlined,
        ),
        const SizedBox(height: 25),
        _InputField(
          label: "BUSINESS ADDRESS",
          hint: "123 Culinary St, Gourmet City",
          controller: addressCtrl,
          icon: Icons.location_on_outlined,
          isMultiline: true,
        ),
        const SizedBox(height: 25),
        Text(
          "OPERATING LICENSE",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4A2C2A).withOpacity(0.5),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        _ImagePickerBox(
          onTap: () => _pickAndUploadImage(isLicense: true),
          currentImage: licenseImageUrl,
          isLoading: _isLicenseUploading,
          label: "Upload Trade License",
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InputField(
          label: "BUSINESS EMAIL",
          hint: "chef@restaurant.com",
          controller: emailCtrl,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 25),
        _InputField(
          label: "CONTACT NUMBER",
          hint: "+1 (555) 000-0000",
          controller: phoneCtrl,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 25),
        _InputField(
          label: "CREATE PASSWORD",
          hint: "••••••••",
          controller: passCtrl,
          icon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 25),
        Text(
          "SHOP BANNER",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4A2C2A).withOpacity(0.5),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        _ImagePickerBox(
          onTap: () => _pickAndUploadImage(isLicense: false),
          currentImage: bannerImageUrl,
          isLoading: _isBannerUploading,
          label: "Upload Restaurant Banner",
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReviewItem(label: "Restaurant", value: restaurantNameCtrl.text),
        _ReviewItem(label: "Address", value: addressCtrl.text),
        _ReviewItem(label: "Email", value: emailCtrl.text),
        _ReviewItem(label: "Phone", value: phoneCtrl.text),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4F3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD1CC)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFD35400)),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  "By submitting, you agree to our partner terms and culinary standards.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4A2C2A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStepTitle() {
    if (_currentStep == 1) return "The Venue";
    if (_currentStep == 2) return "Connectivity";
    return "Verification";
  }

  String _getStepSubtitle() {
    if (_currentStep == 1) return "Tell us about your establishment's location and legal status.";
    if (_currentStep == 2) return "How can we reach you and what should your storefront look like?";
    return "Please confirm all information is correct before final submission.";
  }

  Widget _buildDot(int index) {
    bool isActive = index == _currentStep;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD35400) : const Color(0xFFFFD1CC),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool isMultiline;
  final bool obscureText;
  final TextInputType keyboardType;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.isMultiline = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4A2C2A).withOpacity(0.5),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: isMultiline ? 3 : 1,
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A2C2A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFFD35400), size: 20),
            filled: true,
            fillColor: const Color(0xFFFFE8E5).withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}

class _ImagePickerBox extends StatelessWidget {
  final VoidCallback onTap;
  final String? currentImage;
  final String label;
  final bool isLoading;

  const _ImagePickerBox({
    required this.onTap,
    this.currentImage,
    required this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE8E5).withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD1CC), style: BorderStyle.solid),
          image: currentImage != null
              ? DecorationImage(image: NetworkImage(currentImage!), fit: BoxFit.cover)
              : null,
        ),
        child: isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD35400)))
            : currentImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined, color: Color(0xFFD35400), size: 30),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4A2C2A).withOpacity(0.6),
                    ),
                  ),
                ],
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 40)),
              ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4A2C2A).withOpacity(0.4),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4A2C2A),
            ),
          ),
        ],
      ),
    );
  }
}
