import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

/// Helper class to easily access user data throughout the app
class UserHelper {
  /// Get the current user (returns null if not logged in)
  static User? getCurrentUser(BuildContext context, {bool listen = false}) {
    return Provider.of<UserProvider>(context, listen: listen).user;
  }

  /// Check if user is logged in
  static bool isLoggedIn(BuildContext context, {bool listen = false}) {
    return Provider.of<UserProvider>(context, listen: listen).isLoggedIn;
  }

  /// Get user name (returns 'Guest' if not logged in)
  static String getUserName(BuildContext context, {bool listen = false}) {
    final user = getCurrentUser(context, listen: listen);
    return user?.name ?? 'Guest';
  }

  /// Get user email (returns empty string if not logged in)
  static String getUserEmail(BuildContext context, {bool listen = false}) {
    final user = getCurrentUser(context, listen: listen);
    return user?.email ?? '';
  }

  /// Get user city (returns empty string if not logged in)
  static String getUserCity(BuildContext context, {bool listen = false}) {
    final user = getCurrentUser(context, listen: listen);
    return user?.city ?? '';
  }

  /// Get user phone number (returns empty string if not logged in)
  static String getUserPhone(BuildContext context, {bool listen = false}) {
    final user = getCurrentUser(context, listen: listen);
    return user?.phoneNumber ?? '';
  }

  /// Get user initials for avatar
  static String getUserInitials(BuildContext context, {bool listen = false}) {
    final userName = getUserName(context, listen: listen);
    final parts = userName.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Update user data
  static Future<void> updateUser(
    BuildContext context,
    User updatedUser,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.updateUser(updatedUser);
  }

  /// Logout user
  static Future<void> logout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.logoutUser();
  }

  /// Show a confirmation dialog before logout
  static Future<bool> confirmLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
