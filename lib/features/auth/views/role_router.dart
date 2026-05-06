import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/auth_controller.dart';
import 'package:food_delivery_app/models/app_user.dart';

// Screens
import 'package:food_delivery_app/features/admin/views/admin_main_layout.dart';
import 'package:food_delivery_app/features/customer/views/customer_main_layout.dart';
import 'package:food_delivery_app/features/rider/views/rider_main_layout.dart';
import 'package:food_delivery_app/features/owner/views/owner_main_layout.dart';
import 'package:food_delivery_app/features/auth/views/administration_screen.dart';

class RoleRouter extends ConsumerWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      data: (appUser) {
        if (appUser == null) {
          return const SizedBox.shrink();
        }

        switch (appUser.role) {
          case UserRole.admin:
            return const AdministrationScreen();
          case UserRole.customer:
            return const CustomerMainLayout();
          case UserRole.rider:
            return const RiderMainLayout(); 
          case UserRole.owner:
            return const OwnerMainLayout();
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