import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthService(this._auth, this._db);

  /// SIGN UP (Admin / Customer / Rider)
  Future<void> signUp({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: emailOrPhone,
      password: password,
    );

    final uid = userCredential.user!.uid;

    await _db.collection(_collection(role)).doc(uid).set({
      'role': role.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// LOGIN
  Future<UserRole> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: emailOrPhone,
      password: password,
    );

    final uid = credential.user!.uid;

    for (final role in UserRole.values) {
      final doc =
          await _db.collection(_collection(role)).doc(uid).get();
      if (doc.exists) return role;
    }

    throw Exception("Role not found");
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _collection(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admins';
      case UserRole.customer:
        return 'customers';
      case UserRole.rider:
        return 'riders';
    }
  }
}
