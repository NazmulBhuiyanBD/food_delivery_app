import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/models/app_user.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    // Check if user is already logged in on app start
    final user = ref.read(authProvider).currentUser;
    if (user != null) {
      try {
        final appUser = await _fetchAppUser(user.uid);
        if (appUser.status != UserStatus.approved) {
          await ref.read(authProvider).signOut();
          return null;
        }
        return appUser;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> login(String email, String password, {UserRole? requiredRole}) async {
    // 1. Force Loading State (Clears previous errors/data)
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      // 2. Sign In
      final cred = await ref.read(authProvider).signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // 3. Fetch AppUser
      final appUser = await _fetchAppUser(cred.user!.uid);
      
      if (appUser.status == UserStatus.pending) {
        await ref.read(authProvider).signOut();
        throw Exception("Your application is under review");
      }
      
      if (appUser.status == UserStatus.rejected) {
        await ref.read(authProvider).signOut();
        throw Exception("Your application has been rejected");
      }

      // Role Validation
      if (requiredRole != null && appUser.role != requiredRole) {
        await ref.read(authProvider).signOut();
        throw Exception("Unauthorized: You do not have the ${requiredRole.name} role.");
      }

      return appUser;
    });
  }

  Future<void> signUp(String email, String password, UserRole role, {Map<String, dynamic>? extraData}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final cred = await ref.read(authProvider).createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      final collection = role == UserRole.admin 
          ? 'admins' 
          : role == UserRole.rider 
            ? 'riders' 
            : role == UserRole.owner 
              ? 'owners' 
              : 'customers';
              
      final initialStatus = (role == UserRole.rider || role == UserRole.owner) 
          ? UserStatus.pending 
          : UserStatus.approved;
      
      final Map<String, dynamic> baseData = {
        'email': email,
        'role': role.name,
        'status': initialStatus.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      if (extraData != null) {
        baseData.addAll(extraData);
      }
      
      await ref.read(firestoreProvider).collection(collection).doc(cred.user!.uid).set(baseData);
      
      final newUser = AppUser(uid: cred.user!.uid, role: role, status: initialStatus);
      
      if (initialStatus != UserStatus.approved) {
        await ref.read(authProvider).signOut();
      }
      
      return newUser;
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authProvider).signOut();
    // 4. Force State to Null (Logged Out)
    state = const AsyncData(null);
  }

  Future<void> resetPassword(String email) async {
    try {
      await ref.read(authProvider).sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception("Failed to send reset email: ${e.toString()}");
    }
  }

  // Helper to get user
  Future<AppUser> _fetchAppUser(String uid) async {
    final db = ref.read(firestoreProvider);
    
    var doc = await db.collection('customers').doc(uid).get();
    if (doc.exists) return AppUser.fromMap(uid, doc.data()!);

    doc = await db.collection('riders').doc(uid).get();
    if (doc.exists) return AppUser.fromMap(uid, doc.data()!);
    
    doc = await db.collection('owners').doc(uid).get();
    if (doc.exists) return AppUser.fromMap(uid, doc.data()!);

    doc = await db.collection('admins').doc(uid).get();
    if (doc.exists) return AppUser.fromMap(uid, doc.data()!);

    throw Exception("User not found in database");
  }
}