import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_storage.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _authToken;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get authToken => _authToken;

  UserProvider() {
    _loadUserData();
  }

  // Load user data from storage
  Future<void> _loadUserData() async {
    try {
      _isLoggedIn = await UserStorage.getLoginStatus();
      _authToken = await UserStorage.getToken();

      if (_isLoggedIn) {
        _user = await UserStorage.getUser();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request OTP
  Future<Map<String, dynamic>> requestOtp(String phoneNumber) async {
    return await AuthService.requestOtp(phoneNumber);
  }

  // Verify OTP and login
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final result = await AuthService.verifyOtp(phoneNumber, otp);
      
      if (result['success']) {
        // Update provider state
        _authToken = result['token'];
        _isLoggedIn = true;
        
        // Fetch user profile after successful login
        if (result['isProfileComplete'] == true) {
          await fetchProfile();
        }
        
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // Create Profile
  Future<Map<String, dynamic>> createProfile({
    required String name,
    required String email,
    required String city,
    required String gender,
  }) async {
    try {
      final result = await ProfileService.createProfile(
        name: name,
        email: email,
        city: city,
        gender: gender,
      );
      
      if (result['success']) {
        // Update provider state with new user data
        if (result['user'] != null) {
          _user = User.fromJson(result['user']);
          notifyListeners();
        }
      }
      
      return result;
    } catch (e) {
      debugPrint('Error creating profile: $e');
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // Complete Profile (with documents and profile photo)
  Future<Map<String, dynamic>> completeProfile({
    required String name,
    required String email,
    required String city,
    required String gender,
    dynamic aadhaar,
    dynamic drivingLicense,
    dynamic pan,
    dynamic profilePhoto,
  }) async {
    try {
      final result = await ProfileService.completeProfile(
        name: name,
        email: email,
        city: city,
        gender: gender,
        aadhaar: aadhaar,
        drivingLicense: drivingLicense,
        pan: pan,
        profilePhoto: profilePhoto,
      );
      
      if (result['success']) {
        // Update provider state with new user data
        if (result['user'] != null) {
          _user = User.fromJson(result['user']);
          notifyListeners();
        }
      }
      
      return result;
    } catch (e) {
      debugPrint('Error completing profile: $e');
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // Get Profile
  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final result = await ProfileService.getProfile();
      
      if (result['success']) {
        // Update provider state with fetched user data
        if (result['user'] != null) {
          _user = User.fromJson(result['user']);
          notifyListeners();
        }
      }
      
      return result;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    await fetchProfile();
  }

  // Save user data and log in
  Future<void> loginUser(User user, {String? token}) async {
    try {
      await UserStorage.saveUser(user);
      await UserStorage.saveLoginStatus(true);
      
      if (token != null) {
        await UserStorage.saveToken(token);
        _authToken = token;
      }

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
      await UserStorage.saveUser(updatedUser);
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
      await AuthService.logout();
      
      _user = null;
      _isLoggedIn = false;
      _authToken = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error logging out: $e');
      rethrow;
    }
  }

  // Clear all user data
  Future<void> clearUserData() async {
    try {
      await UserStorage.clearAll();
      _user = null;
      _isLoggedIn = false;
      _authToken = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      rethrow;
    }
  }
}
