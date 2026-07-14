// features/authentication/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import '../models/auth_model.dart';
import '../services/admin_auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthState  _state = AuthState.initial;
  AdminUser? _user;
  String?    _error;

  AuthState  get state => _state;
  AdminUser? get user  => _user;
  String?    get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;

  // ── Init — called from router redirect ─────────────────────────────────────

  Future<void> initialize() async {
    _state = AuthState.loading;
    notifyListeners();
    try {
      final user = await AdminAuthService.instance.getCurrentUser();
      if (user != null) {
        _user  = user;
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (_) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();
    try {
      _user  = await AdminAuthService.instance.signInWithEmail(email, password);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await AdminAuthService.instance.signOut();
    _user  = null;
    _state = AuthState.unauthenticated;
    _error = null;
    notifyListeners();
  }
  // ── Forgot Password ────────────────────────────────────────────────────────
  
  Future<bool> sendPasswordReset(String email) async {
    _state = AuthState.loading;
    notifyListeners();
    try {
      await AdminAuthService.instance.sendPasswordResetEmail(email);
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }
}
