import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'auth/auth_wrapper.dart';
import 'admin/admin_dashboard.dart';
import 'customer/customer_main_layout.dart';
import 'rider/rider_main_layout.dart';

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
      theme: ThemeData(
        primaryColor: const Color(0xFFFF8A00),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      // 1. App Entry Point (Checks if logged in)
      home: const AuthWrapper(),
      
      // 2. Named Routes for Navigation
      routes: {
        '/admin': (_) => const AdminDashboard(),
        '/customer': (_) => const CustomerMainLayout(),
        '/rider': (_) => const RiderMainLayout(),
      },
    );
  }
}