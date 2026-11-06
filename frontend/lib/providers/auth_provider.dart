import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const String _tokenKey = 'payease_jwt_token';
  static const String _nameKey = 'payease_user_name';
  static const String _emailKey = 'payease_user_email';
  static const String _userIdKey = 'payease_user_id';

  String? _token;
  String? _name;
  String? _email;
  String? _userId;

  bool _isLoggedIn = false;
  bool _isLoading = false;

  // ============================================================
  // GETTERS
  // ============================================================

  String? get token => _token;

  String? get name => _name;

  String? get email => _email;

  String? get userId => _userId;

  bool get isLoggedInValue => _isLoggedIn;

  bool get isLoading => _isLoading;

  // ============================================================
  // SIGNUP
  // ============================================================

  Future<String> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.signup(
        name: name,
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();

      if (response['success'] == true) {
        return 'success';
      }

      return response['message'] ?? 'Signup failed';
    } catch (error) {
      _isLoading = false;
      notifyListeners();

      return _cleanError(error);
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.login(
        email: email.trim(),
        password: password,
      );

      if (response['success'] != true) {
        _isLoading = false;
        notifyListeners();

        return response['message'] ?? 'Login failed';
      }

      final token = response['token'];

      final user = response['user'];

      if (token == null || user == null) {
        _isLoading = false;
        notifyListeners();

        return 'Invalid login response from server';
      }

      _token = token.toString();

      _name = user['name']?.toString() ?? 'User';

      _email = user['email']?.toString() ?? email;

      _userId = user['id']?.toString();

      final preferences =
          await SharedPreferences.getInstance();

      await preferences.setString(
        _tokenKey,
        _token!,
      );

      await preferences.setString(
        _nameKey,
        _name!,
      );

      await preferences.setString(
        _emailKey,
        _email!,
      );

      if (_userId != null) {
        await preferences.setString(
          _userIdKey,
          _userId!,
        );
      }

      _isLoggedIn = true;

      _isLoading = false;

      notifyListeners();

      return 'success';
    } catch (error) {
      _isLoading = false;
      notifyListeners();

      return _cleanError(error);
    }
  }

  // ============================================================
  // RESTORE LOGIN AFTER APP RESTART
  // ============================================================

  Future<bool> restoreSession() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final savedToken =
          preferences.getString(_tokenKey);

      if (savedToken == null ||
          savedToken.isEmpty) {
        _isLoggedIn = false;
        return false;
      }

      final response =
          await ApiService.getMe(savedToken);

      if (response['success'] != true) {
        await _clearSession();

        return false;
      }

      final user = response['user'];

      _token = savedToken;

      _name = user['name']?.toString() ?? 'User';

      _email = user['email']?.toString();

      _userId = user['id']?.toString();

      _isLoggedIn = true;

      notifyListeners();

      return true;
    } catch (error) {
      await _clearSession();

      return false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _clearSession();

    notifyListeners();
  }

  // ============================================================
  // CLEAR SESSION
  // ============================================================

  Future<void> _clearSession() async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.remove(_tokenKey);
    await preferences.remove(_nameKey);
    await preferences.remove(_emailKey);
    await preferences.remove(_userIdKey);

    _token = null;
    _name = null;
    _email = null;
    _userId = null;

    _isLoggedIn = false;
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================

  Future<bool> isLoggedIn() async {
    if (_isLoggedIn && _token != null) {
      return true;
    }

    return await restoreSession();
  }

  // ============================================================
  // CHECK ACCOUNT
  // ============================================================

  Future<bool> hasAccount() async {
    final preferences =
        await SharedPreferences.getInstance();

    final token =
        preferences.getString(_tokenKey);

    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // GET USER NAME
  // ============================================================

  Future<String> getUserName() async {
    if (_name != null && _name!.isNotEmpty) {
      return _name!;
    }

    final preferences =
        await SharedPreferences.getInstance();

    return preferences.getString(_nameKey) ?? 'User';
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    // Password reset API has not been added
    // to the backend yet.
    //
    // Do not change the local password anymore.
    //
    // We will implement this properly through
    // the backend later.

    return false;
  }

  // ============================================================
  // ERROR CLEANER
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }
}