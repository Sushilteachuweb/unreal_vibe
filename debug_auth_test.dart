import 'dart:convert';
import 'package:http/http.dart' as http;

// Simple test to debug the 403 error
void main() async {
  await testAuthentication();
}

Future<void> testAuthentication() async {
  print('🧪 Testing Authentication Debug...');
  
  // You'll need to replace this with an actual token from your app
  const String testToken = "YOUR_TOKEN_HERE"; // Get this from app logs
  const String baseUrl = "https://api.unrealvibe.com/api";
  
  // Test different endpoints to see which ones work
  final endpoints = [
    '$baseUrl/user/profile',
    '$baseUrl/user/get-profile', 
    '$baseUrl/event/saved-events',
    '$baseUrl/payment/create-order',
  ];
  
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $testToken',
  };
  
  for (final endpoint in endpoints) {
    try {
      print('\n🔍 Testing: $endpoint');
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');
      
      if (response.statusCode == 401) {
        print('   ❌ Unauthorized - Token expired or invalid');
      } else if (response.statusCode == 403) {
        print('   ❌ Forbidden - Insufficient permissions');
      } else if (response.statusCode == 404) {
        print('   ⚠️ Not Found - Endpoint doesn\'t exist');
      } else if (response.statusCode == 200) {
        print('   ✅ Success - Token is valid for this endpoint');
      }
      
    } catch (e) {
      print('   💥 Error: $e');
    }
  }
  
  // Test order creation specifically
  print('\n🎫 Testing Order Creation...');
  try {
    final orderBody = {
      'eventId': 'test-event-id',
      'items': [
        {'passType': 'Male', 'price': 1499, 'quantity': 1}
      ],
      'attendees': [
        {
          'fullName': 'Test User',
          'email': 'test@example.com',
          'phone': '1234567890',
          'gender': 'Male',
          'passType': 'Male'
        }
      ]
    };
    
    final response = await http.post(
      Uri.parse('$baseUrl/payment/create-order'),
      headers: headers,
      body: json.encode(orderBody),
    ).timeout(const Duration(seconds: 10));
    
    print('Order Creation Status: ${response.statusCode}');
    print('Order Creation Body: ${response.body}');
    
  } catch (e) {
    print('Order Creation Error: $e');
  }
}