import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🔔 Testing Complete Notification API Integration\n');
  
  // Replace with your actual bearer token
  const String bearerToken = "YOUR_BEARER_TOKEN_HERE";
  
  await testNotificationAPIs(bearerToken);
}

Future<void> testNotificationAPIs(String token) async {
  print('=' * 60);
  print('NOTIFICATION API TESTS');
  print('=' * 60);
  
  // Test 1: Fetch Notifications
  await testFetchNotifications(token);
  
  // Test 2: Get Notification Count
  await testGetCount(token);
  
  // Test 3: Mark Notifications as Read
  await testMarkAsRead(token);
  
  // Test 4: Delete Notification
  await testDeleteNotification(token);
  
  // Test 5: SSE Connection
  await testSSEConnection(token);
  
  print('\n' + '=' * 60);
  print('ALL TESTS COMPLETED');
  print('=' * 60);
}

Future<void> testFetchNotifications(String token) async {
  print('\n📋 TEST 1: Fetch Notifications');
  print('-' * 60);
  
  const String endpoint = "https://api.unrealvibe.com/api/notifications";
  
  try {
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print('✅ Success: ${data['success']}');
      print('📊 Total: ${data['total'] ?? 0}');
      print('📬 Notifications: ${(data['notifications'] as List?)?.length ?? 0}');
      print('📄 Page: ${data['page'] ?? 1}');
      print('📏 Limit: ${data['limit'] ?? 20}');
      
      if (data['notifications'] != null && (data['notifications'] as List).isNotEmpty) {
        print('\n📝 Sample Notification:');
        final firstNotif = data['notifications'][0];
        print('  - ID: ${firstNotif['_id']}');
        print('  - Title: ${firstNotif['title']}');
        print('  - Message: ${firstNotif['message']}');
        print('  - Type: ${firstNotif['type']}');
        print('  - Read: ${firstNotif['isRead']}');
      }
    } else {
      print('❌ Failed: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> testGetCount(String token) async {
  print('\n🔢 TEST 2: Get Notification Count');
  print('-' * 60);
  
  const String endpoint = "https://api.unrealvibe.com/api/notifications/count";
  
  try {
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print('✅ Success: ${data['success']}');
      print('🔔 Unread Count: ${data['count']}');
    } else {
      print('❌ Failed: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> testMarkAsRead(String token) async {
  print('\n✅ TEST 3: Mark Notifications as Read');
  print('-' * 60);
  
  const String endpoint = "https://api.unrealvibe.com/api/notifications/mark-read";
  
  // Example notification IDs - replace with actual IDs from your notifications
  final List<String> notificationIds = [
    "675d8f1a2b3c4d5e6f789012",
    "675d8f1a2b3c4d5e6f789013"
  ];
  
  try {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'notification_ids': notificationIds,
      }),
    ).timeout(const Duration(seconds: 10));

    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print('✅ Success: ${data['success']}');
      print('📝 Marked Read: ${data['marked_read']}');
      print('💡 Note: marked_read=0 means notifications were already read or IDs not found');
    } else {
      print('❌ Failed: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> testDeleteNotification(String token) async {
  print('\n🗑️  TEST 4: Delete Notification');
  print('-' * 60);
  
  // Example notification ID - replace with actual ID
  const String notificationId = "675d8f1a2b3c4d5e6f789012";
  final String endpoint = "https://api.unrealvibe.com/api/notifications/$notificationId";
  
  try {
    final response = await http.delete(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print('✅ Success: ${data['success']}');
      print('📝 Message: ${data['message']}');
    } else if (response.statusCode == 404) {
      print('⚠️  Notification not found (404)');
      print('💡 This is expected if the notification doesn\'t exist');
      final Map<String, dynamic> data = json.decode(response.body);
      print('Message: ${data['message']}');
    } else {
      print('❌ Failed: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> testSSEConnection(String token) async {
  print('\n📡 TEST 5: SSE Connection');
  print('-' * 60);
  
  const String endpoint = "https://api.unrealvibe.com/api/sse/notifications";
  
  try {
    print('🔌 Attempting SSE connection...');
    print('⏱️  Will listen for 5 seconds...');
    
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(endpoint));
    
    request.headers.set('Accept', 'text/event-stream');
    request.headers.set('Cache-Control', 'no-cache');
    request.headers.set('Authorization', 'Bearer $token');
    
    final response = await request.close();
    
    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅ SSE Connection Established!');
      print('👂 Listening for events...\n');
      
      final subscription = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.isNotEmpty) {
              print('📨 Received: $line');
              
              if (line.startsWith('data: ')) {
                final data = line.substring(6);
                try {
                  final json = jsonDecode(data);
                  print('   Type: ${json['type']}');
                  print('   Message: ${json['message']}');
                } catch (e) {
                  print('   Raw data: $data');
                }
              }
            }
          });
      
      // Listen for 5 seconds
      await Future.delayed(const Duration(seconds: 5));
      
      await subscription.cancel();
      client.close();
      
      print('\n✅ SSE test completed');
      print('💡 Connection works! Real-time notifications will appear here');
    } else {
      print('❌ Failed: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
