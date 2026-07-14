// core/storage/secure_storage.dart
// Manages JWT token persistence using shared_preferences (web-safe).

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants.dart';

class SecureStorage {
  SecureStorage._();

  // In-memory cache for web fallback
  static String? _memToken;
  static String? _memRole;
  static String? _memUser;

  // ── Token ────────────────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    _memToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
    } catch (e) {
      if (kDebugMode) debugPrint('SecureStorage saveToken Error: storage failure');
    }
  }

  static Future<String?> getToken() async {
    if (_memToken != null) return _memToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      _memToken = prefs.getString(AppConstants.tokenKey);
      return _memToken;
    } catch (e) {
      if (kDebugMode) debugPrint('SecureStorage getToken Error: storage failure');
      return null;
    }
  }

  static Future<void> deleteToken() async {
    _memToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
    } catch (_) {}
  }

  // ── Role ─────────────────────────────────────────────────────────────────────

  static Future<void> saveRole(String role) async {
    _memRole = role;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.roleKey, role);
    } catch (_) {}
  }

  static Future<String?> getRole() async {
    if (_memRole != null) return _memRole;
    try {
      final prefs = await SharedPreferences.getInstance();
      _memRole = prefs.getString(AppConstants.roleKey);
      return _memRole;
    } catch (_) {
      return null;
    }
  }

  // ── User JSON ────────────────────────────────────────────────────────────────

  static Future<void> saveUser(String userJson) async {
    _memUser = userJson;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, userJson);
    } catch (_) {}
  }

  static Future<String?> getUser() async {
    if (_memUser != null) return _memUser;
    try {
      final prefs = await SharedPreferences.getInstance();
      _memUser = prefs.getString(AppConstants.userKey);
      return _memUser;
    } catch (_) {
      return null;
    }
  }

  // ── Clear All ────────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    _memToken = null;
    _memRole = null;
    _memUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.roleKey);
      await prefs.remove(AppConstants.userKey);
    } catch (_) {}
  }

  // ── Session Check ─────────────────────────────────────────────────────────────

  static Future<bool> hasValidSession() async {
    final token = await getToken();
    final role  = await getRole();
    return token != null && role == 'admin';
  }
}
