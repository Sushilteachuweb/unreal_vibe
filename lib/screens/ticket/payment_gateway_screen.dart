import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../home/bottom_navigation.dart';
import '../../utils/responsive_helper.dart';

import '../../providers/payment_provider.dart';
import '../../services/razorpay_service.dart';
import '../../services/dummy_razorpay_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final double totalAmount;
  final String eventName;
  final int ticketCount;
  final String userName;
  final String userEmail;
  final String whatsappNumber;

  const PaymentGatewayScreen({
    Key? key,
    required this.totalAmount,
    required this.eventName,
    required this.ticketCount,
    required this.userName,
    required this.userEmail,
    required this.whatsappNumber,
  }) : super(key: key);

  @override
  _PaymentGatewayScreenState createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  bool _useDummyRazorpay = true; // Toggle for testing
  bool _isUPIExpanded = false;
  late AnimationController _animationController;
  String? _selectedUPIOption;
  String _selectedPaymentMethod = 'UPI';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _upiOptions = [
    {'name': 'Google Pay', 'icon': Icons.payment, 'color': Color(0xFF4285F4)},
    {'name': 'PhonePe', 'icon': Icons.phone_android, 'color': Color(0xFF5F259F)},
    {'name': 'Paytm', 'icon': Icons.account_balance_wallet, 'color': Color(0xFF00B9F5)},
    {'name': 'Amazon Pay', 'icon': Icons.shopping_bag, 'color': Color(0xFFFF9900)},
  ];



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
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1625),
            const Color(0xFF1A1625).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E2740).withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B5FFF), Color(0xFF9D7FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
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
                _buildSummaryRow('Tickets', '${widget.ticketCount} × \$50.00', context),
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Total Amount',
                  '\$${widget.totalAmount.toStringAsFixed(2)}',
                  context,
                  isTotal: true,
                ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.grey[400],
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, isTotal ? 16 : 14),
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isTotal ? const Color(0xFF7B5FFF) : Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, isTotal ? 18 : 14),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildUPISection(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isUPIExpanded
              ? [const Color(0xFF2A1F3D), const Color(0xFF1A1625)]
              : [const Color(0xFF1A1625), const Color(0xFF1A1625)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isUPIExpanded ? const Color(0xFF7B5FFF) : const Color(0xFF2E2740).withOpacity(0.5),
          width: _isUPIExpanded ? 2 : 1,
        ),
        boxShadow: _isUPIExpanded
            ? [
          BoxShadow(
            color: const Color(0xFF7B5FFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() => _isUPIExpanded = !_isUPIExpanded);
              if (_isUPIExpanded) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B5FFF), Color(0xFF9D7FFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B5FFF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UPI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Instant & Secure',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isUPIExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E2740).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isUPIExpanded) ...[
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.4,
                ),
                itemCount: _upiOptions.length,
                itemBuilder: (context, index) {
                  return _buildUPIOption(_upiOptions[index], context);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUPIOption(Map<String, dynamic> option, BuildContext context) {
    final isSelected = _selectedUPIOption == option['name'];

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedUPIOption = option['name']!;
          _selectedPaymentMethod = 'UPI - ${option['name']}';
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A1F3D) : const Color(0xFF0F0F17),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF7B5FFF) : const Color(0xFF2E2740).withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF7B5FFF).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? option['color'].withOpacity(0.2) : const Color(0xFF1A1625),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? option['color'].withOpacity(0.5) : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Icon(
                option['icon'],
                color: isSelected ? option['color'] : Colors.grey[400],
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option['name']!,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[400],
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 11),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected) ...[
              const SizedBox(height: 2),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF7B5FFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions(BuildContext context) {
    return Column(
      children: [
        _buildPaymentOption(
          'Debit/Credit Cards',
          Icons.credit_card,
          'Visa, Mastercard, Rupay',
              () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedPaymentMethod = 'Debit/Credit Cards';
              _isUPIExpanded = false;
              _selectedUPIOption = '';
            });
          },
          context,
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          'Wallet',
          Icons.account_balance_wallet_outlined,
          'Paytm, PhonePe, Amazon Pay',
              () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedPaymentMethod = 'Wallet';
              _isUPIExpanded = false;
              _selectedUPIOption = '';
            });
          },
          context,
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          'Net Banking',
          Icons.account_balance,
          'All major banks supported',
              () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedPaymentMethod = 'Net Banking';
              _isUPIExpanded = false;
              _selectedUPIOption = '';
            });
          },
          context,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
      String title,
      IconData icon,
      String subtitle,
      VoidCallback onTap,
      BuildContext context,
      ) {
    final isSelected = _selectedPaymentMethod == title;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF2A1F3D), Color(0xFF1A1625)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [const Color(0xFF1A1625), const Color(0xFF1A1625)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF7B5FFF) : const Color(0xFF2E2740).withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF7B5FFF).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [Color(0xFF7B5FFF), Color(0xFF9D7FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [const Color(0xFF2E2740), const Color(0xFF2E2740)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: const Color(0xFF7B5FFF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF7B5FFF).withOpacity(0.2)
                    : const Color(0xFF2E2740).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
                color: isSelected ? const Color(0xFF7B5FFF) : Colors.grey[400],
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1625).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2E2740).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9A5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified_user,
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
                  '100% Secure Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your payment information is encrypted',
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
        switch (index) {
          case 0: // Home
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            break;
          case 1: // Explore
            Navigator.pushNamedAndRemoveUntil(context, '/explore', (route) => false);
            break;
          case 2: // Host
            // Navigate to host/create event screen
            Navigator.pushNamed(context, '/host');
            break;
          case 3: // Tickets - already here
            break;
          case 4: // Profile
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
    );
  }

  void _handlePayment() async {
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    // Use dummy or real Razorpay based on toggle
    if (_useDummyRazorpay) {
      _handleDummyPayment();
    } else {
      _handleRealPayment();
    }
  }

  void _handleDummyPayment() {
    final dummyRazorpayService = DummyRazorpayService();
    
    dummyRazorpayService.initialize(
      onPaymentSuccess: (DummyPaymentSuccessResponse response) {
        setState(() => _isProcessing = false);
        _showPaymentSuccessDialog(
          paymentId: response.paymentId,
          orderId: response.orderId,
        );
      },
      onPaymentError: (DummyPaymentFailureResponse response) {
        setState(() => _isProcessing = false);
        _showPaymentErrorDialog(response.message);
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
    
    setState(() => _isProcessing = false);
  }

  // Real Razorpay implementation (commented out for now)
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
                            '\$${widget.totalAmount.toStringAsFixed(2)}',
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
                      // Navigate to tickets screen - go back to main navigation and select tickets tab
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
                    // Navigate back to home - go back to main navigation and select home tab
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