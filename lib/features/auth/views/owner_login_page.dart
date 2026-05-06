import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view_models/auth_controller.dart';
import 'package:food_delivery_app/models/app_user.dart';
import 'owner_apply_page.dart';
import 'forgot_password_page.dart';
class OwnerLoginPage extends ConsumerStatefulWidget {
  const OwnerLoginPage({super.key});

  @override
  ConsumerState<OwnerLoginPage> createState() => _OwnerLoginPageState();
}

class _OwnerLoginPageState extends ConsumerState<OwnerLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _keepSignedIn = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<AppUser?>>(
      authControllerProvider,
      (previous, next) {
        next.when(
          data: (user) {
            if (user == null || !context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
            // 1. Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD35400), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Main Card
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8E5).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD1CC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "PARTNER PORTAL",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFD35400),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),

                            Text(
                              "Welcome back,\nChef.",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF4A2C2A),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "Access your dashboard to manage orders, update your gallery, and review performance analytics.",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4A2C2A).withOpacity(0.7),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Email Field
                            _buildInputLabel("Business Email"),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: emailCtrl,
                              hint: "maitred@restaurant.com",
                              icon: Icons.email_outlined,
                              validator: (value) => (value == null || value.isEmpty) ? 'Please enter email' : null,
                            ),
                            const SizedBox(height: 25),

                            // Password Field
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInputLabel("Password"),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage()));
                                  },
                                  child: Text(
                                    "Forgot Password?",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFD35400),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: passCtrl,
                              hint: "••••••••",
                              icon: Icons.lock_outline,
                              obscureText: true,
                              validator: (value) => (value == null || value.length < 6) ? 'Password too short' : null,
                            ),
                            const SizedBox(height: 25),

                            // Keep me signed in
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => _keepSignedIn = !_keepSignedIn),
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _keepSignedIn ? const Color(0xFFD35400) : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                      color: _keepSignedIn ? const Color(0xFFD35400) : Colors.transparent,
                                    ),
                                    child: _keepSignedIn
                                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Keep me signed in",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF4A2C2A).withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            // Login Button
                            switch (authState) {
                              AsyncLoading() => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
                              _ => GestureDetector(
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      ref.read(authControllerProvider.notifier).login(
                                            emailCtrl.text.trim(),
                                            passCtrl.text.trim(),
                                            requiredRole: UserRole.owner,
                                          );
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 60,
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
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Access Gallery",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                            },

                            const SizedBox(height: 40),
                            const Divider(color: Color(0xFFFFD1CC)),
                            const SizedBox(height: 30),

                            // Apply Button
                            Center(
                              child: Text(
                                "Elevate your culinary reach.",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4A2C2A).withOpacity(0.6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerApplyPage()));
                              },
                              child: Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD1CC).withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text(
                                    "Apply to Partner with Us",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF4A2C2A),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF4A2C2A),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF4A2C2A),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: const Color(0xFF4A2C2A).withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
