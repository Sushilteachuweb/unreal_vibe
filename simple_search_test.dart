import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧪 Simple Search API Test');
  print('========================');
  
  // Test the actual API endpoint from Postman
  const String apiUrl = 'https://api.unrealvibe.com/api/event/search?city=Noida';
  
  try {
    print('📡 Making request to: $apiUrl');
    
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(apiUrl));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('📊 Response Status: ${response.statusCode}');
    print('📄 Response Body: $responseBody');
    
    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(responseBody);
        
        if (data['success'] == true && data['data'] != null && data['data']['events'] != null) {
          final List<dynamic> events = data['data']['events'];
          print('✅ Found ${events.length} events');
          
          if (events.isNotEmpty) {
            final firstEvent = events.first;
            print('📋 First event:');
            print('   ID: ${firstEvent['_id']}');
            print('   Name: ${firstEvent['eventName']}');
            print('   City: ${firstEvent['city']}');
            print('   Date: ${firstEvent['date']}');
            print('   Address: ${firstEvent['fullAddress']}');
            
            // Check if this matches our Event model expectations
            print('\\n🔍 Event model compatibility check:');
            print('   Has _id: ${firstEvent['_id'] != null}');
            print('   Has eventName: ${firstEvent['eventName'] != null}');
            print('   Has city: ${firstEvent['city'] != null}');
            print('   Has passes: ${firstEvent['passes'] != null}');
            print('   Passes count: ${firstEvent['passes']?.length ?? 0}');
          }
        } else {
          print('❌ Invalid response structure');
        }
      } catch (e) {
        print('❌ JSON parsing error: $e');
      }
    } else {
      print('❌ HTTP Error: ${response.statusCode}');
    }
    
    client.close();
  } catch (e) {
    print('❌ Request error: $e');
  }
  
  print('\\n🎉 Test completed!');
}