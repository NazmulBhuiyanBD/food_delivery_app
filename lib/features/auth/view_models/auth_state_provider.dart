import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authProvider).authStateChanges();
});
