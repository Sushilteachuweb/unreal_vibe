import 'package:flutter/material.dart';
import 'dart:async';

class DummyRazorpayService {
  static final DummyRazorpayService _instance = DummyRazorpayService._internal();
  factory DummyRazorpayService() => _instance;
  DummyRazorpayService._internal();

  Function(DummyPaymentSuccessResponse)? _onPaymentSuccess;
  Function(DummyPaymentFailureResponse)? _onPaymentError;

  void initialize({
    required Function(DummyPaymentSuccessResponse) onPaymentSuccess,
    required Function(DummyPaymentFailureResponse) onPaymentError,
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
    _showDummyRazorpayDialog(
      context: context,
      amount: amount,
      name: name,
      email: email,
      contact: contact,
      description: description,
    );
  }

  void _showDummyRazorpayDialog({
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
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Razorpay Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3395FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'R',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Razorpay',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Payment Details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pay to Unreal Vibe',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Payment Methods
                const Text(
                  'Choose Payment Method',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                // UPI Option
                _buildPaymentMethodTile(
                  context: context,
                  icon: Icons.account_balance_wallet,
                  title: 'UPI',
                  subtitle: 'Pay using UPI apps',
                  onTap: () => _simulatePayment(context, 'UPI', true),
                ),
                const SizedBox(height: 8),
                
                // Card Option
                _buildPaymentMethodTile(
                  context: context,
                  icon: Icons.credit_card,
                  title: 'Card',
                  subtitle: 'Debit/Credit Card',
                  onTap: () => _simulatePayment(context, 'Card', true),
                ),
                const SizedBox(height: 8),
                
                // Net Banking Option
                _buildPaymentMethodTile(
                  context: context,
                  icon: Icons.account_balance,
                  title: 'Net Banking',
                  subtitle: 'All major banks',
                  onTap: () => _simulatePayment(context, 'Net Banking', true),
                ),
                const SizedBox(height: 8),
                
                // Wallet Option
                _buildPaymentMethodTile(
                  context: context,
                  icon: Icons.wallet,
                  title: 'Wallet',
                  subtitle: 'Paytm, PhonePe, etc.',
                  onTap: () => _simulatePayment(context, 'Wallet', true),
                ),
                const SizedBox(height: 16),
                
                // Test Failure Button
                TextButton(
                  onPressed: () => _simulatePayment(context, 'Test', false),
                  child: const Text(
                    'Test Payment Failure',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3395FF), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  void _simulatePayment(BuildContext context, String method, bool success) {
    // Close the payment dialog first
    Navigator.pop(context);
    
    // Immediately trigger the callback without showing loading
    // This simulates instant payment processing
    if (success) {
      final response = DummyPaymentSuccessResponse(
        paymentId: 'pay_dummy_${DateTime.now().millisecondsSinceEpoch}',
        orderId: 'order_dummy_${DateTime.now().millisecondsSinceEpoch}',
        signature: 'dummy_signature_${DateTime.now().millisecondsSinceEpoch}',
        method: method,
      );
      _onPaymentSuccess?.call(response);
    } else {
      final response = DummyPaymentFailureResponse(
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

class DummyPaymentSuccessResponse {
  final String paymentId;
  final String orderId;
  final String signature;
  final String method;

  DummyPaymentSuccessResponse({
    required this.paymentId,
    required this.orderId,
    required this.signature,
    required this.method,
  });
}

class DummyPaymentFailureResponse {
  final String code;
  final String description;
  final String source;
  final String step;
  final String reason;

  DummyPaymentFailureResponse({
    required this.code,
    required this.description,
    required this.source,
    required this.step,
    required this.reason,
  });

  String get message => description;
}