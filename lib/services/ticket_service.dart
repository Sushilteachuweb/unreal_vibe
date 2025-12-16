import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket_model.dart';
import 'api_routes.dart';
import 'user_storage.dart';

class TicketService {
  /// Fetch passes for a specific event
  static Future<List<TicketType>> fetchEventPasses(String eventId) async {
    try {
      final endpoint = ApiConfig.getEventPasses(eventId);
      print('Fetching event passes from: $endpoint');
      
      // Get auth token
      final token = await UserStorage.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
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
      print('Creating order at: $endpoint');
      
      // Convert selectedTickets to items format with price
      final items = selectedTickets.map((ticket) {
        return {
          'passType': ticket['type'],
          'price': ticket['price'] ?? 0, // Include price from ticket selection
          'quantity': ticket['quantity'],
        };
      }).toList();
      
      final requestBody = {
        'eventId': eventId,
        'items': items,
        'attendees': attendees,
      };
      
      print('Create Order Request Body: ${json.encode(requestBody)}');
      
      // Get auth token
      final token = await UserStorage.getToken();
      final isLoggedIn = await UserStorage.getLoginStatus();
      
      if (token == null || !isLoggedIn) {
        throw Exception('AUTHENTICATION_REQUIRED');
      }
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: ApiConfig.getAuthHeaders(token),
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print('Create Order API Response Status: ${response.statusCode}');
      print('Create Order API Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Order creation failed');
        }
      } else if (response.statusCode == 401) {
        // Handle authentication error
        await UserStorage.clearAll(); // Clear invalid token
        throw Exception('AUTHENTICATION_REQUIRED');
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Order creation failed: HTTP ${response.statusCode}');
        } catch (e) {
          throw Exception('Order creation failed: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  /// Verify payment with backend
  static Future<Map<String, dynamic>> verifyPayment({
    required String eventId,
    required String orderId,
    required String razorpayPaymentId,
    String? razorpaySignature,
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
      
      final requestBody = {
        'razorpay_order_id': orderId,
        'eventId': eventId,
        if (items != null) 'items': items,
        if (attendees != null) 'attendees': attendees,
        // Note: razorpayPaymentId and razorpaySignature might be added later for actual payment
      };
      
      print('Verify Payment Request Body: ${json.encode(requestBody)}');
      
      // Get auth token
      final token = await UserStorage.getToken();
      final isLoggedIn = await UserStorage.getLoginStatus();
      
      if (token == null || !isLoggedIn) {
        throw Exception('AUTHENTICATION_REQUIRED');
      }
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: ApiConfig.getAuthHeaders(token),
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