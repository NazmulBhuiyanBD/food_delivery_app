import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/theme.dart';
import '../view_models/auth_controller.dart';
import 'package:food_delivery_app/models/app_user.dart';
import 'customer_signup_page.dart';
import 'forgot_password_page.dart';
class CustomerLoginPage extends ConsumerStatefulWidget {
  const CustomerLoginPage({super.key});

  @override
  ConsumerState<CustomerLoginPage> createState() => _CustomerLoginPageState();
}

class _CustomerLoginPageState extends ConsumerState<CustomerLoginPage> {
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Welcome\nBack",
                  style: textTheme.displayMedium?.copyWith(
                    fontSize: 48,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Sign in to continue your gourmet journey.",
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppTheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 60),
                
                // Email Field
                Text(
                  "EMAIL ADDRESS",
                  style: textTheme.labelLarge?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailCtrl,
                  validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                  decoration: const InputDecoration(
                    hintText: "Enter your email",
                  ),
                ),
                const SizedBox(height: 30),
                
                // Password Field
                Text(
                  "PASSWORD",
                  style: textTheme.labelLarge?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passCtrl,
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6) ? 'Min 6 characters' : null,
                  decoration: const InputDecoration(
                    hintText: "••••••••",
                  ),
                ),
                
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage()));
                    },
                    child: Text(
                      "Forgot Password?",
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Login Button
                switch (authState) {
                  AsyncLoading() => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                  _ => Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ref.read(authControllerProvider.notifier).login(
                                  emailCtrl.text.trim(),
                                  passCtrl.text.trim(),
                                );
                          }
                        },
                        child: const Text("LOGIN"),
                      ),
                    ),
                },
                
                const SizedBox(height: 30),
                
                // Signup Redirect
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerSignupPage()));
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "New here? ",
                        style: textTheme.bodyMedium?.copyWith(color: AppTheme.onSurface.withOpacity(0.6)),
                        children: const [
                          TextSpan(
                            text: "CREATE ACCOUNT",
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
