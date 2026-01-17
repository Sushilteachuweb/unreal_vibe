import 'package:flutter/material.dart';

class DummyPhonePeService {
  void initialize({
    required Function(DummyPhonePePaymentSuccessResponse) onPaymentSuccess,
    required Function(DummyPhonePePaymentFailureResponse) onPaymentError,
  }) {
    // Implementation
  }

  void openCheckout({
    required BuildContext context,
    required double amount,
    required String name,
    required String email,
    required String contact,
    required String description,
  }) {
    // Simple implementation for testing
  }
}

class DummyPhonePePaymentSuccessResponse {
  final String paymentId;
  final String orderId;
  final String transactionId;
  final String signature;
  final String method;

  DummyPhonePePaymentSuccessResponse({
    required this.paymentId,
    required this.orderId,
    required this.transactionId,
    required this.signature,
    required this.method,
  });

  String get razorpayPaymentId => paymentId;
  String get razorpaySignature => signature;
}

class DummyPhonePePaymentFailureResponse {
  final String code;
  final String description;
  final String source;
  final String step;
  final String reason;

  DummyPhonePePaymentFailureResponse({
    required this.code,
    required this.description,
    required this.source,
    required this.step,
    required this.reason,
  });

  String get message => description;
}