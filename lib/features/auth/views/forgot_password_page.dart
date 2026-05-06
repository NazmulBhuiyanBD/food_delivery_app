import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/core/theme.dart';
import '../view_models/auth_controller.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).resetPassword(emailCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset email sent! Check your inbox."),
            backgroundColor: AppTheme.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                  "Reset\nPassword",
                  style: textTheme.displayMedium?.copyWith(
                    fontSize: 48,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Enter the email associated with your account and we'll send an email with instructions to reset your password.",
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
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || value.isEmpty || !value.contains('@')) ? 'Valid email required' : null,
                  decoration: const InputDecoration(
                    hintText: "Enter your email",
                  ),
                ),
                const SizedBox(height: 60),

                // Reset Button
                isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                    : Container(
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
                          onPressed: _resetPassword,
                          child: const Text("SEND RESET LINK"),
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
