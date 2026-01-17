import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserStorage {
  // Keys for storage
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _requestIdKey = 'request_id';
  static const String _accessTokenCookieKey = 'access_token_cookie';

  // Save user data
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Get user data
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Save auth token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save user ID
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Save request ID (for OTP)
  static Future<void> saveRequestId(String requestId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_requestIdKey, requestId);
  }

  // Get request ID
  static Future<String?> getRequestId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_requestIdKey);
  }

  // Save login status
  static Future<void> saveLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  // Get login status
  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Save access token cookie
  static Future<void> saveAccessTokenCookie(String cookie) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenCookieKey, cookie);
  }

  // Get access token cookie
  static Future<String?> getAccessTokenCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenCookieKey);
  }

  // Clear all data (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Clear specific keys
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Referral code storage
  static const String _referralCodeKey = 'referral_code';
  static const String _shareCountKey = 'share_count';

  static Future<void> saveReferralCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_referralCodeKey, code);
  }

  static Future<String?> getReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_referralCodeKey);
  }

  static Future<void> saveShareCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_shareCountKey, count);
  }

  static Future<int?> getShareCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_shareCountKey);
  }
}
