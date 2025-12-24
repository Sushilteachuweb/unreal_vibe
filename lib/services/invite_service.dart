import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_model.dart';
import 'user_storage.dart';

class InviteService {
  /// Generate a unique referral code for the user
  static Future<String> generateReferralCode() async {
    try {
      // Try to get existing referral code
      final existingCode = await UserStorage.getReferralCode();
      if (existingCode != null && existingCode.isNotEmpty) {
        return existingCode;
      }
      
      // Generate new referral code
      final user = await UserStorage.getUser();
      final userName = user?.name ?? 'USER';
      
      // Create code from first 3 letters of name + random numbers
      final namePrefix = userName.toUpperCase().replaceAll(' ', '').substring(0, min(3, userName.length));
      final random = Random();
      final numbers = random.nextInt(9999).toString().padLeft(4, '0');
      
      final referralCode = '$namePrefix$numbers';
      
      // Save the referral code
      await UserStorage.saveReferralCode(referralCode);
      
      return referralCode;
    } catch (e) {
      // Fallback: generate random code
      final random = Random();
      final code = 'UV${random.nextInt(999999).toString().padLeft(6, '0')}';
      await UserStorage.saveReferralCode(code);
      return code;
    }
  }
  
  /// Share app with referral code
  static Future<void> shareWithReferralCode(BuildContext context) async {
    try {
      final referralCode = await generateReferralCode();
      
      const String shareText = '''
🎉 Join me on Unreal Vibe and discover amazing events!

🎵 Find concerts, parties, workshops & more
🎫 Book tickets instantly with secure payments
🌟 Get personalized event recommendations
🎁 Use my referral code: [CODE] for special benefits!

Download Unreal Vibe now and let's explore events together!

#UnrealVibe #Events #Party #Music #Referral
      ''';
      
      final personalizedText = shareText.replaceAll('[CODE]', referralCode);
      
      await Share.share(
        personalizedText,
        subject: 'Join me on Unreal Vibe! 🎉',
      );
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Shared with your referral code: $referralCode',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Fallback to regular share
      await shareApp(context);
    }
  }
  
  /// Regular app share without referral
  static Future<void> shareApp(BuildContext context) async {
    const String shareText = '''
🎉 Hey! Check out Unreal Vibe - the best app to discover amazing events!

🎵 Find concerts, parties, workshops, and more
🎫 Book tickets instantly
🌟 Discover trending events near you
📍 Events in your city and beyond

Download now and never miss out on the fun!

#UnrealVibe #Events #Party #Music #Entertainment
    ''';
    
    try {
      await Share.share(
        shareText,
        subject: 'Discover Amazing Events with Unreal Vibe!',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Share specific event with friends
  static Future<void> shareEvent(
    BuildContext context, {
    required String eventTitle,
    required String eventDate,
    required String eventLocation,
    String? eventImage,
  }) async {
    try {
      final referralCode = await generateReferralCode();
      
      final String eventShareText = '''
🎉 Check out this amazing event I found on Unreal Vibe!

🎵 *$eventTitle*
📅 $eventDate
📍 $eventLocation

Join me at this event! Download Unreal Vibe with my referral code: $referralCode

#UnrealVibe #Events #$eventTitle
      ''';
      
      await Share.share(
        eventShareText,
        subject: 'Join me at $eventTitle!',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share event. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Get user's referral stats (placeholder for future API)
  static Future<Map<String, dynamic>> getReferralStats() async {
    // This would connect to an API in the future
    // For now, return mock data
    return {
      'referralCode': await generateReferralCode(),
      'friendsInvited': 0,
      'rewardsEarned': 0,
      'totalShares': await UserStorage.getShareCount() ?? 0,
    };
  }
  
  /// Track share action (for analytics)
  static Future<void> trackShare(String shareType) async {
    try {
      final currentCount = await UserStorage.getShareCount() ?? 0;
      await UserStorage.saveShareCount(currentCount + 1);
      
      // In the future, this could send analytics to a server
      debugPrint('📊 Share tracked: $shareType (Total: ${currentCount + 1})');
    } catch (e) {
      debugPrint('Failed to track share: $e');
    }
  }
  
  /// Show invite friends dialog with options
  static void showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Invite Friends',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Unreal Vibe with your friends and discover events together!',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            
            // Share with referral code
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  shareWithReferralCode(context);
                  trackShare('referral');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6958CA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.card_giftcard, size: 20),
                label: const Text('Share with Referral Code'),
              ),
            ),
            const SizedBox(height: 12),
            
            // Regular share
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  shareApp(context);
                  trackShare('general');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF6958CA)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.share, size: 20),
                label: const Text('Share App'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }
}