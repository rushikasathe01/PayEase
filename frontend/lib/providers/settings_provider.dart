import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _appLockKey = 'app_lock_enabled';
  static const String _biometricKey = 'biometric_enabled';
  static const String _nameKey = 'profile_name';
  static const String _emailKey = 'profile_email';
  static const String _phoneKey = 'profile_phone';

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _appLockEnabled = false;
  bool _biometricEnabled = false;

  String _name = 'Rushika Sathe';
  String _email = 'rushika@example.com';
  String _phone = '+91 9876543210';

  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get appLockEnabled => _appLockEnabled;
  bool get biometricEnabled => _biometricEnabled;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final preferences = await SharedPreferences.getInstance();

    _notificationsEnabled = preferences.getBool(_notificationsKey) ?? true;

    _darkModeEnabled = preferences.getBool(_darkModeKey) ?? false;

    _appLockEnabled = preferences.getBool(_appLockKey) ?? false;

    _biometricEnabled = preferences.getBool(_biometricKey) ?? false;

    _name = preferences.getString(_nameKey) ?? 'Rushika Sathe';
    _email = preferences.getString(_emailKey) ?? 'rushika@example.com';
    _phone = preferences.getString(_phoneKey) ?? '+91 9876543210';

    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_notificationsKey, value);

    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _darkModeEnabled = value;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkModeKey, value);

    notifyListeners();
  }

  Future<void> toggleAppLock(bool value) async {
    _appLockEnabled = value;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_appLockKey, value);

    notifyListeners();
  }

  Future<void> toggleBiometric(bool value) async {
    _biometricEnabled = value;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_biometricKey, value);

    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    _name = name;
    _email = email;
    _phone = phone;

    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_nameKey, name);
    await preferences.setString(_emailKey, email);
    await preferences.setString(_phoneKey, phone);

    notifyListeners();
  }

  Future<void> resetSettings() async {
    _notificationsEnabled = true;
    _darkModeEnabled = false;
    _appLockEnabled = false;
    _biometricEnabled = false;

    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_notificationsKey, true);
    await preferences.setBool(_darkModeKey, false);
    await preferences.setBool(_appLockKey, false);
    await preferences.setBool(_biometricKey, false);

    notifyListeners();
  }
}
