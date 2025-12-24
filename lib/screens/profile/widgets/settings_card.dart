import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../edit_profile_screen.dart';
import '../notifications_screen.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            context,
            Icons.edit,
            'Edit Profile',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            ),
          ),
          _buildDivider(),
          _buildSettingsItem(
            context, 
            Icons.notifications, 
            'Notifications', 
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            ),
          ),
          _buildDivider(),
          _buildSettingsItem(
            context,
            Icons.logout,
            'Logout',
            () => _handleLogout(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE94B8B),
          ),
        ),
      );

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.logoutUser();

        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to login screen
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          
          // Log detailed error for developers
          debugPrint('🚨 [SettingsCard] Logout error: $e');
          
          // Show user-friendly error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logout failed. Please try again'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : const Color(0xFF6366F1),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? Colors.red : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDestructive ? Colors.red.withOpacity(0.5) : const Color(0xFF9CA3AF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFF2A2A2A),
    );
  }
}
