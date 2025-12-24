import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  await testProfileLinks();
}

Future<void> testProfileLinks() async {
  final Map<String, String> links = {
    'Privacy Policy': 'https://unrealvibe.com/privacy-policy',
    'About Us': 'https://unrealvibe.com/#about',
    'T&C': 'https://unrealvibe.com/terms-conditions',
    'Contact Us': 'https://unrealvibe.com/',
  };

  print('🔍 Testing Profile Page Links...\n');

  for (final entry in links.entries) {
    final linkName = entry.key;
    final url = entry.value;
    
    try {
      print('📍 Testing: $linkName');
      print('🌐 URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      print('📊 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ $linkName link is working');
        
        // Check if it's HTML content
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.contains('text/html')) {
          final bodyLength = response.body.length;
          print('📄 HTML content loaded (${bodyLength} characters)');
          
          // Check for common HTML elements
          if (response.body.contains('<title>')) {
            final titleMatch = RegExp(r'<title>(.*?)</title>').firstMatch(response.body);
            if (titleMatch != null) {
              print('📝 Page title: ${titleMatch.group(1)}');
            }
          }
        }
      } else if (response.statusCode >= 300 && response.statusCode < 400) {
        print('🔄 Redirect detected (${response.statusCode})');
        final location = response.headers['location'];
        if (location != null) {
          print('📍 Redirects to: $location');
        }
      } else {
        print('❌ $linkName link returned status: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Error testing $linkName: $e');
    }
    
    print(''); // Empty line for separation
  }
  
  print('🏁 Link testing completed!');
}