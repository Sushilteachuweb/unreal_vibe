import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  await testMyPassesAPI();
}

Future<void> testMyPassesAPI() async {
  const String endpoint = "https://api.unrealvibe.com/api/passes/my-passes";
  
  // You'll need to replace this with a valid bearer token
  const String bearerToken = "YOUR_BEARER_TOKEN_HERE";
  
  try {
    print('🔍 Testing My Passes API...');
    print('📍 Endpoint: $endpoint');
    print('🔐 Using Bearer Token: ${bearerToken.substring(0, 20)}...');
    
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
        final passes = data['passes'] as List? ?? 
                      data['data'] as List? ?? 
                      data['tickets'] as List? ?? 
                      [];
        
        print('  - Passes count: ${passes.length}');
        
        if (passes.isNotEmpty) {
          print('\n🎫 First Pass Details:');
          final firstPass = passes[0] as Map<String, dynamic>;
          print('  - Keys: ${firstPass.keys.toList()}');
          print('  - Sample data: $firstPass');
        }
        
        // Test the model parsing
        print('\n🧪 Testing Model Parsing:');
        try {
          // Simulate the model parsing
          final testPasses = passes.map((passJson) {
            final pass = passJson as Map<String, dynamic>;
            return {
              'id': pass['_id'] ?? pass['id'] ?? 'unknown',
              'eventName': pass['eventName'] ?? pass['event']?['name'] ?? 'Unknown Event',
              'passType': pass['passType'] ?? pass['type'] ?? 'Unknown Type',
              'status': pass['status'] ?? 'upcoming',
            };
          }).toList();
          
          print('✅ Model parsing would succeed with ${testPasses.length} passes');
          for (var pass in testPasses) {
            print('  - ${pass['eventName']} (${pass['passType']})');
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