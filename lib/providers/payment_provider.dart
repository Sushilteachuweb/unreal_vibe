import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/phonepe_service.dart';
import '../services/user_storage.dart';
import '../services/api_routes.dart';

class PaymentProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  PhonePePaymentResult? _lastPaymentResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PhonePePaymentResult? get lastPaymentResult => _lastPaymentResult;

  // Your backend API base URL
  static const String _baseUrl = 'http://api.unrealvibe.com'; // Replace with your actual API URL

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Create PhonePe order on your backend
  Future<Map<String, dynamic>?> createOrder({
    required double amount,
    required String currency,
    required Map<String, dynamic> notes,
  }) async {
    try {
      setLoading(true);
      clearError();

      // Get authentication headers
      final token = await UserStorage.getToken();
      final headers = token != null 
          ? await ApiConfig.getAuthHeadersWithCookies(token)
          : ApiConfig.headers;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/payment/create-order'),
        headers: headers,
        body: json.encode({
          'amount': (amount * 100).toInt(), // Convert to paise
          'currency': currency,
          'notes': notes,
          'payment_gateway': 'phonepe', // Specify PhonePe as payment gateway
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        setError('Failed to create order: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      setError('Network error: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  // Verify payment on your backend
  Future<bool> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
    String? transactionId,
    required Map<String, dynamic> bookingDetails,
  }) async {
    try {
      setLoading(true);
      clearError();

      // Get authentication headers
      final token = await UserStorage.getToken();
      final headers = token != null 
          ? await ApiConfig.getAuthHeadersWithCookies(token)
          : ApiConfig.headers;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/payment/verify'),
        headers: headers,
        body: json.encode({
          'phonepe_payment_id': paymentId,
          'phonepe_order_id': orderId,
          'phonepe_signature': signature,
          if (transactionId != null) 'phonepe_transaction_id': transactionId,
          'payment_gateway': 'phonepe',
          'booking_details': bookingDetails,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        setError('Payment verification failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      setError('Verification error: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Complete booking process
  Future<bool> processPayment({
    required PhonePePaymentRequest paymentRequest,
    required String userToken, // If you have user authentication
  }) async {
    try {
      setLoading(true);
      clearError();

      // Step 1: Create order on backend
      final orderData = await createOrder(
        amount: paymentRequest.amount,
        currency: 'INR',
        notes: {
          'event_id': paymentRequest.eventId,
          'event_name': paymentRequest.eventName,
          'ticket_type': paymentRequest.ticketType,
          'quantity': paymentRequest.quantity.toString(),
        },
      );

      if (orderData == null) {
        return false;
      }

      // Step 2: Open PhonePe checkout
      final phonePeService = PhonePeService();
      
      // Initialize PhonePe with callbacks
      phonePeService.initialize(
        onPaymentSuccess: (response) async {
          // Step 3: Verify payment on backend
          final isVerified = await verifyPayment(
            paymentId: response.paymentId,
            orderId: response.orderId,
            signature: response.signature,
            transactionId: response.transactionId,
            bookingDetails: paymentRequest.toJson(),
          );

          if (isVerified) {
            _lastPaymentResult = PhonePePaymentResult.success(
              paymentId: response.paymentId,
              orderId: response.orderId,
              transactionId: response.transactionId,
              signature: response.signature,
            );
          } else {
            _lastPaymentResult = PhonePePaymentResult.failure(
              errorMessage: 'Payment verification failed',
            );
          }
          notifyListeners();
        },
        onPaymentError: (response) {
          _lastPaymentResult = PhonePePaymentResult.failure(
            errorMessage: response.message,
            errorCode: response.code,
          );
          notifyListeners();
        },
        onExternalWallet: (response) {
          debugPrint('External wallet selected: ${response.walletName}');
        },
      );

      // Open PhonePe checkout
      await phonePeService.openCheckout(
        orderId: orderData['id'],
        amount: paymentRequest.amount,
        name: paymentRequest.userDetails['name'] ?? 'User',
        email: paymentRequest.userDetails['email'] ?? '',
        contact: paymentRequest.userDetails['phone'] ?? '',
        description: 'Ticket for ${paymentRequest.eventName}',
        prefillName: paymentRequest.userDetails['name'],
        prefillEmail: paymentRequest.userDetails['email'],
        prefillContact: paymentRequest.userDetails['phone'],
      );

      return true;
    } catch (e) {
      setError('Payment processing error: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Get payment history (optional)
  Future<List<Map<String, dynamic>>> getPaymentHistory(String userId) async {
    try {
      setLoading(true);
      clearError();

      // Get authentication headers
      final token = await UserStorage.getToken();
      final headers = token != null 
          ? await ApiConfig.getAuthHeadersWithCookies(token)
          : ApiConfig.headers;

      final response = await http.get(
        Uri.parse('$_baseUrl/api/payment/history/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['payments'] ?? []);
      } else {
        setError('Failed to fetch payment history');
        return [];
      }
    } catch (e) {
      setError('Network error: $e');
      return [];
    } finally {
      setLoading(false);
    }
  }

  void clearLastPaymentResult() {
    _lastPaymentResult = null;
    notifyListeners();
  }
}