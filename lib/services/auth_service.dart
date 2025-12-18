// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_routes.dart';
import 'user_storage.dart';

class AuthService {
  // Test token validity by making a simple authenticated request
  static Future<bool> isTokenValid() async {
    try {
      final token = await UserStorage.getToken();
      if (token == null) {
        print('🔐 No token found');
        return false;
      }
      
      print('🔐 Testing token validity...');
      
      // Try multiple endpoints to test token validity
      final endpoints = [
        ApiConfig.getProfile,
        ApiConfig.profile,
        ApiConfig.getSavedEvents, // This requires auth and should work
      ];
      
      for (final endpoint in endpoints) {
        try {
          print('🔐 Testing endpoint: $endpoint');
          
          final response = await http.get(
            Uri.parse(endpoint),
            headers: ApiConfig.getAuthHeaders(token),
          ).timeout(const Duration(seconds: 5));
          
          print('🔐 Response: ${response.statusCode}');
          
          // Check for clear authentication/authorization errors
          if (response.statusCode == 401) {
            print('❌ Token is expired (401 Unauthorized)');
            await UserStorage.clearAll(); // Clear invalid token
            return false;
          } else if (response.statusCode == 403) {
            print('❌ Token has insufficient permissions (403 Forbidden)');
            await UserStorage.clearAll(); // Clear invalid token
            return false;
          } else if (response.statusCode == 200) {
            print('✅ Token is valid (200 OK)');
            return true;
          }
          // Continue to next endpoint if this one doesn't work
        } catch (e) {
          print('🔐 Error testing endpoint $endpoint: $e');
          continue;
        }
      }
      
      print('⚠️ All validation endpoints failed - assuming token is valid');
      print('⚠️ Will let the actual order API handle authentication');
      return true; // Assume valid if we can't test properly
      
    } catch (e) {
      print('🔐 Token validation error: $e');
      return true; // Assume valid and let order API handle it
    }
  }

  // Request OTP
  static Future<Map<String, dynamic>> requestOtp(String phoneNumber) async {
    try {
      print("📞 Calling Request OTP API: ${ApiConfig.requestOtp}");
      print("📞 Request Body: {phone: $phoneNumber}");

      final response = await http.post(
        Uri.parse(ApiConfig.requestOtp),
        headers: ApiConfig.headers,
        body: jsonEncode({
          "phone": phoneNumber,
        }),
      );

      print("📞 Raw Response: ${response.body}");
      print("📞 Status Code: ${response.statusCode}");

      final data = jsonDecode(response.body);
      print("📞 Decoded JSON: $data");

      if (response.statusCode == 200 && data['success'] == true) {
        // Save request_id for OTP verification
        if (data['details'] != null && data['details']['request_id'] != null) {
          await UserStorage.saveRequestId(data['details']['request_id']);
          print("📞 Request ID saved: ${data['details']['request_id']}");
        }

        print("📞 OTP sent successfully");
        return {
          'success': true,
          'message': data['message'] ?? 'OTP sent successfully',
          'otp': data['otp'], // For development/testing
        };
      } else {
        print("📞 Request OTP failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      print("📞 Request OTP error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(
    String phoneNumber,
    String otp,
  ) async {
    try {
      print("🔐 Calling Verify OTP API: ${ApiConfig.verifyOtp}");
      print("🔐 Request Body: {phone: $phoneNumber, otp: $otp}");

      final response = await http.post(
        Uri.parse(ApiConfig.verifyOtp),
        headers: ApiConfig.headers,
        body: jsonEncode({
          "phone": phoneNumber,
          "otp": otp,
        }),
      );

      print("🔐 Raw Response: ${response.body}");
      print("🔐 Status Code: ${response.statusCode}");

      final data = jsonDecode(response.body);
      print("🔐 Decoded JSON: $data");

      if (response.statusCode == 200 && data['success'] == true) {
        // Save token
        if (data['token'] != null) {
          await UserStorage.saveToken(data['token']);
          print("🔐 Token saved successfully");
        }

        // Save login status
        await UserStorage.saveLoginStatus(true);

        print("🔐 OTP verified successfully");
        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'token': data['token'],
          'isProfileComplete': data['isProfileComplete'] ?? false,
        };
      } else {
        print("🔐 Verify OTP failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid OTP',
        };
      }
    } catch (e) {
      print("🔐 Verify OTP error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final token = await UserStorage.getToken();
      
      if (token != null) {
        print("🚪 Calling Logout API: ${ApiConfig.logout}");
        print("🚪 Using Bearer Token: ${token.substring(0, 20)}...");
        
        final response = await http.post(
          Uri.parse(ApiConfig.logout),
          headers: ApiConfig.getAuthHeaders(token),
        );

        print("🚪 Status Code: ${response.statusCode}");
        print("🚪 Response: ${response.body}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print("🚪 Logout API successful: ${data['message']}");
        } else {
          print("🚪 Logout API failed but continuing with local logout");
        }
      } else {
        print("🚪 No token found, skipping API call");
      }

      // Clear local storage regardless of API response
      await UserStorage.clearAll();
      print("🚪 Local data cleared successfully");

      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      print("🚪 Logout error: $e");
      // Still clear local data even if API fails
      await UserStorage.clearAll();
      print("🚪 Local data cleared after error");
      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    }
  }
}
