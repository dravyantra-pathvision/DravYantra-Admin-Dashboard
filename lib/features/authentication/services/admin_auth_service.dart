// features/authentication/services/admin_auth_service.dart
// Handles Firebase sign-in and backend role verification.

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/auth_model.dart';

class AdminAuthService {
  AdminAuthService._();
  static final AdminAuthService instance = AdminAuthService._();

  final _firebaseAuth = FirebaseAuth.instance;

  /// Sign in with email/password via Firebase,
  /// then call /api/auth/login to get role from DB.
  /// Returns AdminUser if role == 'admin', throws otherwise.
  Future<AdminUser> signInWithEmail(String email, String password) async {
    // 1. Firebase Authentication
    UserCredential cred;
    try {
      cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      throw Exception('Firebase Auth Error: $e');
    }
    final firebaseUser = cred.user;
    if (firebaseUser == null) throw Exception('Firebase sign-in returned null user');

    // 2. Get Firebase ID token
    final idToken = await firebaseUser.getIdToken();

    // 3. Verify role with backend
    Map<String, dynamic> response;
    try {
      response = await ApiClient.instance.post(ApiEndpoints.login, {
        'idToken': idToken,
      });
    } catch (e) {
      throw Exception('Backend API Error: $e');
    }

    final backendToken = response['token'] as String?;
    if (backendToken == null) throw Exception('Backend did not return a session token.');

    final user = AdminUser.fromJson(response['user'] as Map<String, dynamic>);

    // 4. Persist custom backend token + role + user
    try {
      await Future.wait([
        SecureStorage.saveToken(backendToken),
        SecureStorage.saveRole(user.role),
        SecureStorage.saveUser(jsonEncode(user.toJson())),
      ]);
    } catch (e) {
      throw Exception('Secure Storage Error: $e');
    }

    return user;
  }

  /// Sign out from Firebase and clear local storage.
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      SecureStorage.clearAll(),
    ]);
  }

  /// Check if there's a valid admin session stored locally.
  Future<AdminUser?> getCurrentUser() async {
    final isValid = await SecureStorage.hasValidSession();
    if (!isValid) return null;
    final userJson = await SecureStorage.getUser();
    if (userJson == null) return null;
    try {
      return AdminUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }
}
