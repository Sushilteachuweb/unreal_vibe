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
        return Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: 600,
              maxWidth: 400,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5F259F),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            'P',
                            style: TextStyle(
                              color: Color(0xFF5F259F),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'PhonePe Payment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Amount Display
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Amount: ₹${amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                description,
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        const Text(
                          'Choose Payment Method:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Payment Methods
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _simulatePayment(context, 'UPI', true),
                            icon: const Icon(Icons.account_balance_wallet),
                            label: const Text('Pay with UPI'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5F259F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _simulatePayment(context, 'PhonePe Wallet', true),
                            icon: const Icon(Icons.wallet),
                            label: const Text('PhonePe Wallet'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5F259F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _simulatePayment(context, 'Card', true),
                            icon: const Icon(Icons.credit_card),
                            label: const Text('Pay with Card'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5F259F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        TextButton(
                          onPressed: () => _simulatePayment(context, 'Test', false),
                          child: const Text(
                            'Simulate Payment Failure',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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