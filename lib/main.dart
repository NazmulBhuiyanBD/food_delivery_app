import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'features/auth/views/administration_screen.dart';
import 'features/admin/views/admin_main_layout.dart';
import 'features/customer/views/customer_main_layout.dart';
import 'features/rider/views/rider_main_layout.dart';
import 'features/auth/views/loading_screen.dart';

import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Delivery App',
      theme: AppTheme.lightTheme,
      // 1. App Entry Point (Loading Screen -> AuthWrapper)
      home: const LoadingScreen(),
      
      // 2. Named Routes for Navigation
      routes: {
        '/admin': (_) => const AdministrationScreen(),
        '/admin_dashboard': (_) => const AdminMainLayout(),
        '/customer': (_) => const CustomerMainLayout(),
        '/rider': (_) => const RiderMainLayout(),
      },
    );
  }
}