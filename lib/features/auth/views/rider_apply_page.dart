import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../view_models/auth_controller.dart';
import 'package:food_delivery_app/models/app_user.dart';
import 'package:food_delivery_app/services/cloudinary_service.dart';

class RiderApplyPage extends ConsumerStatefulWidget {
  const RiderApplyPage({super.key});

  @override
  ConsumerState<RiderApplyPage> createState() => _RiderApplyPageState();
}

class _RiderApplyPageState extends ConsumerState<RiderApplyPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Step 1: Personal
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  DateTime? selectedDob;

  // Step 2: Vehicle
  String? vehicleType = 'Motorcycle';
  final vehicleNumCtrl = TextEditingController();
  final plateNumCtrl = TextEditingController();

  // Step 3: Documents
  String? nidImageUrl;
  String? licenseImageUrl;
  String? profileImageUrl;
  bool _isUploadingNid = false;
  bool _isUploadingLicense = false;
  bool _isUploadingProfile = false;

  int _currentStep = 1;

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    dobCtrl.dispose();
    passCtrl.dispose();
    vehicleNumCtrl.dispose();
    plateNumCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
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
    if (picked != null && picked != selectedDob) {
      setState(() {
        selectedDob = picked;
        dobCtrl.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickAndUpload(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      if (type == 'nid') _isUploadingNid = true;
      else if (type == 'license') _isUploadingLicense = true;
      else _isUploadingProfile = true;
    });

    try {
      final url = await CloudinaryService.uploadImage(File(pickedFile.path));
      setState(() {
        if (type == 'nid') nidImageUrl = url;
        else if (type == 'license') licenseImageUrl = url;
        else profileImageUrl = url;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          if (type == 'nid') _isUploadingNid = false;
          else if (type == 'license') _isUploadingLicense = false;
          else _isUploadingProfile = false;
        });
      }
    }
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep == 3 && (nidImageUrl == null || licenseImageUrl == null || profileImageUrl == null)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload all required documents")));
        return;
      }

      if (_currentStep < 4) {
        setState(() => _currentStep++);
      } else {
        // Final Submission
        ref.read(authControllerProvider.notifier).signUp(
          emailCtrl.text.trim(),
          passCtrl.text.trim(),
          UserRole.rider,
          extraData: {
            'firstName': firstNameCtrl.text.trim(),
            'lastName': lastNameCtrl.text.trim(),
            'fullName': "${firstNameCtrl.text} ${lastNameCtrl.text}",
            'phone': phoneCtrl.text.trim(),
            'dob': dobCtrl.text.trim(),
            'vehicleType': vehicleType,
            'vehicleNumber': vehicleNumCtrl.text.trim(),
            'plateNumber': plateNumCtrl.text.trim(),
            'nidImageUrl': nidImageUrl,
            'licenseImageUrl': licenseImageUrl,
            'profileImageUrl': profileImageUrl,
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
            // Clean Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD35400), size: 20),
                    onPressed: () {
                      if (_currentStep > 1) setState(() => _currentStep--);
                      else Navigator.pop(context);
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
                    _buildStepIndicator(),
                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 15))],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getStepTitle(), style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A))),
                            const SizedBox(height: 10),
                            Text(_getStepSubtitle(), style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF4A2C2A).withOpacity(0.6))),
                            const SizedBox(height: 40),

                            if (_currentStep == 1) _buildStep1(),
                            if (_currentStep == 2) _buildStep2(),
                            if (_currentStep == 3) _buildStep3(),
                            if (_currentStep == 4) _buildStep4(),

                            const SizedBox(height: 40),

                            switch (authState) {
                              AsyncLoading() => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
                              _ => GestureDetector(
                                  onTap: (_isUploadingNid || _isUploadingLicense || _isUploadingProfile) ? null : _nextStep,
                                  child: Container(
                                    width: double.infinity,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: (_isUploadingNid || _isUploadingLicense || _isUploadingProfile)
                                            ? [Colors.grey, Colors.grey.shade400]
                                            : [const Color(0xFFD35400), const Color(0xFFE67E22)],
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _currentStep == 4 ? "COMPLETE APPLICATION" : "CONTINUE",
                                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                      ),
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

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isActive = index + 1 <= _currentStep;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: index + 1 == _currentStep ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFD35400) : const Color(0xFFFFD1CC),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            if (index < 3) const SizedBox(width: 8),
          ],
        );
      }),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        _InputField(label: "FIRST NAME", hint: "Jane", controller: firstNameCtrl, icon: Icons.person_outline),
        const SizedBox(height: 20),
        _InputField(label: "LAST NAME", hint: "Doe", controller: lastNameCtrl, icon: Icons.person_outline),
        const SizedBox(height: 20),
        _InputField(
          label: "DATE OF BIRTH",
          hint: "Select Date",
          controller: dobCtrl,
          icon: Icons.calendar_today_outlined,
          readOnly: true,
          onTap: () => _selectDate(context),
        ),
        const SizedBox(height: 20),
        _InputField(label: "EMAIL", hint: "rider@example.com", controller: emailCtrl, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 20),
        _InputField(label: "PHONE", hint: "+1 (555) 000-0000", controller: phoneCtrl, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
        const SizedBox(height: 20),
        _InputField(label: "PASSWORD", hint: "••••••••", controller: passCtrl, icon: Icons.lock_outline, obscureText: true),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("VEHICLE TYPE", style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A).withOpacity(0.5), letterSpacing: 1)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: vehicleType,
          items: ['Motorcycle', 'Bicycle', 'Car'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => vehicleType = v),
          decoration: _inputDecoration(null, Icons.delivery_dining_outlined),
        ),
        const SizedBox(height: 20),
        _InputField(label: "VEHICLE MODEL/NUMBER", hint: "e.g. Honda Civic 2022", controller: vehicleNumCtrl, icon: Icons.info_outline),
        const SizedBox(height: 20),
        _InputField(label: "PLATE NUMBER", hint: "GUR-1234", controller: plateNumCtrl, icon: Icons.numbers_outlined),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        _DocumentPicker(label: "NID / PASSPORT", currentUrl: nidImageUrl, isLoading: _isUploadingNid, onTap: () => _pickAndUpload('nid')),
        const SizedBox(height: 20),
        _DocumentPicker(label: "DRIVING LICENSE", currentUrl: licenseImageUrl, isLoading: _isUploadingLicense, onTap: () => _pickAndUpload('license')),
        const SizedBox(height: 20),
        _DocumentPicker(label: "PROFILE PHOTO", currentUrl: profileImageUrl, isLoading: _isUploadingProfile, onTap: () => _pickAndUpload('profile')),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      children: [
        _ReviewItem(label: "Full Name", value: "${firstNameCtrl.text} ${lastNameCtrl.text}"),
        _ReviewItem(label: "Vehicle", value: "$vehicleType - ${plateNumCtrl.text}"),
        _ReviewItem(label: "Contact", value: phoneCtrl.text),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFFFF4F3), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFFD1CC))),
          child: Text("I confirm that all information provided is accurate and I am ready to join the delivery fleet.", textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  String _getStepTitle() {
    if (_currentStep == 1) return "Identity";
    if (_currentStep == 2) return "Mobility";
    if (_currentStep == 3) return "Credentials";
    return "Confirm";
  }

  String _getStepSubtitle() {
    if (_currentStep == 1) return "Who will be joining our elite delivery team?";
    if (_currentStep == 2) return "Tell us about the vehicle you'll be using.";
    if (_currentStep == 3) return "Please upload clear images of your legal documents.";
    return "Verify your application before final submission.";
  }

  InputDecoration _inputDecoration(String? hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFFD35400), size: 20),
      filled: true,
      fillColor: const Color(0xFFFFE8E5).withOpacity(0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool obscureText;
  final TextInputType keyboardType;

  const _InputField({required this.label, required this.hint, required this.controller, required this.icon, this.readOnly = false, this.onTap, this.obscureText = false, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A).withOpacity(0.5), letterSpacing: 1)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFFD35400), size: 20),
            filled: true,
            fillColor: const Color(0xFFFFE8E5).withOpacity(0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}

class _DocumentPicker extends StatelessWidget {
  final String label;
  final String? currentUrl;
  final bool isLoading;
  final VoidCallback onTap;

  const _DocumentPicker({required this.label, this.currentUrl, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE8E5).withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD1CC)),
          image: currentUrl != null ? DecorationImage(image: NetworkImage(currentUrl!), fit: BoxFit.cover) : null,
        ),
        child: isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD35400)))
            : currentUrl == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload_file, color: Color(0xFFD35400)),
                  const SizedBox(height: 5),
                  Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF4A2C2A).withOpacity(0.6))),
                ],
              )
            : Container(decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(20)), child: const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 30))),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF4A2C2A).withOpacity(0.5))),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A))),
        ],
      ),
    );
  }
}
