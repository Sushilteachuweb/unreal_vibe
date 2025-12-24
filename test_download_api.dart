import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  await testDownloadAPI();
}

Future<void> testDownloadAPI() async {
  // Use a real booking ID from the API response you showed
  const String bookingId = "6943e795a580b286e57be85e";
  final String endpoint = "https://api.unrealvibe.com/api/passes/my-passes/download/$bookingId";
  
  // You'll need to replace this with a valid bearer token
  const String bearerToken = "YOUR_BEARER_TOKEN_HERE";
  
  try {
    print('🔍 Testing Download Ticket API...');
    print('📍 Endpoint: $endpoint');
    print('🎫 Booking ID: $bookingId');
    print('🔐 Using Bearer Token: ${bearerToken.substring(0, 20)}...');
    
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Accept': 'application/pdf',
      },
    ).timeout(const Duration(seconds: 30));

    print('\n📊 Response Details:');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Content-Type: ${response.headers['content-type']}');
    print('Content-Length: ${response.headers['content-length']} bytes');
    
    if (response.statusCode == 200) {
      print('\n✅ Download API call successful!');
      
      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('application/pdf')) {
        print('📄 Response is a PDF file');
        print('📊 File size: ${response.bodyBytes.length} bytes');
        
        if (response.bodyBytes.length > 0) {
          print('✅ PDF file downloaded successfully');
          
          // Check if it's a valid PDF (starts with %PDF)
          final pdfHeader = String.fromCharCodes(response.bodyBytes.take(4));
          if (pdfHeader == '%PDF') {
            print('✅ Valid PDF file format confirmed');
          } else {
            print('⚠️ File may not be a valid PDF (header: $pdfHeader)');
          }
        } else {
          print('❌ PDF file is empty');
        }
      } else {
        print('⚠️ Response is not a PDF file');
        print('📄 Content-Type: $contentType');
        
        // Try to parse as JSON (might be an error response)
        try {
          final jsonResponse = json.decode(response.body);
          print('📋 JSON Response: $jsonResponse');
        } catch (e) {
          print('📄 Raw response (first 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
        }
      }
    } else {
      print('❌ Download API call failed with status: ${response.statusCode}');
      
      if (response.statusCode == 401) {
        print('🔐 Authentication failed - check your bearer token');
      } else if (response.statusCode == 404) {
        print('🔍 Booking not found - check the booking ID');
      } else if (response.statusCode == 403) {
        print('🚫 Access forbidden - user may not own this booking');
      }
      
      // Try to parse error response
      try {
        final errorResponse = json.decode(response.body);
        print('📋 Error Response: $errorResponse');
      } catch (e) {
        print('📄 Raw error response: ${response.body}');
      }
    }
  } catch (e) {
    print('❌ Network Error: $e');
  }
}