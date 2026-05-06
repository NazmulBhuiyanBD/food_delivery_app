import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view_models/auth_controller.dart';
import 'package:food_delivery_app/models/app_user.dart';
import '../../admin/views/admin_main_layout.dart';

class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final idCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    idCtrl.dispose();
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
            // Assuming role check happens in role_router, but since this is specifically admin login:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminMainLayout()));
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
            // Header
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
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    // Shield Icon
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          )
                        ],
                      ),
                      child: const Icon(Icons.admin_panel_settings, color: Color(0xFFD35400), size: 40),
                    ),
                    const SizedBox(height: 25),
                    
                    // Titles
                    Text(
                      "Admin Access",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A2C2A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Secure authorization required.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4A2C2A).withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ADMINISTRATOR ID",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A2C2A).withOpacity(0.5),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: idCtrl,
                            hint: "Enter your operational ID",
                            icon: Icons.badge_outlined,
                            isObscure: false,
                          ),
                          const SizedBox(height: 25),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "SECURITY KEY",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4A2C2A).withOpacity(0.5),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                "Recover Access",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFD35400),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: passCtrl,
                            hint: "••••••••••••",
                            icon: Icons.key_outlined,
                            isObscure: true,
                            suffixIcon: Icons.visibility_off_outlined,
                          ),
                          const SizedBox(height: 30),

                          // Two-Factor Info
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE8E5).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: const Color(0xFFFFD1CC)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.phonelink_lock, color: Color(0xFFD35400), size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Two-Factor Required",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF4A2C2A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "A secure token will be requested on the next step.",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF4A2C2A).withOpacity(0.6),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Submit Button
                          switch (authState) {
                            AsyncLoading() => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
                            _ => GestureDetector(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    ref.read(authControllerProvider.notifier).login(
                                          idCtrl.text.trim(),
                                          passCtrl.text.trim(),
                                          requiredRole: UserRole.admin,
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
                                        "Authenticate",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                          },
                          
                          const SizedBox(height: 50),
                          
                          // Footer
                          Center(
                            child: Text(
                              "NazEats Express Enterprise Infrastructure\nv. 4.2.1 • US-East Node",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4A2C2A).withOpacity(0.4),
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isObscure,
    IconData? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF4A2C2A),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFF4A2C2A).withOpacity(0.3), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFFD35400), size: 20),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: const Color(0xFF4A2C2A).withOpacity(0.4), size: 20) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFFE8E5), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFFE8E5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD35400), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
