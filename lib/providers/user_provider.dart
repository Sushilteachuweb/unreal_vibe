import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  UserProvider() {
    _loadUserData();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (_isLoggedIn) {
        final userJson = prefs.getString(_userKey);
        if (userJson != null) {
          _user = User.fromJson(json.decode(userJson));
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save user data and log in
  Future<void> loginUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(user.toJson()));
      await prefs.setBool(_isLoggedInKey, true);

      _user = user;
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving user data: $e');
      rethrow;
    }
  }

  // Update user data
  Future<void> updateUser(User updatedUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(updatedUser.toJson()));

      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user data: $e');
      rethrow;
    }
  }

  // Log out user
  Future<void> logoutUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);

      _user = null;
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error logging out: $e');
      rethrow;
    }
  }

  // Clear all user data
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _user = null;
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      rethrow;
    }
  }
}
