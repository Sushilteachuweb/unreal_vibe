import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/razorpay_service.dart';

class PaymentProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  PaymentResult? _lastPaymentResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PaymentResult? get lastPaymentResult => _lastPaymentResult;

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

  // Create Razorpay order on your backend
  Future<Map<String, dynamic>?> createOrder({
    required double amount,
    required String currency,
    required Map<String, dynamic> notes,
  }) async {
    try {
      setLoading(true);
      clearError();

      final response = await http.post(
        Uri.parse('$_baseUrl/api/payment/create-order'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': (amount * 100).toInt(), // Convert to paise
          'currency': currency,
          'notes': notes,
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
    required Map<String, dynamic> bookingDetails,
  }) async {
    try {
      setLoading(true);
      clearError();

      final response = await http.post(
        Uri.parse('$_baseUrl/api/payment/verify'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'payment_id': paymentId,
          'order_id': orderId,
          'signature': signature,
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
    required PaymentRequest paymentRequest,
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

      // Step 2: Open Razorpay checkout
      final razorpayService = RazorpayService();
      
      // Initialize Razorpay with callbacks
      razorpayService.initialize(
        onPaymentSuccess: (response) async {
          // Step 3: Verify payment on backend
          final isVerified = await verifyPayment(
            paymentId: response.paymentId!,
            orderId: response.orderId!,
            signature: response.signature!,
            bookingDetails: paymentRequest.toJson(),
          );

          if (isVerified) {
            _lastPaymentResult = PaymentResult.success(
              paymentId: response.paymentId!,
              orderId: response.orderId!,
              signature: response.signature!,
            );
          } else {
            _lastPaymentResult = PaymentResult.failure(
              errorMessage: 'Payment verification failed',
            );
          }
          notifyListeners();
        },
        onPaymentError: (response) {
          _lastPaymentResult = PaymentResult.failure(
            errorMessage: response.message ?? 'Payment failed',
            errorCode: response.code.toString(),
          );
          notifyListeners();
        },
        onExternalWallet: (response) {
          debugPrint('External wallet selected: ${response.walletName}');
        },
      );

      // Open Razorpay checkout
      razorpayService.openCheckout(
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

      final response = await http.get(
        Uri.parse('$_baseUrl/api/payment/history/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
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