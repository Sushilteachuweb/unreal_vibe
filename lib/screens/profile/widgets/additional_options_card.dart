import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../services/invite_service.dart';
import '../saved_events_screen.dart';

class AdditionalOptionsCard extends StatelessWidget {
  const AdditionalOptionsCard({Key? key}) : super(key: key);

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
          _buildSettingsItem(Icons.bookmark, 'Saved Events', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SavedEventsScreen(),
              ),
            );
          }),
          _buildDivider(),
          _buildSettingsItem(Icons.share, 'Invite Friends', () => InviteService.showInviteDialog(context)),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF6366F1),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9CA3AF),
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

  void _inviteFriends(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildInviteBottomSheet(context),
    );
  }

  Widget _buildInviteBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          const Text(
            'Invite Friends to Unreal Vibe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          const Text(
            'Share the best events in your city with friends!',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Share options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(
                context,
                Icons.share,
                'Share App',
                'General',
                () => _shareApp(context),
              ),
              _buildShareOption(
                context,
                Icons.message,
                'WhatsApp',
                'Message',
                () => _shareViaWhatsApp(context),
              ),
              _buildShareOption(
                context,
                Icons.sms,
                'SMS',
                'Text',
                () => _shareViaSMS(context),
              ),
              _buildShareOption(
                context,
                Icons.email,
                'Email',
                'Email',
                () => _shareViaEmail(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A2A2A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF6958CA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6958CA),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    Navigator.pop(context);
    
    const String shareText = '''
🎉 Hey! Check out Unreal Vibe - the best app to discover amazing events in your city!

🎵 Find concerts, parties, workshops, and more
🎫 Book tickets instantly
🌟 Discover trending events near you

Download now and never miss out on the fun!

#UnrealVibe #Events #Party #Music #Fun
    ''';
    
    Share.share(
      shareText,
      subject: 'Join me on Unreal Vibe!',
    );
  }

  void _shareViaWhatsApp(BuildContext context) {
    Navigator.pop(context);
    
    const String whatsappText = '''
🎉 Hey! I found this amazing app called *Unreal Vibe* for discovering events!

🎵 *What you can do:*
• Find concerts, parties & workshops
• Book tickets instantly  
• Discover trending events nearby

Download it and let's explore events together! 🚀

#UnrealVibe #Events
    ''';
    
    Share.share(
      whatsappText,
      subject: 'Check out Unreal Vibe!',
    );
  }

  void _shareViaSMS(BuildContext context) {
    Navigator.pop(context);
    
    const String smsText = '''
Hey! Check out Unreal Vibe - the best app for discovering events in your city! 

Find concerts, parties, workshops and book tickets instantly. Download now and join the fun!

#UnrealVibe
    ''';
    
    Share.share(
      smsText,
      subject: 'Unreal Vibe App',
    );
  }

  void _shareViaEmail(BuildContext context) {
    Navigator.pop(context);
    
    const String emailText = '''
Hi there!

I wanted to share this amazing app I discovered called Unreal Vibe. It's the perfect platform for finding and booking events in your city.

Here's what makes it special:
🎵 Discover concerts, parties, workshops, and cultural events
🎫 Instant ticket booking with secure payments
🌟 Find trending events near your location
📱 Easy-to-use interface with real-time updates

Whether you're into music, comedy, workshops, or nightlife, Unreal Vibe has something for everyone. I think you'd really enjoy exploring events with this app!

Download Unreal Vibe and let's discover amazing events together!

Best regards!

#UnrealVibe #Events #Entertainment
    ''';
    
    Share.share(
      emailText,
      subject: 'Discover Amazing Events with Unreal Vibe!',
    );
  }
}
