import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../config/razorpay_config.dart';

class RazorpayService {
  static final RazorpayService _instance = RazorpayService._internal();
  factory RazorpayService() => _instance;
  RazorpayService._internal();

  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? _onPaymentSuccess;
  Function(PaymentFailureResponse)? _onPaymentError;
  Function(ExternalWalletResponse)? _onExternalWallet;

  void initialize({
    required Function(PaymentSuccessResponse) onPaymentSuccess,
    required Function(PaymentFailureResponse) onPaymentError,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _onPaymentSuccess = onPaymentSuccess;
    _onPaymentError = onPaymentError;
    _onExternalWallet = onExternalWallet;

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _onPaymentSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _onPaymentError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _onExternalWallet?.call(response);
  }

  void openCheckout({
    required String orderId,
    required double amount,
    required String name,
    required String email,
    required String contact,
    required String description,
    String? prefillName,
    String? prefillEmail,
    String? prefillContact,
  }) {
    var options = {
      'key': RazorpayConfig.currentKeyId,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': RazorpayConfig.companyName,
      'order_id': orderId,
      'description': description,
      'timeout': RazorpayConfig.paymentTimeout,
      'prefill': {
        'contact': prefillContact ?? contact,
        'email': prefillEmail ?? email,
        'name': prefillName ?? name,
      },
      'theme': {
        'color': '#6958CA',
      },
      'modal': {
        'ondismiss': () {
          debugPrint('Razorpay payment dismissed');
        }
      },
      'notes': {
        'event_booking': 'true',
        'platform': 'mobile_app',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}

// Payment Models
class PaymentRequest {
  final String eventId;
  final String eventName;
  final int quantity;
  final double amount;
  final String ticketType;
  final Map<String, dynamic> userDetails;

  PaymentRequest({
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

class PaymentResult {
  final bool success;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorMessage;
  final String? errorCode;

  PaymentResult({
    required this.success,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorMessage,
    this.errorCode,
  });

  factory PaymentResult.success({
    required String paymentId,
    required String orderId,
    required String signature,
  }) {
    return PaymentResult(
      success: true,
      paymentId: paymentId,
      orderId: orderId,
      signature: signature,
    );
  }

  factory PaymentResult.failure({
    required String errorMessage,
    String? errorCode,
  }) {
    return PaymentResult(
      success: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }
}