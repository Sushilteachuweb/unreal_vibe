import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../services/invite_service.dart';
import '../../../services/user_storage.dart';
import '../../../services/api_routes.dart';
import '../../../services/event_service.dart';
import '../saved_events_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
          _buildDivider(),
          _buildSettingsItem(Icons.bug_report, 'Debug Auth & Saved Events', () => _debugAuthAndSavedEvents(context)),
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

  // Debug function to test authentication and saved events
  Future<void> _debugAuthAndSavedEvents(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF6366F1)),
            SizedBox(height: 16),
            Text(
              'Running debug tests...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    List<String> debugResults = [];
    
    try {
      // Check authentication state
      debugResults.add('🔐 AUTHENTICATION CHECK');
      debugResults.add('========================');
      
      final token = await UserStorage.getToken();
      final isLoggedIn = await UserStorage.getLoginStatus();
      
      debugResults.add('🔑 Token exists: ${token != null}');
      debugResults.add('🔑 Is logged in: $isLoggedIn');
      
      if (token != null && token.isNotEmpty) {
        debugResults.add('🔑 Token preview: ${token.substring(0, 30)}...');
        debugResults.add('🔑 Token length: ${token.length}');
        
        // Test different API endpoints
        debugResults.add('\n📍 API ENDPOINT TESTS');
        debugResults.add('====================');
        
        // First test the working save event API for comparison
        debugResults.add('\n🧪 Testing Save Event (Known Working):');
        try {
          final saveUrl = 'https://api.unrealvibe.com/api/event/69621f0b601145b4cb10676b/save';
          final saveHeaders = await ApiConfig.getAuthHeadersWithCookies(token);
          final saveResponse = await http.post(
            Uri.parse(saveUrl),
            headers: saveHeaders,
          ).timeout(const Duration(seconds: 10));
          
          debugResults.add('📊 Save Event Status: ${saveResponse.statusCode}');
          if (saveResponse.statusCode == 200) {
            debugResults.add('✅ Save event works with current auth method');
          } else {
            debugResults.add('❌ Save event failed - auth issue?');
          }
        } catch (e) {
          debugResults.add('❌ Save event error: $e');
        }
        
        // Now test saved events with different auth methods
        debugResults.add('\n🔍 Testing Saved Events with Different Auth Methods:');
        
        // Method 1: Bearer + Cookie (current)
        debugResults.add('\n1️⃣ Bearer + Cookie (Current Method):');
        try {
          final headers1 = await ApiConfig.getAuthHeadersWithCookies(token);
          final response1 = await http.get(
            Uri.parse('https://api.unrealvibe.com/api/event/saved-events'),
            headers: headers1,
          ).timeout(const Duration(seconds: 10));
          
          debugResults.add('📊 Status: ${response1.statusCode}');
          debugResults.add('📊 Response: ${response1.body}');
          
          if (response1.statusCode == 500 && response1.body.contains('computeEventExtras')) {
            debugResults.add('🐛 Server bug confirmed with Bearer+Cookie');
          }
        } catch (e) {
          debugResults.add('❌ Bearer+Cookie error: $e');
        }
        
        // Method 2: Bearer only (old method)
        debugResults.add('\n2️⃣ Bearer Only (Old Method):');
        try {
          final headers2 = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          };
          final response2 = await http.get(
            Uri.parse('https://api.unrealvibe.com/api/event/saved-events'),
            headers: headers2,
          ).timeout(const Duration(seconds: 10));
          
          debugResults.add('📊 Status: ${response2.statusCode}');
          debugResults.add('📊 Response: ${response2.body}');
          
          if (response2.statusCode == 500 && response2.body.contains('computeEventExtras')) {
            debugResults.add('🐛 Same server bug with Bearer only');
          }
        } catch (e) {
          debugResults.add('❌ Bearer only error: $e');
        }
        
        // Method 3: Cookie only
        debugResults.add('\n3️⃣ Cookie Only:');
        try {
          final headers3 = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cookie': 'accessToken=$token',
          };
          final response3 = await http.get(
            Uri.parse('https://api.unrealvibe.com/api/event/saved-events'),
            headers: headers3,
          ).timeout(const Duration(seconds: 10));
          
          debugResults.add('📊 Status: ${response3.statusCode}');
          debugResults.add('📊 Response: ${response3.body}');
          
          if (response3.statusCode == 500 && response3.body.contains('computeEventExtras')) {
            debugResults.add('🐛 Same server bug with Cookie only');
          }
        } catch (e) {
          debugResults.add('❌ Cookie only error: $e');
        }
        
        // Test other working endpoints for comparison
        final testEndpoints = [
          {'name': 'My Passes', 'url': 'https://api.unrealvibe.com/api/passes/my-passes'},
          {'name': 'Regular Events', 'url': 'https://api.unrealvibe.com/api/event/events'},
        ];
        
        for (final endpoint in testEndpoints) {
          try {
            debugResults.add('\n📍 Testing: ${endpoint['name']}');
            
            final authHeaders = await ApiConfig.getAuthHeadersWithCookies(token);
            final response = await http.get(
              Uri.parse(endpoint['url']!),
              headers: authHeaders,
            ).timeout(const Duration(seconds: 10));
            
            debugResults.add('📊 Status: ${response.statusCode}');
            
            if (response.statusCode == 200) {
              debugResults.add('✅ ${endpoint['name']} works with current auth');
              try {
                final data = json.decode(response.body);
                if (endpoint['name'] == 'Regular Events' && data['events'] != null) {
                  final events = data['events'] as List? ?? [];
                  debugResults.add('📋 Events count: ${events.length}');
                } else if (endpoint['name'] == 'My Passes' && data['passes'] != null) {
                  final passes = data['passes'] as List? ?? [];
                  debugResults.add('📋 Passes count: ${passes.length}');
                }
              } catch (e) {
                debugResults.add('⚠️ JSON parsing error: $e');
              }
            } else if (response.statusCode == 401) {
              debugResults.add('❌ 401 Unauthorized');
              if (response.body.contains('Invalid or expired token')) {
                debugResults.add('💡 Token expired - need to log in again');
              } else {
                debugResults.add('💡 Authentication failed');
              }
            } else {
              debugResults.add('❌ HTTP ${response.statusCode}');
              debugResults.add('📋 Response: ${response.body}');
            }
          } catch (e) {
            debugResults.add('❌ Network error: $e');
          }
        }
        
        // Test EventService directly
        debugResults.add('\n🧪 EVENT SERVICE TEST');
        debugResults.add('====================');
        
        try {
          final savedEvents = await EventService.fetchSavedEvents(forceRefresh: true);
          debugResults.add('✅ EventService.fetchSavedEvents() success');
          debugResults.add('📋 Returned ${savedEvents.length} saved events');
        } catch (e) {
          debugResults.add('❌ EventService.fetchSavedEvents() failed: $e');
        }
        
      } else {
        debugResults.add('❌ No token found - user not logged in');
      }
      
      debugResults.add('\n💡 ANALYSIS & RECOMMENDATIONS');
      debugResults.add('================================');
      if (token == null) {
        debugResults.add('1. User needs to log in');
      } else {
        debugResults.add('🔍 Authentication Method Analysis:');
        debugResults.add('- If ALL auth methods return same 500 error: SERVER BUG');
        debugResults.add('- If some methods work, others fail: AUTH METHOD ISSUE');
        debugResults.add('- If save works but fetch fails: ENDPOINT-SPECIFIC BUG');
        debugResults.add('');
        debugResults.add('💡 Next Steps:');
        debugResults.add('1. If seeing 401 errors: Log out and log back in');
        debugResults.add('2. If no saved events: Save an event first');
        debugResults.add('3. If 500 errors: Contact backend team about server bug');
        debugResults.add('4. Pull down to refresh in Saved Events screen');
      }
      
    } catch (e) {
      debugResults.add('❌ Debug test failed: $e');
    }
    
    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
      
      // Show results dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Debug Results',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Text(
                debugResults.join('\n'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF6366F1)),
              ),
            ),
          ],
        ),
      );
    }
  }
}
