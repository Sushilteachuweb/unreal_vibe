import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket_model.dart';
import '../models/my_pass_model.dart';
import 'api_routes.dart';
import 'user_storage.dart';

// Helper class for base64 URL decoding
class _Base64Url {
  String normalize(String source) {
    var result = source;
    // Add padding if needed
    switch (result.length % 4) {
      case 2:
        result += '==';
        break;
      case 3:
        result += '=';
        break;
    }
    // Replace URL-safe characters
    result = result.replaceAll('-', '+').replaceAll('_', '/');
    return result;
  }
  
  List<int> decode(String source) {
    return base64.decode(source);
  }
}

final base64Url = _Base64Url();

class TicketService {
  /// Fetch user's purchased passes
  static Future<MyPassesResponse> fetchMyPasses() async {
    try {
      final endpoint = ApiConfig.getMyPasses;
      print('Fetching my passes from: $endpoint');
      
      // Get auth token
      final token = await UserStorage.getToken();
      final isLoggedIn = await UserStorage.getLoginStatus();
      
      if (token == null || !isLoggedIn) {
        throw Exception('AUTHENTICATION_REQUIRED');
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: await ApiConfig.getAuthHeadersWithCookies(token),
      ).timeout(const Duration(seconds: 10));

      print('My Passes API Response Status: ${response.statusCode}');
      print('My Passes API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Parsed data: $data');
        print('Success: ${data['success']}');
        print('Passes count: ${(data['passes'] as List?)?.length ?? 0}');
        
        final result = MyPassesResponse.fromJson(data);
        print('MyPassesResponse created with ${result.passes.length} passes');
        return result;
      } else if (response.statusCode == 401) {
        // Handle authentication error
        await UserStorage.clearAll();
        throw Exception('AUTHENTICATION_REQUIRED');
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to fetch passes: HTTP ${response.statusCode}');
        } catch (e) {
          throw Exception('Failed to fetch passes: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error fetching my passes: $e');
      rethrow;
    }
  }

  /// Fetch passes for a specific event
  static Future<List<TicketType>> fetchEventPasses(String eventId) async {
    try {
      final endpoint = ApiConfig.getEventPasses(eventId);
      print('Fetching event passes from: $endpoint');
      
      // Get auth token
      final token = await UserStorage.getToken();
      final headers = token != null 
          ? await ApiConfig.getAuthHeadersWithCookies(token)
          : ApiConfig.headers;

      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('Passes API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Passes API Response Body: ${response.body}');
        
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['passes'] != null) {
          final List<dynamic> passesJson = data['passes'];
          final passes = passesJson.map((passJson) => 
            TicketType.fromPass(passJson, null) // No whatsIncluded in passes API
          ).toList();
          
          print('Successfully parsed ${passes.length} passes');
          return passes;
        } else {
          print('Invalid passes response format: $data');
          throw Exception('Invalid API response format');
        }
      } else {
        print('HTTP ${response.statusCode} from passes API: ${response.body}');
        throw Exception('Failed to fetch passes: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching passes: $e');
      
      // Return empty list as fallback - the UI will use event passes or default tickets
      return [];
    }
  }

  /// Legacy method for backward compatibility
  @deprecated
  static Future<List<TicketType>> fetchTicketPackages(String eventId) async {
    return fetchEventPasses(eventId);
  }

  /// Create order for selected tickets
  static Future<Map<String, dynamic>> createOrder({
    required String eventId,
    required List<Map<String, dynamic>> selectedTickets,
    required List<Map<String, dynamic>> attendees,
  }) async {
    try {
      final endpoint = ApiConfig.createOrder;
      print('═══════════════════════════════════════════════════════');
      print('🎫 CREATE ORDER DEBUG LOG');
      print('═══════════════════════════════════════════════════════');
      print('📍 Endpoint: $endpoint');
      print('🎯 Event ID: $eventId');
      
      // Get auth token and validate authentication
      final token = await UserStorage.getToken();
      final isLoggedIn = await UserStorage.getLoginStatus();
      final cookie = await UserStorage.getAccessTokenCookie();
      
      print('\n🔐 AUTHENTICATION STATUS:');
      print('  ├─ Token exists: ${token != null}');
      print('  ├─ Is logged in: $isLoggedIn');
      print('  ├─ Cookie exists: ${cookie != null}');
      
      // Check when user logged in
      final prefs = await SharedPreferences.getInstance();
      final loginTime = prefs.getInt('login_timestamp');
      if (loginTime != null) {
        final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTime);
        final timeSinceLogin = DateTime.now().difference(loginDate);
        print('  ├─ Logged in at: $loginDate');
        print('  ├─ Time since login: ${timeSinceLogin.inMinutes} minutes (${timeSinceLogin.inSeconds} seconds)');
      } else {
        print('  ├─ Login timestamp: Not recorded');
      }
      
      if (token != null) {
        print('  ├─ Token length: ${token.length}');
        print('  ├─ Token preview: ${token.substring(0, min(50, token.length))}...');
        print('  └─ Token ends with: ...${token.substring(token.length - 20)}');
        
        // Decode JWT to see claims
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            // Decode the payload (second part)
            final payload = parts[1];
            // Add padding if needed
            final normalized = base64Url.normalize(payload);
            final decoded = utf8.decode(base64Url.decode(normalized));
            final claims = json.decode(decoded);
            print('  ├─ JWT Payload: $decoded');
            
            // Check expiration
            if (claims['exp'] != null) {
              final expTimestamp = claims['exp'] as int;
              final expDate = DateTime.fromMillisecondsSinceEpoch(expTimestamp * 1000);
              final now = DateTime.now();
              final timeLeft = expDate.difference(now);
              
              print('  ├─ Token Expires: $expDate');
              print('  ├─ Current Time: $now');
              print('  ├─ Time Left: ${timeLeft.inMinutes} minutes (${timeLeft.inSeconds} seconds)');
              
              if (timeLeft.isNegative) {
                print('  ├─ ⚠️ TOKEN IS EXPIRED!');
              } else if (timeLeft.inMinutes < 5) {
                print('  ├─ ⚠️ TOKEN EXPIRES SOON (less than 5 minutes)');
              } else {
                print('  ├─ ✅ Token is still valid');
              }
            }
            
            // Check issued at
            if (claims['iat'] != null) {
              final iatTimestamp = claims['iat'] as int;
              final iatDate = DateTime.fromMillisecondsSinceEpoch(iatTimestamp * 1000);
              final age = DateTime.now().difference(iatDate);
              print('  ├─ Token Issued: $iatDate');
              print('  ├─ Token Age: ${age.inMinutes} minutes (${age.inSeconds} seconds)');
            }
          }
        } catch (e) {
          print('  ├─ JWT decode error: $e');
        }
      }
      if (cookie != null) {
        print('  ├─ Cookie length: ${cookie.length}');
        print('  └─ Cookie preview: ${cookie.substring(0, min(50, cookie.length))}...');
      }
      
      if (token == null || !isLoggedIn) {
        print('\n❌ AUTHENTICATION REQUIRED - no valid token');
        throw Exception('AUTHENTICATION_REQUIRED');
      }
      
      // Check user profile to see permissions
      print('\n👤 CHECKING USER PROFILE:');
      try {
        final profileResponse = await http.get(
          Uri.parse(ApiConfig.getProfile),
          headers: await ApiConfig.getAuthHeadersWithCookies(token),
        ).timeout(const Duration(seconds: 5));
        
        if (profileResponse.statusCode == 200) {
          final profileData = json.decode(profileResponse.body);
          print('  ├─ Profile fetch: SUCCESS');
          print('  ├─ User data: ${json.encode(profileData)}');
          
          // Check for common permission fields
          if (profileData['user'] != null) {
            final user = profileData['user'];
            print('  ├─ User ID: ${user['_id'] ?? 'N/A'}');
            print('  ├─ Role: ${user['role'] ?? 'N/A'}');
            print('  ├─ Is Verified: ${user['isVerified'] ?? 'N/A'}');
            print('  ├─ Email Verified: ${user['emailVerified'] ?? 'N/A'}');
            print('  ├─ Phone Verified: ${user['phoneVerified'] ?? 'N/A'}');
            print('  └─ Account Status: ${user['status'] ?? 'N/A'}');
          }
        } else {
          print('  └─ Profile fetch failed: ${profileResponse.statusCode}');
        }
      } catch (e) {
        print('  └─ Profile check error: $e');
      }
      
      // Convert selectedTickets to items format with price
      final items = selectedTickets.map((ticket) {
        return {
          'passType': ticket['type'],
          'price': ticket['price'] ?? 0, // Include price from ticket selection
          'quantity': ticket['quantity'],
        };
      }).toList();
      
      // Keep attendees format exactly as Postman expects (fullName + passType)
      final requestBody = {
        'eventId': eventId,
        'items': items,
        'attendees': attendees, // Don't modify - keep original format
      };
      
      print('\n📦 REQUEST BODY:');
      print(json.encode(requestBody));
      
      print('\n🔍 REQUEST VALIDATION:');
      print('  ├─ Event ID: ${requestBody['eventId']}');
      print('  ├─ Items count: ${(requestBody['items'] as List).length}');
      print('  ├─ Attendees count: ${(requestBody['attendees'] as List).length}');
      print('  └─ Items structure:');
      for (var i = 0; i < (requestBody['items'] as List).length; i++) {
        final item = (requestBody['items'] as List)[i];
        print('      [$i] passType: ${item['passType']}, price: ${item['price']}, quantity: ${item['quantity']}');
      }
      print('  └─ Attendees structure:');
      for (var i = 0; i < (requestBody['attendees'] as List).length; i++) {
        final attendee = (requestBody['attendees'] as List)[i];
        print('      [$i] fullName: ${attendee['fullName']}, email: ${attendee['email']}, phone: ${attendee['phone']}, gender: ${attendee['gender']}, passType: ${attendee['passType']}');
      }
      
      final headers = await ApiConfig.getAuthHeadersWithCookies(token);
      print('\n� REQUEST HEADERS:');
      headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization' || key.toLowerCase() == 'cookie') {
          print('  ├─ $key: ${value.substring(0, min(60, value.length))}...');
        } else {
          print('  ├─ $key: $value');
        }
      });
      
      // Try with full headers (Bearer + Cookie)
      print('\n🚀 SENDING REQUEST...');
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print('\n📥 RESPONSE RECEIVED:');
      print('  ├─ Status Code: ${response.statusCode}');
      print('  ├─ Response Body: ${response.body}');
      print('  └─ Response Headers: ${response.headers}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          print('\n✅ ORDER CREATED SUCCESSFULLY');
          print('═══════════════════════════════════════════════════════\n');
          return data;
        } else {
          print('\n❌ API RETURNED success: false');
          print('═══════════════════════════════════════════════════════\n');
          final message = data['message'] ?? 'Order creation failed';
          throw Exception('API_ERROR: $message');
        }
      } else if (response.statusCode == 400) {
        print('\n❌ 400 BAD REQUEST');
        try {
          final errorData = json.decode(response.body);
          final message = errorData['message'] ?? 'Bad request';
          print('  └─ Error: $message');
          print('═══════════════════════════════════════════════════════\n');
          
          if (message.toLowerCase().contains('sold out') || 
              message.toLowerCase().contains('capacity') ||
              message.toLowerCase().contains('insufficient')) {
            throw Exception('SOLD_OUT: This event is sold out or has insufficient capacity. Please try a different event or ticket type.');
          } else if (message.toLowerCase().contains('invalid') ||
                     message.toLowerCase().contains('validation')) {
            throw Exception('VALIDATION_ERROR: Please check your booking details and try again. Error: $message');
          } else {
            throw Exception('BOOKING_ERROR: $message');
          }
        } catch (e) {
          if (e.toString().startsWith('Exception: ')) {
            rethrow; // Re-throw our custom exceptions
          }
          throw Exception('BOOKING_ERROR: Unable to process your booking. Please try again.');
        }
      } else if (response.statusCode == 401) {
        // Handle authentication error - token expired or invalid
        print('\n❌ 401 UNAUTHORIZED');
        print('  ├─ Token is expired or invalid');
        print('  └─ Clearing stored credentials');
        print('═══════════════════════════════════════════════════════\n');
        await UserStorage.clearAll(); // Clear invalid token
        throw Exception('AUTHENTICATION_REQUIRED: Your session has expired. Please log in again to continue.');
      } else if (response.statusCode == 403) {
        // Handle forbidden error - user doesn't have permission
        print('\n❌ 403 FORBIDDEN - INSUFFICIENT PERMISSIONS');
        print('  ├─ Token exists but lacks required permissions');
        print('  ├─ This usually means:');
        print('  │  • Token is valid but user role is insufficient');
        print('  │  • User account needs verification');
        print('  │  • Backend permission check is failing');
        print('  └─ Clearing stored credentials and requiring re-login');
        print('═══════════════════════════════════════════════════════\n');
        
        try {
          final errorData = json.decode(response.body);
          final message = errorData['message'] ?? 'Unable to process your booking';
          
          // Clear the token since it's not working
          await UserStorage.clearAll();
          
          throw Exception('PERMISSION_DENIED: $message. Please log in again.');
        } catch (e) {
          if (e.toString().startsWith('Exception: PERMISSION_DENIED:')) {
            rethrow;
          }
          await UserStorage.clearAll();
          throw Exception('PERMISSION_DENIED: We\'re having trouble processing your booking. Please log in again.');
        }
      } else if (response.statusCode == 404) {
        print('\n❌ 404 NOT FOUND');
        print('═══════════════════════════════════════════════════════\n');
        throw Exception('EVENT_NOT_FOUND: This event is no longer available or the booking system is temporarily unavailable.');
      } else if (response.statusCode >= 500) {
        print('\n❌ ${response.statusCode} SERVER ERROR');
        print('═══════════════════════════════════════════════════════\n');
        throw Exception('SERVER_ERROR: The booking system is temporarily unavailable. Please try again in a few minutes.');
      } else {
        print('\n❌ UNEXPECTED STATUS CODE: ${response.statusCode}');
        print('═══════════════════════════════════════════════════════\n');
        try {
          final errorData = json.decode(response.body);
          throw Exception('BOOKING_ERROR: ${errorData['message'] ?? 'Unexpected error occurred'}');
        } catch (e) {
          throw Exception('BOOKING_ERROR: Unable to complete your booking. Please try again.');
        }
      }
    } catch (e) {
      print('\n💥 EXCEPTION CAUGHT:');
      print('  └─ Error: $e');
      print('═══════════════════════════════════════════════════════\n');
      rethrow;
    }
  }

  /// Download ticket PDF for a specific booking
  static Future<List<int>> downloadTicket(String bookingId) async {
    try {
      final endpoint = ApiConfig.downloadTicket(bookingId);
      print('Downloading ticket from: $endpoint');
      
      // Get auth token
      final token = await UserStorage.getToken();
      final isLoggedIn = await UserStorage.getLoginStatus();
      
      if (token == null || !isLoggedIn) {
        throw Exception('AUTHENTICATION_REQUIRED');
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: await ApiConfig.getAuthHeadersWithCookies(token),
      ).timeout(const Duration(seconds: 30)); // Longer timeout for file download

      print('Download Ticket API Response Status: ${response.statusCode}');
      print('Download Ticket API Response Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        print('Successfully downloaded ticket, size: ${response.bodyBytes.length} bytes');
        return response.bodyBytes;
      } else if (response.statusCode == 401) {
        await UserStorage.clearAll();
        throw Exception('AUTHENTICATION_REQUIRED');
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to download ticket: HTTP ${response.statusCode}');
        } catch (e) {
          throw Exception('Failed to download ticket: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error downloading ticket: $e');
      rethrow;
    }
  }

  /// Get QR code data for a specific pass (from verify payment API)
  static Future<Map<String, dynamic>> getPassQRCode({
    required String passId,
    required String eventId,
  }) async {
    try {
      final endpoint = ApiConfig.verifyPayment;
      print('Getting QR code data from: $endpoint');
      
      // Get auth token
      final token = await UserStorage.getToken();
      final isLoggedIn = await UserStorage.getLoginStatus();
      
      if (token == null || !isLoggedIn) {
        throw Exception('AUTHENTICATION_REQUIRED');
      }
      
      final requestBody = {
        'passId': passId,
        'eventId': eventId,
        'action': 'getQRCode', // Custom action to get QR code
      };
      
      print('Get QR Code Request Body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: await ApiConfig.getAuthHeadersWithCookies(token),
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print('Get QR Code API Response Status: ${response.statusCode}');
      print('Get QR Code API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to get QR code');
        }
      } else if (response.statusCode == 401) {
        await UserStorage.clearAll();
        throw Exception('AUTHENTICATION_REQUIRED');
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to get QR code: HTTP ${response.statusCode}');
        } catch (e) {
          throw Exception('Failed to get QR code: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error getting QR code: $e');
      rethrow;
    }
  }

  /// Verify payment with backend (supports both PhonePe and Razorpay)
  static Future<Map<String, dynamic>> verifyPayment({
    required String eventId,
    required String orderId,
    required String paymentId, // Changed from razorpayPaymentId to generic paymentId
    String? signature, // Changed from razorpaySignature to generic signature
    String? transactionId, // Added for PhonePe support
    String? paymentMethod, // Added to identify payment gateway
    List<Map<String, dynamic>>? selectedTickets,
    List<Map<String, dynamic>>? attendees,
  }) async {
    try {
      final endpoint = ApiConfig.verifyPayment;
      print('Verifying payment at: $endpoint');
      
      // Convert selectedTickets to items format if provided
      List<Map<String, dynamic>>? items;
      if (selectedTickets != null) {
        items = selectedTickets.map((ticket) {
          return {
            'passType': ticket['type'],
            'price': ticket['price'] ?? 0,
            'quantity': ticket['quantity'],
          };
        }).toList();
      }
      
      // Create request body based on payment method
      final requestBody = <String, dynamic>{
        'eventId': eventId,
        if (items != null) 'items': items,
        if (attendees != null) 'attendees': attendees,
      };
      
      // Add payment gateway specific fields
      if (paymentMethod?.toLowerCase() == 'phonepe') {
        // PhonePe specific fields + backward compatibility
        requestBody.addAll({
          // PhonePe fields
          'phonepe_order_id': orderId,
          'phonepe_payment_id': paymentId,
          'phonepe_transaction_id': transactionId,
          if (signature != null) 'phonepe_signature': signature,
          'payment_gateway': 'phonepe',
          
          // Backward compatibility - also send Razorpay field names
          // until backend is updated to handle PhonePe fields
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          if (signature != null) 'razorpay_signature': signature,
        });
      } else {
        // Razorpay specific fields (backward compatibility)
        requestBody.addAll({
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          if (signature != null) 'razorpay_signature': signature,
          'payment_gateway': 'razorpay',
        });
      }
      
      print('Verify Payment Request Body: ${json.encode(requestBody)}');
      
      // Get auth token
      final token = await UserStorage.getToken();
      final isLoggedIn = await UserStorage.getLoginStatus();
      
      if (token == null || !isLoggedIn) {
        throw Exception('AUTHENTICATION_REQUIRED');
      }
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: await ApiConfig.getAuthHeadersWithCookies(token),
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print('Verify Payment API Response Status: ${response.statusCode}');
      print('Verify Payment API Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Payment verification failed');
        }
      } else if (response.statusCode == 401) {
        // Handle authentication error
        await UserStorage.clearAll(); // Clear invalid token
        throw Exception('AUTHENTICATION_REQUIRED');
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Payment verification failed: HTTP ${response.statusCode}');
        } catch (e) {
          throw Exception('Payment verification failed: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error verifying payment: $e');
      rethrow;
    }
  }

  /// Legacy booking method - now uses createOrder
  @deprecated
  static Future<Map<String, dynamic>> bookTickets({
    required String eventId,
    required List<Map<String, dynamic>> tickets,
    required Map<String, dynamic> userDetails,
  }) async {
    // Convert old format to new format
    final selectedTickets = tickets;
    final attendees = [userDetails];
    
    return createOrder(
      eventId: eventId,
      selectedTickets: selectedTickets,
      attendees: attendees,
    );
  }
}