import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../models/app_user.dart';
import '../services/widget_support.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  UserRole selectedRole = UserRole.customer;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<UserRole?>>(
      authControllerProvider,
      (previous, next) {
        next.when(
          data: (role) {
            if (role == null || !context.mounted) return;
            
            // ✅ FIX: Clear Stack
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Create Account", style: AppWidget.HeadlineTextField()),
              Text("Sign up to get started", style: AppWidget.SimpleTextField()),
              const SizedBox(height: 40),

              // Role Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<UserRole>(
                    value: selectedRole,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF8A00)),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Row(
                          children: [
                            Icon(
                              role == UserRole.admin
                                  ? Icons.admin_panel_settings
                                  : role == UserRole.rider
                                      ? Icons.delivery_dining
                                      : Icons.person,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 10),
                            Text(role.name.toUpperCase(), style: AppWidget.SemiBoldTextField()),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedRole = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: emailCtrl,
                validator: (v) => v!.isEmpty ? "Enter email" : null,
                decoration: AppWidget.inputDecoration("Email", Icons.email_outlined),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: passCtrl,
                obscureText: true,
                validator: (v) => v!.length < 6 ? "Password must be 6+ chars" : null,
                decoration: AppWidget.inputDecoration("Password", Icons.lock_outlined),
              ),
              const SizedBox(height: 40),

              switch (authState) {
                AsyncLoading() => const Center(child: CircularProgressIndicator(color: Color(0xFFFF8A00))),
                _ => SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8A00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ref.read(authControllerProvider.notifier).signUp(
                                emailCtrl.text.trim(),
                                passCtrl.text.trim(),
                                selectedRole,
                              );
                        }
                      },
                      child: const Text("SIGN UP",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
              },
            ],
          ),
        ),
      ),
    );
  }
}