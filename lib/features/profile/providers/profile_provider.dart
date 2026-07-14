import 'package:flutter/material.dart';
import '../models/admin_profile_model.dart';
import '../services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  AdminProfile? _profile;
  List<AdminSession> _sessions = [];
  bool _isLoading = false;
  String? _error;

  AdminProfile? get profile => _profile;
  List<AdminSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileService.getProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileService.updateProfile(data);
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNotificationPreferences(Map<String, dynamic> data) async {
    try {
      await _profileService.updateNotificationPreferences(data);
      if (_profile != null) {
        _profile = AdminProfile(
          uid: _profile!.uid,
          email: _profile!.email,
          fullName: _profile!.fullName,
          role: _profile!.role,
          createdAt: _profile!.createdAt,
          phone: _profile!.phone,
          timezone: _profile!.timezone,
          employeeId: _profile!.employeeId,
          department: _profile!.department,
          languagePref: _profile!.languagePref,
          accountStatus: _profile!.accountStatus,
          profilePhoto: _profile!.profilePhoto,
          designation: _profile!.designation,
          notificationPreferences: data,
          lastLogin: _profile!.lastLogin,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      throw e;
    }
  }

  Future<void> changePassword(String newPassword, String confirmPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _profileService.changePassword(newPassword, confirmPassword);
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSessions() async {
    try {
      final allSessions = await _profileService.getSessions();
      _sessions = allSessions.where((s) => s.isActive).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> terminateSession(String sessionId) async {
    try {
      await _profileService.terminateSession(sessionId);
      await fetchSessions();
    } catch (e) {
      _error = e.toString();
      throw e;
    }
  }

  Future<void> uploadPhoto(List<int> bytes, String filename) async {
    try {
      final photoUrl = await _profileService.uploadPhoto(bytes, filename);
      if (_profile != null) {
        _profile = AdminProfile(
          uid: _profile!.uid,
          email: _profile!.email,
          fullName: _profile!.fullName,
          role: _profile!.role,
          createdAt: _profile!.createdAt,
          phone: _profile!.phone,
          timezone: _profile!.timezone,
          employeeId: _profile!.employeeId,
          department: _profile!.department,
          languagePref: _profile!.languagePref,
          accountStatus: _profile!.accountStatus,
          profilePhoto: photoUrl,
          designation: _profile!.designation,
          notificationPreferences: _profile!.notificationPreferences,
          lastLogin: _profile!.lastLogin,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      throw e;
    }
  }

  Future<void> removePhoto() async {
    try {
      await _profileService.removePhoto();
      if (_profile != null) {
        _profile = AdminProfile(
          uid: _profile!.uid,
          email: _profile!.email,
          fullName: _profile!.fullName,
          role: _profile!.role,
          createdAt: _profile!.createdAt,
          phone: _profile!.phone,
          timezone: _profile!.timezone,
          employeeId: _profile!.employeeId,
          department: _profile!.department,
          languagePref: _profile!.languagePref,
          accountStatus: _profile!.accountStatus,
          profilePhoto: null,
          designation: _profile!.designation,
          notificationPreferences: _profile!.notificationPreferences,
          lastLogin: _profile!.lastLogin,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      throw e;
    }
  }
}
