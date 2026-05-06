import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/theme.dart';
import '../view_models/auth_controller.dart';
import 'package:food_delivery_app/models/app_user.dart';
import 'rider_apply_page.dart';
import 'forgot_password_page.dart';
class RiderLoginPage extends ConsumerStatefulWidget {
  const RiderLoginPage({super.key});

  @override
  ConsumerState<RiderLoginPage> createState() => _RiderLoginPageState();
}

class _RiderLoginPageState extends ConsumerState<RiderLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final textTheme = Theme.of(context).textTheme;

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
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: AppTheme.tertiary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );

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
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        
                        // 2. Rider Icon & Title
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8E5),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.delivery_dining_rounded,
                            size: 40,
                            color: Color(0xFFD35400),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "Rider Portal",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4A2C2A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sign in to manage deliveries and earnings.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4A2C2A).withOpacity(0.6),
                          ),
                        ),
                        
                        const SizedBox(height: 50),

                        // 3. Login Card
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "EMAIL ADDRESS",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4A2C2A).withOpacity(0.5),
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: emailCtrl,
                                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFD35400), size: 20),
                                  hintText: "rider@example.com",
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                                  filled: true,
                                  fillColor: const Color(0xFFFFE8E5).withOpacity(0.3),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 25),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "PASSWORD",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF4A2C2A).withOpacity(0.5),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage()));
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFD35400),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: passCtrl,
                                obscureText: _obscureText,
                                validator: (value) => (value == null || value.length < 6) ? 'Min 6 characters' : null,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFD35400), size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey.shade400, size: 20),
                                    onPressed: () => setState(() => _obscureText = !_obscureText),
                                  ),
                                  hintText: "••••••••",
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                                  filled: true,
                                  fillColor: const Color(0xFFFFE8E5).withOpacity(0.3),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 40),

                              // Sign In Button
                              switch (authState) {
                                AsyncLoading() => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
                                _ => GestureDetector(
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        ref.read(authControllerProvider.notifier).login(
                                              emailCtrl.text.trim(),
                                              passCtrl.text.trim(),
                                              requiredRole: UserRole.rider,
                                            );
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 62,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFD35400), Color(0xFFE67E22)],
                                        ),
                                        borderRadius: BorderRadius.circular(31),
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
                                            "Sign In",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                              },
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                        
                        // OR Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: const Color(0xFF4A2C2A).withOpacity(0.1))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "OR",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4A2C2A).withOpacity(0.3),
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: const Color(0xFF4A2C2A).withOpacity(0.1))),
                          ],
                        ),

                        const SizedBox(height: 40),
                        
                        Text(
                          "Want to deliver with us?",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A2C2A).withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Apply Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const RiderApplyPage()));
                          },
                          child: Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD1CC).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.delivery_dining_rounded, color: Color(0xFFD35400), size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  "Apply to be a Rider",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFD35400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

