import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  await testNotificationsAPI();
}

Future<void> testNotificationsAPI() async {
  // Test the SSE endpoint (only one that exists)
  const String endpoint = "https://api.unrealvibe.com/api/sse/notifications";
  
  // You'll need to replace this with a valid bearer token
  const String bearerToken = "YOUR_BEARER_TOKEN_HERE";
  
  try {
    print('🔍 Testing SSE Notifications Endpoint...');
    print('📍 Endpoint: $endpoint');
    print('🔐 Using Bearer Token: ${bearerToken.substring(0, 20)}...');
    print('⚠️  Note: This is an SSE endpoint, may return connection info instead of notifications');
    
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      },
    ).timeout(const Duration(seconds: 10));

    print('\n📊 Response Details:');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');
    
    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        print('\n✅ API call successful!');
        print('📋 Parsed Response:');
        print('  - Success: ${data['success']}');
        print('  - Message: ${data['message']}');
        print('  - Data keys: ${data.keys.toList()}');
        
        // Check different possible array keys
        final notifications = data['notifications'] as List? ?? 
                             data['data'] as List? ?? 
                             [];
        
        print('  - Notifications count: ${notifications.length}');
        print('  - Total count: ${data['totalCount'] ?? 'N/A'}');
        print('  - Unread count: ${data['unreadCount'] ?? 'N/A'}');
        
        if (notifications.isNotEmpty) {
          print('\n🔔 First Notification Details:');
          final firstNotification = notifications[0] as Map<String, dynamic>;
          print('  - Keys: ${firstNotification.keys.toList()}');
          print('  - Sample data: $firstNotification');
        }
        
        // Test the model parsing
        print('\n🧪 Testing Model Parsing:');
        try {
          final testNotifications = notifications.map((notificationJson) {
            final notification = notificationJson as Map<String, dynamic>;
            return {
              'id': notification['_id'] ?? notification['id'] ?? 'unknown',
              'title': notification['title'] ?? 'Unknown Title',
              'message': notification['message'] ?? notification['body'] ?? 'No message',
              'type': notification['type'] ?? 'general',
              'isRead': notification['isRead'] ?? notification['read'] ?? false,
              'createdAt': notification['createdAt'] ?? notification['timestamp'],
            };
          }).toList();
          
          print('✅ Model parsing would succeed with ${testNotifications.length} notifications');
          for (var notification in testNotifications.take(3)) {
            print('  - ${notification['title']} (${notification['type']}) - Read: ${notification['isRead']}');
          }
        } catch (e) {
          print('❌ Model parsing would fail: $e');
        }
        
      } catch (e) {
        print('❌ JSON parsing failed: $e');
        print('Raw response: ${response.body}');
      }
    } else {
      print('❌ API call failed with status: ${response.statusCode}');
      if (response.statusCode == 401) {
        print('🔐 Authentication failed - check your bearer token');
      } else if (response.statusCode == 404) {
        print('🔍 Endpoint not found - check the URL');
      }
    }
  } catch (e) {
    print('❌ Network Error: $e');
  }
}