import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'auth/auth_wrapper.dart';

import 'admin/admin_dashboard.dart';
import 'customer/customer_home.dart';
import 'rider/rider_home.dart';

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
      home: const AuthWrapper(),
      routes: {
        '/admin': (_) => const AdminDashboard(),
        '/customer': (_) => const CustomerHome(),
        '/rider': (_) => const RiderHome(),
      },
    );
  }
}
