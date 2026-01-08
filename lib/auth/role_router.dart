import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../models/app_user.dart';
import '../admin/admin_dashboard.dart';
import '../customer/customer_home.dart';
import '../rider/rider_home.dart';

class RoleRouter extends ConsumerWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRole = ref.watch(authControllerProvider);

    return authRole.when(
      data: (role) {
        if (role == null) {
          return const SizedBox.shrink();
        }

        switch (role) {
          case UserRole.admin:
            return const AdminDashboard();
          case UserRole.customer:
            return const CustomerHome();
          case UserRole.rider:
            return const RiderHome();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text(e.toString())),
      ),
    );
  }
}
