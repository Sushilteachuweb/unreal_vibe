import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/phonepe_config.dart';

class PhonePeService {
  static final PhonePeService _instance = PhonePeService._internal();
  factory PhonePeService() => _instance;
  PhonePeService._internal();

  Function(PhonePePaymentSuccessResponse)? _onPaymentSuccess;
  Function(PhonePePaymentFailureResponse)? _onPaymentError;
  Function(PhonePeExternalWalletResponse)? _onExternalWallet;

  void initialize({
    required Function(PhonePePaymentSuccessResponse) onPaymentSuccess,
    required Function(PhonePePaymentFailureResponse) onPaymentError,
    required Function(PhonePeExternalWalletResponse) onExternalWallet,
  }) {
    _onPaymentSuccess = onPaymentSuccess;
    _onPaymentError = onPaymentError;
    _onExternalWallet = onExternalWallet;
  }

  /// Generate a unique transaction ID
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'TXN_${timestamp}_$random';
  }

  /// Generate SHA256 hash for PhonePe API
  String _generateHash(String payload) {
    final saltKey = PhonePeConfig.currentSaltKey;
    final saltIndex = PhonePeConfig.saltIndex;
    final hashString = '$payload/pg/v1/pay$saltKey';
    final bytes = utf8.encode(hashString);
    final digest = sha256.convert(bytes);
    return '${digest.toString()}###$saltIndex';
  }

  /// Create PhonePe payment request
  Future<Map<String, dynamic>> createPaymentRequest({
    required String orderId,
    required double amount,
    required String name,
    required String email,
    required String contact,
    required String description,
    String? callbackUrl,
  }) async {
    try {
      final transactionId = _generateTransactionId();
      final amountInPaise = (amount * 100).toInt();
      
      final paymentRequest = {
        'merchantId': PhonePeConfig.currentMerchantId,
        'merchantTransactionId': transactionId,
        'merchantUserId': 'USER_${DateTime.now().millisecondsSinceEpoch}',
        'amount': amountInPaise,
        'redirectUrl': callbackUrl ?? 'https://webhook.site/redirect-url',
        'redirectMode': 'POST',
        'callbackUrl': callbackUrl ?? 'https://webhook.site/callback-url',
        'mobileNumber': contact,
        'paymentInstrument': {
          'type': 'PAY_PAGE'
        }
      };

      final payload = base64Encode(utf8.encode(json.encode(paymentRequest)));
      final hash = _generateHash(payload);

      return {
        'request': payload,
        'hash': hash,
        'transactionId': transactionId,
        'merchantId': PhonePeConfig.currentMerchantId,
      };
    } catch (e) {
      debugPrint('Error creating PhonePe payment request: $e');
      rethrow;
    }
  }

  /// Initiate PhonePe payment
  Future<void> openCheckout({
    required String orderId,
    required double amount,
    required String name,
    required String email,
    required String contact,
    required String description,
    String? prefillName,
    String? prefillEmail,
    String? prefillContact,
  }) async {
    try {
      // Create payment request
      final paymentData = await createPaymentRequest(
        orderId: orderId,
        amount: amount,
        name: prefillName ?? name,
        email: prefillEmail ?? email,
        contact: prefillContact ?? contact,
        description: description,
      );

      // Make API call to PhonePe
      final response = await http.post(
        Uri.parse('${PhonePeConfig.currentBaseUrl}/pg/v1/pay'),
        headers: {
          'Content-Type': 'application/json',
          'X-VERIFY': paymentData['hash'],
        },
        body: json.encode({
          'request': paymentData['request'],
        }),
      );

      debugPrint('PhonePe API Response Status: ${response.statusCode}');
      debugPrint('PhonePe API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final paymentUrl = responseData['data']['instrumentResponse']['redirectInfo']['url'];
          
          // Launch PhonePe payment URL
          final uri = Uri.parse(paymentUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            
            // For now, simulate success after a delay
            // In a real app, you'd handle the callback from PhonePe
            await Future.delayed(const Duration(seconds: 3));
            _simulatePaymentSuccess(paymentData['transactionId'], orderId);
          } else {
            throw Exception('Could not launch PhonePe payment URL');
          }
        } else {
          throw Exception(responseData['message'] ?? 'Payment initiation failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Payment initiation failed');
      }
    } catch (e) {
      debugPrint('Error opening PhonePe checkout: $e');
      _onPaymentError?.call(PhonePePaymentFailureResponse(
        code: 'PAYMENT_INITIATION_FAILED',
        description: e.toString(),
        source: 'phonepe_service',
        step: 'payment_initiation',
        reason: 'api_error',
      ));
    }
  }

  /// Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    try {
      final merchantId = PhonePeConfig.currentMerchantId;
      final saltKey = PhonePeConfig.currentSaltKey;
      final saltIndex = PhonePeConfig.saltIndex;
      
      final hashString = '/pg/v1/status/$merchantId/$transactionId$saltKey';
      final bytes = utf8.encode(hashString);
      final digest = sha256.convert(bytes);
      final hash = '${digest.toString()}###$saltIndex';

      final response = await http.get(
        Uri.parse('${PhonePeConfig.currentBaseUrl}/pg/v1/status/$merchantId/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'X-VERIFY': hash,
          'X-MERCHANT-ID': merchantId,
        },
      );

      debugPrint('PhonePe Status Check Response: ${response.statusCode}');
      debugPrint('PhonePe Status Check Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check payment status');
      }
    } catch (e) {
      debugPrint('Error checking payment status: $e');
      rethrow;
    }
  }

  /// Simulate payment success (for testing)
  void _simulatePaymentSuccess(String transactionId, String orderId) {
    final response = PhonePePaymentSuccessResponse(
      paymentId: 'phonepe_$transactionId',
      orderId: orderId,
      transactionId: transactionId,
      method: 'PhonePe',
      signature: 'phonepe_signature_${DateTime.now().millisecondsSinceEpoch}',
    );
    _onPaymentSuccess?.call(response);
  }

  void dispose() {
    _onPaymentSuccess = null;
    _onPaymentError = null;
    _onExternalWallet = null;
  }
}

// Payment Models
class PhonePePaymentRequest {
  final String eventId;
  final String eventName;
  final int quantity;
  final double amount;
  final String ticketType;
  final Map<String, dynamic> userDetails;

  PhonePePaymentRequest({
    required this.eventId,
    required this.eventName,
    required this.quantity,
    required this.amount,
    required this.ticketType,
    required this.userDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'event_name': eventName,
      'quantity': quantity,
      'amount': amount,
      'ticket_type': ticketType,
      'user_details': userDetails,
    };
  }
}

class PhonePePaymentSuccessResponse {
  final String paymentId;
  final String orderId;
  final String transactionId;
  final String method;
  final String signature;

  PhonePePaymentSuccessResponse({
    required this.paymentId,
    required this.orderId,
    required this.transactionId,
    required this.method,
    required this.signature,
  });

  // For compatibility with existing Razorpay code
  String get razorpayPaymentId => paymentId;
  String get razorpaySignature => signature;
}

class PhonePePaymentFailureResponse {
  final String code;
  final String description;
  final String source;
  final String step;
  final String reason;

  PhonePePaymentFailureResponse({
    required this.code,
    required this.description,
    required this.source,
    required this.step,
    required this.reason,
  });

  String get message => description;
}

class PhonePeExternalWalletResponse {
  final String walletName;

  PhonePeExternalWalletResponse({
    required this.walletName,
  });
}

class PhonePePaymentResult {
  final bool success;
  final String? paymentId;
  final String? orderId;
  final String? transactionId;
  final String? signature;
  final String? errorMessage;
  final String? errorCode;

  PhonePePaymentResult({
    required this.success,
    this.paymentId,
    this.orderId,
    this.transactionId,
    this.signature,
    this.errorMessage,
    this.errorCode,
  });

  factory PhonePePaymentResult.success({
    required String paymentId,
    required String orderId,
    required String transactionId,
    required String signature,
  }) {
    return PhonePePaymentResult(
      success: true,
      paymentId: paymentId,
      orderId: orderId,
      transactionId: transactionId,
      signature: signature,
    );
  }

  factory PhonePePaymentResult.failure({
    required String errorMessage,
    String? errorCode,
  }) {
    return PhonePePaymentResult(
      success: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }
}