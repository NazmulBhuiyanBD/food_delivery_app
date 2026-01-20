import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../models/app_user.dart';
import '../services/widget_support.dart';
import 'signup_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Navigation Listener
    ref.listen<AsyncValue<UserRole?>>(
      authControllerProvider,
      (previous, next) {
        next.when(
          data: (role) {
            if (role == null || !context.mounted) return;
            
            // ✅ FIX: Clear stack so back button doesn't work and old state is wiped
            String route = '/';
            switch (role) {
              case UserRole.admin: route = '/admin'; break;
              case UserRole.customer: route = '/customer'; break;
              case UserRole.rider: route = '/rider'; break;
            }
            
            Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header Section
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF8A00), Color(0xFFFFB347)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fastfood, size: 80, color: Colors.white),
                  const SizedBox(height: 10),
                  Text("FoodDash", style: AppWidget.WhiteTextField().copyWith(fontSize: 30)),
                  Text("Deliver Favourite Food", style: AppWidget.WhiteTextField()),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Login Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text("Login to your account", style: AppWidget.HeadlineTextField()),
                    const SizedBox(height: 30),

                    TextFormField(
                      controller: emailCtrl,
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter email' : null,
                      decoration: AppWidget.inputDecoration("Email", Icons.email_outlined),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: passCtrl,
                      obscureText: true,
                      validator: (value) => (value == null || value.length < 6) ? 'Password too short' : null,
                      decoration: AppWidget.inputDecoration("Password", Icons.lock_outlined),
                    ),

                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text("Forgot Password?", style: AppWidget.SimpleTextField()),
                    ),
                    const SizedBox(height: 40),

                    // Login Button
                    switch (authState) {
                      AsyncLoading() => const CircularProgressIndicator(color: Color(0xFFFF8A00)),
                      _ => SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8A00),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 5,
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ref.read(authControllerProvider.notifier).login(
                                      emailCtrl.text.trim(),
                                      passCtrl.text.trim(),
                                    );
                              }
                            },
                            child: const Text("LOGIN",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    },

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        // Clear inputs before navigating
                        emailCtrl.clear();
                        passCtrl.clear();
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage()));
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                          children: [
                            TextSpan(
                              text: "Sign Up",
                              style: TextStyle(color: Color(0xFFFF8A00), fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
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
}