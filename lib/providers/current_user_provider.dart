import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/firebase_providers.dart';

final currentUserIdProvider = Provider<String>((ref) {
  final user = ref.read(authProvider).currentUser;

  if (user == null) {
    throw Exception('User not logged in');
  }

  return user.uid;
});
