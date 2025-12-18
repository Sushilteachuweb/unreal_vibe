import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_routes.dart';
import '../models/host_request_model.dart';

class HostService {
  /// Test if the API endpoint is reachable
  static Future<Map<String, dynamic>> testApiConnection({String? authToken}) async {
    print('🔍 [HostService] Starting API connection test...');
    
    try {
      // Prepare headers with authentication
      Map<String, String> headers;
      if (authToken != null && authToken.isNotEmpty) {
        headers = ApiConfig.getAuthHeaders(authToken);
        print('🔐 [HostService] Using authenticated headers for testing');
      } else {
        headers = {'Accept': 'application/json'};
        print('⚠️ [HostService] No auth token provided for testing');
      }
      
      // Test base API
      print('📡 [HostService] Testing base API: ${ApiConfig.baseUrl}');
      final baseResponse = await http.get(
        Uri.parse(ApiConfig.baseUrl),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('✅ [HostService] Base API Response - Status: ${baseResponse.statusCode}');
      print('📄 [HostService] Base API Body (first 200 chars): ${baseResponse.body.length > 200 ? baseResponse.body.substring(0, 200) : baseResponse.body}');
      
      // Test all host endpoints
      final endpoints = [
        {'name': 'Main', 'url': ApiConfig.hostRequest},
        {'name': 'Alt1', 'url': ApiConfig.hostRequestAlt1},
        {'name': 'Alt2', 'url': ApiConfig.hostRequestAlt2},
        {'name': 'Alt3', 'url': ApiConfig.hostRequestAlt3},
      ];
      
      Map<String, dynamic> endpointResults = {};
      
      for (final endpoint in endpoints) {
        try {
          print('📡 [HostService] Testing ${endpoint['name']} endpoint: ${endpoint['url']}');
          final response = await http.get(
            Uri.parse(endpoint['url']!),
            headers: headers,
          ).timeout(const Duration(seconds: 10));
          
          print('✅ [HostService] ${endpoint['name']} Response - Status: ${response.statusCode}');
          
          endpointResults['${endpoint['name']}_status'] = response.statusCode;
          endpointResults['${endpoint['name']}_exists'] = response.statusCode != 404;
          endpointResults['${endpoint['name']}_body'] = response.body.length > 100 ? response.body.substring(0, 100) : response.body;
        } catch (e) {
          print('❌ [HostService] ${endpoint['name']} endpoint failed: $e');
          endpointResults['${endpoint['name']}_status'] = 'Error';
          endpointResults['${endpoint['name']}_exists'] = false;
          endpointResults['${endpoint['name']}_error'] = e.toString();
        }
      }
      
      return {
        'baseApiReachable': baseResponse.statusCode < 500,
        'baseApiStatus': baseResponse.statusCode,
        'baseApiBody': baseResponse.body.length > 200 ? baseResponse.body.substring(0, 200) : baseResponse.body,
        ...endpointResults,
      };
    } catch (e) {
      print('❌ [HostService] API connection test failed: $e');
      return {
        'error': e.toString(),
        'baseApiReachable': false,
      };
    }
  }

  /// Submit host party request
  static Future<HostRequestResponse> submitHostRequest({
    required String preferredPartyDate,
    required String locality,
    required String city,
    required String pincode,
    String? authToken,
  }) async {
    print('🚀 [HostService] Starting host request submission...');
    print('📅 [HostService] Date: $preferredPartyDate');
    print('📍 [HostService] Locality: $locality');
    print('🏙️ [HostService] City: $city');
    print('📮 [HostService] Pincode: $pincode');
    
    final hostRequest = HostRequest(
      preferredPartyDate: preferredPartyDate,
      locality: locality,
      city: city,
      pincode: pincode,
    );

    final requestBody = json.encode(hostRequest.toJson());
    print('📦 [HostService] Request body: $requestBody');
    
    // Prepare headers with authentication
    Map<String, String> headers;
    if (authToken != null && authToken.isNotEmpty) {
      headers = ApiConfig.getAuthHeaders(authToken);
      print('🔐 [HostService] Using authenticated headers with Bearer token');
    } else {
      headers = ApiConfig.headers;
      print('⚠️ [HostService] No auth token provided, using basic headers');
    }
    print('📋 [HostService] Headers: $headers');
    
    // List of endpoints to try
    final endpoints = [
      ApiConfig.hostRequest,
      ApiConfig.hostRequestAlt1,
      ApiConfig.hostRequestAlt2,
      ApiConfig.hostRequestAlt3,
    ];
    
    for (int i = 0; i < endpoints.length; i++) {
      final endpoint = endpoints[i];
      print('🌐 [HostService] Trying endpoint ${i + 1}/${endpoints.length}: $endpoint');
      
      try {
        final response = await http.post(
          Uri.parse(endpoint),
          headers: headers,
          body: requestBody,
        ).timeout(const Duration(seconds: 30));

        print('📨 [HostService] Response received - Status: ${response.statusCode}');
        print('📄 [HostService] Response body: ${response.body}');
        print('📋 [HostService] Response headers: ${response.headers}');

        // If we get a 404, try the next endpoint
        if (response.statusCode == 404 && i < endpoints.length - 1) {
          print('🔄 [HostService] 404 received, trying next endpoint...');
          continue;
        }

        // Check if response is JSON
        Map<String, dynamic>? responseData;
        try {
          responseData = json.decode(response.body);
          print('✅ [HostService] Successfully parsed JSON response');
        } catch (e) {
          print('❌ [HostService] Failed to parse JSON response: $e');
          
          // Response is not valid JSON, likely HTML error page
          String errorMessage = 'Server returned an invalid response';
          if (response.statusCode == 404) {
            errorMessage = 'API endpoint not found. Please check if the server is running.';
            print('🔍 [HostService] 404 Error - Endpoint not found: $endpoint');
          } else if (response.statusCode >= 500) {
            errorMessage = 'Server error occurred. Please try again later.';
            print('🔥 [HostService] Server error (${response.statusCode})');
          } else if (response.body.toLowerCase().contains('<!doctype html>')) {
            errorMessage = 'Server returned an HTML page instead of data. The API might be down.';
            print('🌐 [HostService] HTML response detected instead of JSON');
          }
          
          return HostRequestResponse(
            success: false,
            message: errorMessage,
            error: 'Endpoint: $endpoint\nStatus: ${response.statusCode}\nBody: ${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}',
            statusCode: response.statusCode,
          );
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('✅ [HostService] Request successful with endpoint: $endpoint');
          return HostRequestResponse(
            success: true,
            message: responseData?['message'] ?? 'Host request submitted successfully',
            data: responseData,
          );
        } else {
          print('⚠️ [HostService] Request failed with status: ${response.statusCode}');
          return HostRequestResponse(
            success: false,
            message: responseData?['message'] ?? 'Failed to submit host request',
            error: 'Endpoint: $endpoint\nMessage: ${responseData?['message'] ?? 'Failed to submit host request'}',
            statusCode: response.statusCode,
          );
        }
      } catch (e) {
        print('💥 [HostService] Exception with endpoint $endpoint: $e');
        
        // If this is the last endpoint, return the error
        if (i == endpoints.length - 1) {
          String errorMessage = 'Network error occurred';
          if (e.toString().contains('SocketException')) {
            errorMessage = 'No internet connection. Please check your network.';
            print('🌐 [HostService] Network connection issue detected');
          } else if (e.toString().contains('TimeoutException')) {
            errorMessage = 'Request timeout. Please try again.';
            print('⏰ [HostService] Request timeout detected');
          } else if (e.toString().contains('HandshakeException')) {
            errorMessage = 'SSL connection error. Please check your network security settings.';
            print('🔒 [HostService] SSL handshake error detected');
          } else if (e.toString().contains('FormatException')) {
            errorMessage = 'Server returned invalid data format.';
            print('📄 [HostService] Data format error detected');
          }
          
          return HostRequestResponse(
            success: false,
            message: errorMessage,
            error: 'All endpoints failed. Last error: ${e.toString()}',
          );
        }
        
        // Try next endpoint
        print('🔄 [HostService] Exception occurred, trying next endpoint...');
        continue;
      }
    }
    
    // This should never be reached, but just in case
    return HostRequestResponse(
      success: false,
      message: 'All API endpoints failed',
      error: 'No working endpoint found',
    );
  }
}