import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../home/bottom_navigation.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/payment_provider.dart';
import '../../services/razorpay_service.dart';
import '../../services/dummy_razorpay_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SimplifiedPaymentGatewayScreen extends StatefulWidget {
  final double totalAmount;
  final String eventName;
  final int ticketCount;
  final String userName;
  final String userEmail;
  final String whatsappNumber;

  const SimplifiedPaymentGatewayScreen({
    Key? key,
    required this.totalAmount,
    required this.eventName,
    required this.ticketCount,
    required this.userName,
    required this.userEmail,
    required this.whatsappNumber,
  }) : super(key: key);

  @override
  _SimplifiedPaymentGatewayScreenState createState() => _SimplifiedPaymentGatewayScreenState();
}

class _SimplifiedPaymentGatewayScreenState extends State<SimplifiedPaymentGatewayScreen> {
  bool _isProcessing = false;
  bool _useDummyRazorpay = true; // Toggle for testing

  @override
  Widget build(BuildContext context) {
    final double padding = ResponsiveHelper.getResponsivePadding(context, 16.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummary(context),
                    const SizedBox(height: 32),
                    _buildSecurityBadge(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPayButton(context, padding),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0F),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF2E2740).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1B2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Secure Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SSL Encrypted',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Debug toggle for testing
          GestureDetector(
            onTap: () {
              setState(() {
                _useDummyRazorpay = !_useDummyRazorpay;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_useDummyRazorpay ? 'Using Dummy Razorpay' : 'Using Real Razorpay'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _useDummyRazorpay ? Colors.orange : Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _useDummyRazorpay ? 'DEMO' : 'LIVE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1625), Color(0xFF0F0F17)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2E2740).withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B5FFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFF7B5FFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Order Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F17),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Event', widget.eventName, context),
                const SizedBox(height: 12),
                _buildSummaryRow('Tickets', '${widget.ticketCount} x Ticket', context),
                const SizedBox(height: 12),
                _buildSummaryRow('Name', widget.userName, context),
                const SizedBox(height: 12),
                _buildSummaryRow('Email', widget.userEmail, context),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF2E2740),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Total Amount', '₹${widget.totalAmount.toStringAsFixed(2)}', context, isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, BuildContext context, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.grey[400],
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, isTotal ? 16 : 14),
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? const Color(0xFF7B5FFF) : Colors.white,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, isTotal ? 18 : 14),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1625),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2E2740).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9A5).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.security,
              color: Color(0xFF00D9A5),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your payment is secured with 256-bit SSL encryption',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(BuildContext context, double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 12, padding, 8),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B5FFF), Color(0xFF9D7FFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B5FFF).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: !_isProcessing ? _handlePayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Pay ₹${widget.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return CustomBottomNavigation(
      currentIndex: 3, // Tickets tab is active
      onTap: (index) {
        // Navigate to the selected tab
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/main',
          (route) => false,
          arguments: index,
        );
      },
    );
  }

  void _handlePayment() async {
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    try {
      // Use dummy or real Razorpay based on toggle
      if (_useDummyRazorpay) {
        _handleDummyPayment();
      } else {
        _handleRealPayment();
      }
    } catch (e) {
      // Safety fallback - reset processing state if something goes wrong
      if (mounted) {
        setState(() => _isProcessing = false);
        _showPaymentErrorDialog('Payment initialization failed: $e');
      }
    }
  }

  void _handleDummyPayment() {
    final dummyRazorpayService = DummyRazorpayService();
    
    dummyRazorpayService.initialize(
      onPaymentSuccess: (DummyPaymentSuccessResponse response) {
        if (mounted) {
          setState(() => _isProcessing = false);
          _showPaymentSuccessDialog(
            paymentId: response.paymentId,
            orderId: response.orderId,
          );
        }
      },
      onPaymentError: (DummyPaymentFailureResponse response) {
        if (mounted) {
          setState(() => _isProcessing = false);
          _showPaymentErrorDialog(response.message);
        }
      },
    );

    // Open dummy Razorpay checkout
    dummyRazorpayService.openCheckout(
      context: context,
      amount: widget.totalAmount,
      name: widget.userName,
      email: widget.userEmail,
      contact: widget.whatsappNumber,
      description: 'Ticket for ${widget.eventName}',
    );
    
    // Safety timeout - reset processing state after 30 seconds if no callback
    Timer(const Duration(seconds: 30), () {
      if (mounted && _isProcessing) {
        setState(() => _isProcessing = false);
        _showPaymentErrorDialog('Payment timeout. Please try again.');
      }
    });
  }

  // Real Razorpay implementation
  void _handleRealPayment() async {
    try {
      final paymentProvider = context.read<PaymentProvider>();
      
      // Create payment request
      final paymentRequest = PaymentRequest(
        eventId: 'event_${DateTime.now().millisecondsSinceEpoch}',
        eventName: widget.eventName,
        quantity: widget.ticketCount,
        amount: widget.totalAmount,
        ticketType: 'Event Ticket',
        userDetails: {
          'name': widget.userName,
          'email': widget.userEmail,
          'phone': widget.whatsappNumber,
        },
      );

      // Initialize Razorpay service
      final razorpayService = RazorpayService();
      razorpayService.initialize(
        onPaymentSuccess: (PaymentSuccessResponse response) async {
          setState(() => _isProcessing = false);
          
          // Verify payment on backend
          final isVerified = await paymentProvider.verifyPayment(
            paymentId: response.paymentId!,
            orderId: response.orderId!,
            signature: response.signature!,
            bookingDetails: paymentRequest.toJson(),
          );

          if (isVerified) {
            _showPaymentSuccessDialog(
              paymentId: response.paymentId!,
              orderId: response.orderId!,
            );
          } else {
            _showPaymentErrorDialog('Payment verification failed');
          }
        },
        onPaymentError: (PaymentFailureResponse response) {
          setState(() => _isProcessing = false);
          _showPaymentErrorDialog(response.message ?? 'Payment failed');
        },
        onExternalWallet: (ExternalWalletResponse response) {
          setState(() => _isProcessing = false);
          debugPrint('External wallet selected: ${response.walletName}');
        },
      );

      // Create order and open Razorpay
      final orderData = await paymentProvider.createOrder(
        amount: widget.totalAmount,
        currency: 'INR',
        notes: {
          'event_name': widget.eventName,
          'ticket_count': widget.ticketCount.toString(),
          'user_name': widget.userName,
          'user_email': widget.userEmail,
        },
      );

      if (orderData != null) {
        razorpayService.openCheckout(
          orderId: orderData['id'],
          amount: widget.totalAmount,
          name: widget.userName,
          email: widget.userEmail,
          contact: widget.whatsappNumber,
          description: 'Ticket for ${widget.eventName}',
          prefillName: widget.userName,
          prefillEmail: widget.userEmail,
          prefillContact: widget.whatsappNumber,
        );
      } else {
        setState(() => _isProcessing = false);
        _showPaymentErrorDialog('Failed to create order. Please try again.');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showPaymentErrorDialog('Payment processing error: $e');
    }
  }

  void _showPaymentErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1625), Color(0xFF0F0F17)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment Failed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  void _showPaymentSuccessDialog({String? paymentId, String? orderId}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1625), Color(0xFF0F0F17)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF7B5FFF), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B5FFF).withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D9A5), Color(0xFF00B894)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D9A5).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Payment Successful!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 22),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your tickets have been confirmed',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F17),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount Paid',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '₹${widget.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF7B5FFF),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Razorpay',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (paymentId != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Payment ID',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              paymentId.substring(0, 12) + '...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B5FFF), Color(0xFF9D7FFF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B5FFF).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to tickets screen
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/main',
                        (route) => false,
                        arguments: 3, // Tickets tab index
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'View My Tickets',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Navigate back to home
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/main',
                      (route) => false,
                      arguments: 0, // Home tab index
                    );
                  },
                  child: Text(
                    'Back to Home',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
}