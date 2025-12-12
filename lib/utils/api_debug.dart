import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiDebug {
  static Future<void> testApiEndpoints() async {
    final baseUrl = "http://api.unrealvibe.com";
    
    final endpointsToTest = [
      "/api/event/eventsoutput",
      "/api/events",
      "/api/event/events", 
      "/api/event/list",
      "/events",
      "/event/events",
      "/event/list",
      "/event/eventsoutput",
    ];

    print("=== API Endpoint Testing ===");
    print("Base URL: $baseUrl");
    print("");

    for (String endpoint in endpointsToTest) {
      try {
        final url = "$baseUrl$endpoint";
        print("Testing: $url");
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));

        print("  Status: ${response.statusCode}");
        
        if (response.statusCode == 200) {
          try {
            final data = json.decode(response.body);
            print("  Response: ${data.toString().substring(0, data.toString().length > 100 ? 100 : data.toString().length)}...");
            
            if (data is Map && data.containsKey('events')) {
              print("  ✅ Found 'events' key with ${data['events']?.length ?? 0} items");
            } else if (data is Map && data.containsKey('success')) {
              print("  ✅ Found 'success' key: ${data['success']}");
            } else {
              print("  ⚠️  Unexpected response structure");
            }
          } catch (e) {
            print("  ⚠️  JSON parse error: $e");
          }
        } else {
          print("  ❌ HTTP ${response.statusCode}: ${response.body.substring(0, response.body.length > 50 ? 50 : response.body.length)}");
        }
      } catch (e) {
        print("  ❌ Error: $e");
      }
      print("");
    }
    
    print("=== End API Testing ===");
  }
}