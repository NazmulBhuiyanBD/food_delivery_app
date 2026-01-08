import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/firebase_providers.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authProvider).authStateChanges();
});
