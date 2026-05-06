import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/core/theme.dart';
import '../view_models/auth_controller.dart';
import 'package:food_delivery_app/models/app_user.dart';

class CustomerSignupPage extends ConsumerStatefulWidget {
  const CustomerSignupPage({super.key});

  @override
  ConsumerState<CustomerSignupPage> createState() => _CustomerSignupPageState();
}

class _CustomerSignupPageState extends ConsumerState<CustomerSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
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
                const SizedBox(height: 10),
                Text(
                  "Create\nAccount",
                  style: textTheme.displayMedium?.copyWith(
                    fontSize: 48,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Join our community of gourmet food lovers.",
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppTheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Name Field
                Text(
                  "FULL NAME",
                  style: textTheme.labelLarge?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nameCtrl,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                  decoration: const InputDecoration(hintText: "Enter your name"),
                ),
                const SizedBox(height: 25),

                // Email Field
                Text(
                  "EMAIL ADDRESS",
                  style: textTheme.labelLarge?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailCtrl,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                  decoration: const InputDecoration(hintText: "Enter your email"),
                ),
                const SizedBox(height: 25),
                
                // Password Field
                Text(
                  "PASSWORD",
                  style: textTheme.labelLarge?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passCtrl,
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? "Min 6 characters" : null,
                  decoration: const InputDecoration(hintText: "••••••••"),
                ),
                const SizedBox(height: 25),

                // Confirm Password Field
                Text(
                  "CONFIRM PASSWORD",
                  style: textTheme.labelLarge?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: confirmPassCtrl,
                  obscureText: true,
                  validator: (v) => v != passCtrl.text ? "No match" : null,
                  decoration: const InputDecoration(hintText: "••••••••"),
                ),
                
                const SizedBox(height: 50),
                
                // Sign Up Button
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
                            ref.read(authControllerProvider.notifier).signUp(
                                  emailCtrl.text.trim(),
                                  passCtrl.text.trim(),
                                  UserRole.customer,
                                  extraData: {'name': nameCtrl.text.trim()},
                                );
                          }
                        },
                        child: const Text("CREATE ACCOUNT"),
                      ),
                    ),
                },
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
