import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../models/ticket_model.dart';
import '../../models/attendee_model.dart';
import '../../models/purchased_ticket_model.dart';
import '../../services/dummy_razorpay_service.dart';
import '../../services/ticket_service.dart';
import 'payment_success_screen.dart';

class TicketConfirmationScreen extends StatefulWidget {
  final Event event;
  final List<TicketSelection> ticketSelections;
  final List<Attendee> attendees;
  final String orderId;
  final Map<String, dynamic> orderResponse;

  const TicketConfirmationScreen({
    Key? key,
    required this.event,
    required this.ticketSelections,
    required this.attendees,
    required this.orderId,
    required this.orderResponse,
  }) : super(key: key);

  @override
  State<TicketConfirmationScreen> createState() => _TicketConfirmationScreenState();
}

class _TicketConfirmationScreenState extends State<TicketConfirmationScreen> {
  final DummyRazorpayService _razorpayService = DummyRazorpayService();
  bool _isProcessingPayment = false;
  
  // Promo code related variables
  final TextEditingController _promoCodeController = TextEditingController();
  String? _appliedPromoCode;
  double _discountPercentage = 0.0;
  bool _isApplyingPromo = false;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpayService.initialize(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentError: _handlePaymentError,
    );
  }

  double get _subtotal {
    return widget.ticketSelections.fold(
      0.0,
      (sum, selection) => sum + selection.totalPrice,
    );
  }

  double get _discountAmount => _subtotal * (_discountPercentage / 100);
  double get _subtotalAfterDiscount => _subtotal - _discountAmount;
  double get _taxAmount => _subtotalAfterDiscount * 0.10; // 10% tax on discounted amount
  double get _total => _subtotalAfterDiscount + _taxAmount;

  void _applyPromoCode() async {
    final promoCode = _promoCodeController.text.trim().toUpperCase();
    
    if (promoCode.isEmpty) {
      _showErrorMessage('Please enter a promo code');
      return;
    }
    
    setState(() {
      _isApplyingPromo = true;
    });
    
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // For now, hardcode some promo codes for UI demonstration
    double discount = 0.0;
    bool isValid = false;
    
    switch (promoCode) {
      case 'UNREAL20':
        discount = 20.0;
        isValid = true;
        break;
      case 'SAVE10':
        discount = 10.0;
        isValid = true;
        break;
      case 'WELCOME15':
        discount = 15.0;
        isValid = true;
        break;
      case 'FIRST25':
        discount = 25.0;
        isValid = true;
        break;
      default:
        isValid = false;
    }
    
    setState(() {
      _isApplyingPromo = false;
      if (isValid) {
        _appliedPromoCode = promoCode;
        _discountPercentage = discount;
        _showSuccessMessage('Promo code "$promoCode" applied! ${discount.toInt()}% discount');
      } else {
        _showErrorMessage('Invalid promo code. Please try again.');
      }
    });
  }
  
  void _removePromoCode() {
    setState(() {
      _appliedPromoCode = null;
      _discountPercentage = 0.0;
      _promoCodeController.clear();
    });
    _showSuccessMessage('Promo code removed');
  }
  
  void _proceedToPayment() {
    // Get first attendee details for payment
    final firstAttendee = widget.attendees.first;
    
    // Open Razorpay checkout
    _razorpayService.openCheckout(
      context: context,
      amount: _total,
      name: firstAttendee.fullName,
      email: firstAttendee.email,
      contact: firstAttendee.phone,
      description: 'Ticket booking for ${widget.event.title}',
    );
  }
  
  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  void _handlePaymentSuccess(DummyPaymentSuccessResponse response) async {
    try {
      // Show loading
      _showLoadingDialog('Verifying payment...');

      // Prepare selected tickets data with price
      final selectedTickets = widget.ticketSelections.map((selection) => {
        'type': _formatTicketType(selection.ticketType.name),
        'price': selection.ticketType.price.toInt(),
        'quantity': selection.quantity,
      }).toList();

      // Prepare attendees data
      final attendeesData = widget.attendees.map((attendee) => attendee.toJson()).toList();

      // Verify payment with backend
      final verificationResponse = await TicketService.verifyPayment(
        eventId: widget.event.id,
        orderId: widget.orderId,
        razorpayPaymentId: response.paymentId,
        razorpaySignature: response.signature,
        selectedTickets: selectedTickets,
        attendees: attendeesData,
      );

      // Hide loading
      if (mounted) Navigator.of(context).pop();

      // Handle successful verification
      if (mounted) {
        _navigateToSuccessScreen(verificationResponse);
      }
    } catch (e) {
      // Hide loading
      if (mounted) Navigator.of(context).pop();
      
      _showErrorMessage('Payment verification failed: $e');
    }
  }

  void _handlePaymentError(DummyPaymentFailureResponse response) {
    _showErrorMessage('Payment failed: ${response.message}');
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF6958CA)),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSuccessScreen(Map<String, dynamic> verificationResponse) {
    try {
      final bookingResponse = BookingResponse.fromJson(verificationResponse);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            event: widget.event,
            bookingResponse: bookingResponse,
          ),
        ),
      );
    } catch (e) {
      print('Error parsing booking response: $e');
      // Fallback to simple success dialog
      _showSuccessDialog(verificationResponse);
    }
  }

  void _showSuccessDialog(Map<String, dynamic> verificationResponse) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF10B981),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your tickets have been confirmed.',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate back to home
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/main',
                  (route) => false,
                  arguments: 0, // Home tab index
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTicketType(String ticketTypeName) {
    return ticketTypeName
        .replaceAll(' PASS', '')
        .replaceAll('PASS', '')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
        .join(' ')
        .trim();
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confirm Booking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventCard(),
                  const SizedBox(height: 24),
                  _buildTicketSummary(),
                  const SizedBox(height: 24),
                  _buildPromoCodeSection(),
                  const SizedBox(height: 24),
                  _buildAttendeesList(),
                  const SizedBox(height: 24),
                  _buildPriceSummary(),
                ],
              ),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildEventCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              widget.event.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFF2A2A2A),
                  child: const Icon(Icons.event, color: Colors.white),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.event.date,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.event.location,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ticket Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.ticketSelections.map((selection) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${selection.ticketType.name} x ${selection.quantity}',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    '₹${selection.totalPrice.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Promo Code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_appliedPromoCode != null) ...[
            // Applied promo code display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appliedPromoCode!,
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_discountPercentage.toInt()}% discount applied',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _removePromoCode,
                    child: const Text(
                      'Remove',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Promo code input
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _promoCodeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                      filled: true,
                      fillColor: const Color(0xFF0A0A0A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isApplyingPromo ? null : _applyPromoCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isApplyingPromo
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Apply',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Try: UNREAL20, SAVE10, WELCOME15, FIRST25',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendeesList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendees',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Order: ${widget.orderId.substring(0, 12)}...',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.attendees.asMap().entries.map((entry) {
            final index = entry.key;
            final attendee = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${attendee.passType} Pass',
                          style: const TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Attendee ${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.person, attendee.fullName),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.email, attendee.email),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.phone, attendee.phone),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.wc, attendee.gender),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', _subtotal),
          if (_appliedPromoCode != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Discount ($_appliedPromoCode)',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_discountPercentage.toInt()}%',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '-₹${_discountAmount.toInt()}',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          _buildPriceRow('Tax (10%)', _taxAmount),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2A2A2A)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_appliedPromoCode != null && _discountAmount > 0) ...[
                    Text(
                      '₹${(_subtotal + (_subtotal * 0.10)).toInt()}',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    '₹${_total.toInt()}',
                    style: const TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 15,
          ),
        ),
        Text(
          '₹${amount.toInt()}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A2A)),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Order Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Order Created Successfully',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ID: ${widget.orderId.substring(widget.orderId.length - 8)}',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Payment Button
            ElevatedButton(
              onPressed: _isProcessingPayment ? null : _proceedToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Proceed to Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${_total.toInt()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
