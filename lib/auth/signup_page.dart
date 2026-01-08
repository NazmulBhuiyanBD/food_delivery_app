import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../models/app_user.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
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

    // ✅ Navigation as side-effect
    ref.listen<AsyncValue<UserRole?>>(
      authControllerProvider,
      (previous, next) {
        next.when(
          data: (role) {
            if (role == null) return;
            if (!context.mounted) return;

            switch (role) {
              case UserRole.admin:
                Navigator.pushReplacementNamed(context, '/admin');
                break;
              case UserRole.customer:
                Navigator.pushReplacementNamed(context, '/customer');
                break;
              case UserRole.rider:
                Navigator.pushReplacementNamed(context, '/rider');
                break;
            }
          },
          loading: () {},
          error: (_, __) {},
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔽 Role selector
            DropdownButtonFormField<UserRole>(
              value: selectedRole,
              decoration: const InputDecoration(labelText: 'Select Role'),
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedRole = value!);
              },
            ),
            const SizedBox(height: 12),

            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),

            // ✅ Async UI (official Riverpod style)
            switch (authState) {
              AsyncLoading() =>
                const CircularProgressIndicator(),

              AsyncError(:final error) =>
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),

              _ => ElevatedButton(
                onPressed: () {
                  ref
                      .read(authControllerProvider.notifier)
                      .signUp(
                        emailCtrl.text.trim(),
                        passCtrl.text.trim(),
                        selectedRole,
                      );
                },
                child: const Text('Create Account'),
              ),
            },

            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
