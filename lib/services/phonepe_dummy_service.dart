import 'package:flutter/material.dart';

class DummyPhonePeService {
  static final DummyPhonePeService _instance = DummyPhonePeService._internal();
  factory DummyPhonePeService() => _instance;
  DummyPhonePeService._internal();

  Function(DummyPhonePePaymentSuccessResponse)? _onPaymentSuccess;
  Function(DummyPhonePePaymentFailureResponse)? _onPaymentError;

  void initialize({
    required Function(DummyPhonePePaymentSuccessResponse) onPaymentSuccess,
    required Function(DummyPhonePePaymentFailureResponse) onPaymentError,
  }) {
    _onPaymentSuccess = onPaymentSuccess;
    _onPaymentError = onPaymentError;
  }

  void openCheckout({
    required BuildContext context,
    required double amount,
    required String name,
    required String email,
    required String contact,
    required String description,
  }) {
    _showDummyPhonePeDialog(
      context: context,
      amount: amount,
      name: name,
      email: email,
      contact: contact,
      description: description,
    );
  }

  void _showDummyPhonePeDialog({
    required BuildContext context,
    required double amount,
    required String name,
    required String email,
    required String contact,
    required String description,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF5F259F),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Text(
                    'P',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('PhonePe Payment'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text('Amount: ₹${amount.toStringAsFixed(2)}'),
                    Text('Description: $description'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Choose Payment Method:'),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _simulatePayment(context, 'UPI', true),
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('Pay with UPI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F259F),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _simulatePayment(context, 'PhonePe Wallet', true),
                  icon: const Icon(Icons.wallet),
                  label: const Text('PhonePe Wallet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F259F),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _simulatePayment(context, 'Card', true),
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Pay with Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F259F),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _simulatePayment(context, 'Test', false),
                child: const Text(
                  'Simulate Payment Failure',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _simulatePayment(BuildContext context, String method, bool success) {
    Navigator.pop(context);
    
    if (success) {
      final response = DummyPhonePePaymentSuccessResponse(
        paymentId: 'phonepe_dummy_${DateTime.now().millisecondsSinceEpoch}',
        orderId: 'order_dummy_${DateTime.now().millisecondsSinceEpoch}',
        transactionId: 'txn_dummy_${DateTime.now().millisecondsSinceEpoch}',
        signature: 'dummy_signature_${DateTime.now().millisecondsSinceEpoch}',
        method: method,
      );
      _onPaymentSuccess?.call(response);
    } else {
      final response = DummyPhonePePaymentFailureResponse(
        code: 'PAYMENT_CANCELLED',
        description: 'Payment was cancelled by user',
        source: 'customer',
        step: 'payment_authentication',
        reason: 'user_cancelled',
      );
      _onPaymentError?.call(response);
    }
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