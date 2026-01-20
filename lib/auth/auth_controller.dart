import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firebase_providers.dart';
import '../models/app_user.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, UserRole?>(AuthController.new);

class AuthController extends AsyncNotifier<UserRole?> {
  @override
  Future<UserRole?> build() async {
    // Check if user is already logged in on app start
    final user = ref.read(authProvider).currentUser;
    if (user != null) {
      return await _fetchUserRole(user.uid);
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    // 1. Force Loading State (Clears previous errors/data)
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      // 2. Sign In
      final cred = await ref.read(authProvider).signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // 3. Fetch New Role
      return await _fetchUserRole(cred.user!.uid);
    });
  }

  Future<void> signUp(String email, String password, UserRole role) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final cred = await ref.read(authProvider).createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      final collection = role == UserRole.admin ? 'admins' : role == UserRole.rider ? 'riders' : 'customers';
      
      await ref.read(firestoreProvider).collection(collection).doc(cred.user!.uid).set({
        'email': email,
        'role': role.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return role;
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authProvider).signOut();
    // 4. Force State to Null (Logged Out)
    state = const AsyncData(null);
  }

  // Helper to get role
  Future<UserRole> _fetchUserRole(String uid) async {
    final db = ref.read(firestoreProvider);
    if ((await db.collection('customers').doc(uid).get()).exists) return UserRole.customer;
    if ((await db.collection('riders').doc(uid).get()).exists) return UserRole.rider;
    if ((await db.collection('admins').doc(uid).get()).exists) return UserRole.admin;
    throw Exception("User role not found in database");
  }
}