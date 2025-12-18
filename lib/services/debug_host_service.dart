import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_routes.dart';

class DebugHostService {
  /// Test the host API endpoint with debug information
  static Future<Map<String, dynamic>> debugHostRequest({
    required String preferredPartyDate,
    required String locality,
    required String city,
    required String pincode,
  }) async {
    final requestBody = {
      "preferredPartyDate": preferredPartyDate,
      "locality": locality,
      "city": city,
      "pincode": pincode,
    };

    print('=== DEBUG HOST REQUEST ===');
    print('URL: ${ApiConfig.hostRequest}');
    print('Headers: ${ApiConfig.headers}');
    print('Body: ${json.encode(requestBody)}');
    print('========================');

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.hostRequest),
        headers: ApiConfig.headers,
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('=== DEBUG RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('Response Length: ${response.body.length}');
      print('=====================');

      return {
        'statusCode': response.statusCode,
        'headers': response.headers,
        'body': response.body,
        'bodyLength': response.body.length,
        'isJson': _isValidJson(response.body),
      };
    } catch (e) {
      print('=== DEBUG ERROR ===');
      print('Error: $e');
      print('Error Type: ${e.runtimeType}');
      print('==================');

      return {
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
      };
    }
  }

  static bool _isValidJson(String str) {
    try {
      json.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }
}