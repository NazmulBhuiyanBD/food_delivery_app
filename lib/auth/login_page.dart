import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../models/app_user.dart';
import 'signup_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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

    // ✅ navigation side-effect
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
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

            // ✅ async UI
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
                        .login(
                          emailCtrl.text.trim(),
                          passCtrl.text.trim(),
                        );
                  },
                  child: const Text('Login'),
                ),
            },

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignupPage(),
                  ),
                );
              },
              child: const Text('Create new account'),
            ),
          ],
        ),
      ),
    );
  }
}
