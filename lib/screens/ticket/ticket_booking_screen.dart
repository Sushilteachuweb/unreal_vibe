import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/responsive_helper.dart';
import '../../models/event_model.dart';
import '../../screens/home/bottom_navigation.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/explore/explore_screen.dart';
import '../../screens/create/create_screen.dart';
import '../../screens/ticket/my_tickets_screen.dart';
import '../../screens/profile/profile_screen.dart';
import 'simplified_payment_gateway_screen.dart';
import '../../widgets/skeleton_loading.dart';

class TicketBookingScreen extends StatefulWidget {
  final Event event;

  const TicketBookingScreen({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<TicketBookingScreen> createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen> {
  int _ticketCount = 1;
  final TextEditingController _promoController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedGender = 'Male';
  bool _promoApplied = false;

  final double _ticketPrice = 50.0;
  final double _taxRate = 0.10; // 10% tax to match $5 on $50

  double get _subtotal => _ticketPrice * _ticketCount;
  double get _taxAmount => _subtotal * _taxRate;
  double get _total => _subtotal + _taxAmount;

  @override
  void dispose() {
    _promoController.dispose();
    _whatsappController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, padding),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title
                    _buildEventTitle(context),
                    const SizedBox(height: 24),

                    // Ticket Quantity Section
                    _buildTicketQuantity(context),
                    const SizedBox(height: 24),

                    // Pricing Summary
                    _buildPricingSummary(context),
                    const SizedBox(height: 24),

                    // Promo Code
                    _buildPromoCode(context),
                    const SizedBox(height: 24),

                    // Your Details
                    _buildYourDetails(context),
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
          _buildConfirmPayButton(context, padding),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
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
            child: Center(
              child: Text(
                'Unrealvibes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildEventTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.event.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.event.date}, ${widget.event.time}',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 15),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTicketQuantity(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1625),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2E2740),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.confirmation_number,
              color: Color(0xFF7B5FFF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Number of Tickets',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2E2740),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _ticketCount > 1
                      ? () => setState(() => _ticketCount--)
                      : null,
                  icon: const Icon(Icons.remove, color: Colors.white),
                  iconSize: 18,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 30),
                  alignment: Alignment.center,
                  child: Text(
                    '$_ticketCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _ticketCount < 10
                      ? () => setState(() => _ticketCount++)
                      : null,
                  icon: const Icon(Icons.add, color: Colors.white),
                  iconSize: 18,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text(
            '\$${_ticketPrice.toStringAsFixed(2)} per person',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(height: 16),
        _buildPriceRow('Ticket Price', '\$${_subtotal.toStringAsFixed(2)}', context),
        const SizedBox(height: 12),
        _buildPriceRow('Taxes & Charges', '\$${_taxAmount.toStringAsFixed(2)}', context),
        const SizedBox(height: 16),
        Container(
          height: 1,
          color: const Color(0xFF2E2740),
        ),
        const SizedBox(height: 16),
        _buildPriceRow('Total', '\$${_total.toStringAsFixed(2)}', context, isTotal: true),
        const SizedBox(height: 8),
        Text(
          '*Taxes & Charges Apply',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, BuildContext context, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.grey[400],
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, isTotal ? 18 : 15),
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? const Color(0xFF7B5FFF) : Colors.white,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, isTotal ? 20 : 15),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Promo Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter promo code',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 15),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A1625),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF7B5FFF), width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B5FFF), Color(0xFF9D7FFF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: _applyPromoCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 15),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_promoApplied)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Promo code applied successfully!',
              style: TextStyle(
                color: const Color(0xFF00D9A5),
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildYourDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildInputField('Whatsapp Number', _whatsappController, context, isPhoneNumber: true),
        const SizedBox(height: 12),
        _buildInputField('Your Name', _nameController, context),
        const SizedBox(height: 12),
        _buildInputField('Your Email', _emailController, context),
        const SizedBox(height: 12),
        _buildGenderDropdown(context),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, BuildContext context, {bool isPhoneNumber = false}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      keyboardType: isPhoneNumber ? TextInputType.phone : TextInputType.text,
      inputFormatters: isPhoneNumber ? [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ] : null,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 15),
        ),
        filled: true,
        fillColor: const Color(0xFF1A1625),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF7B5FFF), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _buildGenderDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1625),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          isExpanded: true,
          hint: Text(
            'Gender',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 15),
            ),
          ),
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 15),
          ),
          dropdownColor: const Color(0xFF1A1625),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          items: ['Male', 'Female', 'Other'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildConfirmPayButton(BuildContext context, double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 16, padding, 16),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4081), Color(0xFFE91E63)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4081).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _handleConfirmPay,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Text(
            'Confirm & Pay',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
            ),
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
            break;
          case 1: // Explore
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ExploreScreen()),
              (route) => false,
            );
            break;
          case 2: // Create
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const CreateScreen()),
              (route) => false,
            );
            break;
          case 3: // Tickets
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyTicketsScreen()),
              (route) => false,
            );
            break;
          case 4: // Profile
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
              (route) => false,
            );
            break;
        }
      },
    );
  }

  void _applyPromoCode() {
    if (_promoController.text.isNotEmpty) {
      setState(() {
        _promoApplied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Promo code applied successfully!'),
          backgroundColor: const Color(0xFF00D9A5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _handleConfirmPay() {
    // Validate form
    if (_whatsappController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Validate WhatsApp number is exactly 10 digits
    if (_whatsappController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid 10-digit WhatsApp number'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Navigate to payment gateway screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimplifiedPaymentGatewayScreen(
          totalAmount: _total,
          eventName: widget.event.title,
          ticketCount: _ticketCount,
          userName: _nameController.text,
          userEmail: _emailController.text,
          whatsappNumber: _whatsappController.text,
        ),
      ),
    );
  }
}