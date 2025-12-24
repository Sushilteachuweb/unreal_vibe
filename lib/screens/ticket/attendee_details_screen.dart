import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/event_model.dart';
import '../../models/ticket_model.dart';
import '../../models/attendee_model.dart';
import '../../services/ticket_service.dart';
import '../../services/dummy_razorpay_service.dart';
import '../../services/user_storage.dart';
import '../../services/auth_service.dart';
import '../../services/test_auth_helper.dart';
import '../../models/purchased_ticket_model.dart';
import '../../utils/error_handler.dart';
import 'ticket_confirmation_screen.dart';
import 'payment_success_screen.dart';


class AttendeeDetailsScreen extends StatefulWidget {
  final Event event;
  final List<TicketSelection> ticketSelections;

  const AttendeeDetailsScreen({
    Key? key,
    required this.event,
    required this.ticketSelections,
  }) : super(key: key);

  @override
  State<AttendeeDetailsScreen> createState() => _AttendeeDetailsScreenState();
}

class _AttendeeDetailsScreenState extends State<AttendeeDetailsScreen> {
  final List<Attendee> _attendees = [];
  final List<GlobalKey<FormState>> _formKeys = [];
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCreatingOrder = false;
  String? _createdOrderId;
  final DummyRazorpayService _razorpayService = DummyRazorpayService();

  @override
  void initState() {
    super.initState();
    _initializeAttendees();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpayService.initialize(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentError: _handlePaymentError,
    );
  }

  void _initializeAttendees() {
    for (var selection in widget.ticketSelections) {
      final ticketTypeName = selection.ticketType.name.toUpperCase();
      final formattedPassType = _formatTicketType(selection.ticketType.name);
      
      for (int i = 0; i < selection.quantity; i++) {
        if (ticketTypeName.contains('COUPLE')) {
          // For couple tickets, create two attendees - one male and one female
          _attendees.add(Attendee(
            fullName: '',
            email: '',
            phone: '',
            gender: 'Male',
            passType: formattedPassType,
          ));
          _formKeys.add(GlobalKey<FormState>());
          
          _attendees.add(Attendee(
            fullName: '',
            email: '',
            phone: '',
            gender: 'Female',
            passType: formattedPassType,
          ));
          _formKeys.add(GlobalKey<FormState>());
        } else {
          // For individual tickets (Male/Female), create one attendee
          _attendees.add(Attendee(
            fullName: '',
            email: '',
            phone: '',
            gender: _getGenderFromPassType(selection.ticketType.name),
            passType: formattedPassType,
          ));
          _formKeys.add(GlobalKey<FormState>());
        }
      }
    }
  }

  String _getGenderFromPassType(String passType) {
    if (passType.toUpperCase().contains('MALE') && !passType.toUpperCase().contains('FEMALE')) {
      return 'Male';
    } else if (passType.toUpperCase().contains('FEMALE')) {
      return 'Female';
    } else if (passType.toUpperCase().contains('COUPLE')) {
      return 'Male'; // Default for couple, user can change
    }
    return 'Male'; // Default
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

  double get _totalPrice {
    return widget.ticketSelections.fold(0.0, (sum, selection) => sum + selection.totalPrice);
  }

  void _nextPage() {
    if (_currentPage < _attendees.length - 1) {
      // Validate current page before moving to next
      if (_formKeys[_currentPage].currentState?.validate() ?? false) {
        // Save current form state
        _formKeys[_currentPage].currentState?.save();
        
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Show error for current page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill all details for Attendee ${_currentPage + 1}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      _createOrder();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _createOrder() async {
    // Check authentication first
    final isLoggedIn = await UserStorage.getLoginStatus();
    final token = await UserStorage.getToken();
    
    print('🔐 Pre-order Authentication Check:');
    print('  - Is logged in: $isLoggedIn');
    print('  - Token exists: ${token != null}');
    
    if (!isLoggedIn || token == null) {
      print('❌ Authentication required - redirecting to login');
      _showAuthenticationDialog();
      return;
    }
    
    // Optional: Test token validity before proceeding
    // This is a soft check - if it fails, we'll still try the order
    // and let the actual API handle authentication errors
    try {
      final isTokenValid = await AuthService.isTokenValid();
      if (!isTokenValid) {
        print('⚠️ Token validation failed - will attempt order anyway');
        // Don't return here - let the order API handle it
      } else {
        print('✅ Token validation passed');
      }
    } catch (e) {
      print('⚠️ Token validation check failed: $e - proceeding anyway');
      // Continue with order creation
    }

    // Save current form state before validation
    for (int i = 0; i < _formKeys.length; i++) {
      _formKeys[i].currentState?.save();
    }
    
    // Small delay to ensure all onChanged callbacks are processed
    await Future.delayed(const Duration(milliseconds: 100));

    // Validate all attendees using direct data validation (more reliable than form validation)
    List<String> validationErrors = [];
    
    for (int i = 0; i < _attendees.length; i++) {
      final attendee = _attendees[i];
      
      // Validating attendee ${i + 1}
      
      List<String> fieldErrors = [];
      
      // Check individual field validations
      if (attendee.fullName.isEmpty) {
        fieldErrors.add('Full Name');
        print('    - Missing: Full Name');
      }
      
      if (attendee.email.isEmpty) {
        fieldErrors.add('Email');
        print('    - Missing: Email');
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(attendee.email)) {
        fieldErrors.add('Email (invalid format)');
        print('    - Invalid: Email format');
      }
      
      if (attendee.phone.isEmpty) {
        fieldErrors.add('Phone');
        print('    - Missing: Phone');
      } else if (attendee.phone.length != 10) {
        fieldErrors.add('Phone (must be 10 digits)');

      } else if (!RegExp(r'^[0-9]{10}$').hasMatch(attendee.phone)) {
        fieldErrors.add('Phone (invalid format)');
        print('    - Invalid: Phone format');
      }
      
      if (fieldErrors.isNotEmpty) {
        validationErrors.add('Attendee ${i + 1}: ${fieldErrors.join(', ')}');
        // Validation failed for attendee ${i + 1}
      } else {
        // Validation passed for attendee ${i + 1}
      }
    }

    if (validationErrors.isNotEmpty) {
      final errorMessage = 'Please fix the following:\n${validationErrors.join('\n')}';
          
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }
    
    // All attendees validated successfully

    setState(() {
      _isCreatingOrder = true;
    });

    try {
      // Prepare selected tickets data with price
      final selectedTickets = widget.ticketSelections.map((selection) => {
        'type': _formatTicketType(selection.ticketType.name),
        'price': selection.ticketType.price.toInt(),
        'quantity': selection.quantity,
      }).toList();

      // Prepare attendees data
      final attendeesData = _attendees.map((attendee) => attendee.toJson()).toList();

      // Calculate expected attendee count (couple tickets need 2 attendees each)
      int expectedAttendeeCount = 0;
      for (final selection in widget.ticketSelections) {
        final isCouple = selection.ticketType.name.toUpperCase().contains('COUPLE');
        if (isCouple) {
          expectedAttendeeCount += selection.quantity * 2; // 2 people per couple ticket
        } else {
          expectedAttendeeCount += selection.quantity; // 1 person per individual ticket
        }
      }
      
      final totalTicketQuantity = selectedTickets.fold<int>(0, (sum, ticket) => sum + (ticket['quantity'] as int));
      final totalAttendeesCount = attendeesData.length;

      // Validation logging for debugging
      
      // Debug individual ticket selections
      for (int i = 0; i < widget.ticketSelections.length; i++) {
        final selection = widget.ticketSelections[i];
        final isCouple = selection.ticketType.name.toUpperCase().contains('COUPLE');
        print('🎫 Ticket $i: ${selection.ticketType.name} x ${selection.quantity} ${isCouple ? "(Couple - 2 people each)" : ""}');
      }
      
      // Debug individual attendees
      // Attendee data prepared for order creation

      // Validate attendee count matches expected count
      if (totalAttendeesCount != expectedAttendeeCount) {
        throw Exception('Attendee count ($totalAttendeesCount) does not match expected count ($expectedAttendeeCount)');
      }

      // Validate that each attendee's pass type matches selected tickets
      final selectedTicketTypes = selectedTickets.map((ticket) => ticket['type'] as String).toSet();
      for (final attendee in attendeesData) {
        final attendeePassType = attendee['passType'] as String;
        if (!selectedTicketTypes.contains(attendeePassType)) {

          throw Exception('Attendee pass type "$attendeePassType" does not match any selected ticket type');
        }
      }
      
      // Count attendees by pass type and validate against ticket quantities
      final attendeesByPassType = <String, int>{};
      for (final attendee in attendeesData) {
        final passType = attendee['passType'] as String;
        attendeesByPassType[passType] = (attendeesByPassType[passType] ?? 0) + 1;
      }
      
      for (final ticket in selectedTickets) {
        final ticketType = ticket['type'] as String;
        final ticketQuantity = ticket['quantity'] as int;
        final attendeeCount = attendeesByPassType[ticketType] ?? 0;
        
        // For couple tickets, expect 2 attendees per ticket
        final isCouple = ticketType.toUpperCase().contains('COUPLE');
        final expectedAttendeeCount = isCouple ? ticketQuantity * 2 : ticketQuantity;
        
        if (attendeeCount != expectedAttendeeCount) {

          throw Exception('Pass type "$ticketType": Expected $expectedAttendeeCount attendees, but got $attendeeCount');
        }
      }
      
      print('✅ All validations passed!');

      // Create order
      final orderResponse = await TicketService.createOrder(
        eventId: widget.event.id,
        selectedTickets: selectedTickets,
        attendees: attendeesData,
      );

      // Store order ID for payment verification
      _createdOrderId = orderResponse['orderId'] ?? orderResponse['order_id'] ?? orderResponse['id'];

      if (mounted) {
        setState(() {
          _isCreatingOrder = false;
        });

        // Navigate to ticket confirmation screen
        _navigateToConfirmation(orderResponse);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreatingOrder = false;
        });
        
        String errorMessage;
        
        // Handle authentication errors
        if (e.toString().contains('AUTHENTICATION_REQUIRED')) {
          errorMessage = 'Please login to continue booking';
          _showAuthenticationDialog();
          return;
        }
        
        // Handle permission errors
        if (e.toString().contains('PERMISSION_DENIED')) {
          errorMessage = 'Your account does not have permission to create orders. Please contact support or try logging in again.';
          _showAuthenticationDialog();
          return;
        }
        
        // Handle specific booking errors
        if (e.toString().contains('pass not available')) {
          errorMessage = 'Selected tickets are no longer available. Please try different tickets.';
        } else if (e.toString().contains('Attendees count mismatch') || 
                   e.toString().contains('Attendee count') && e.toString().contains('does not match')) {
          errorMessage = 'There is a mismatch between the number of tickets and attendees. Please go back and check your selection.';
        } else {
          // Use the error handler for all other errors
          errorMessage = ErrorHandler.getUserFriendlyMessage(e);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToConfirmation(Map<String, dynamic> orderResponse) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TicketConfirmationScreen(
          event: widget.event,
          ticketSelections: widget.ticketSelections,
          attendees: _attendees,
          orderId: _createdOrderId!,
          orderResponse: orderResponse,
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
      // Fallback to simple success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Your tickets are confirmed.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/main',
        (route) => false,
        arguments: 0, // Home tab index
      );
    }
  }

  void _proceedToPayment() {
    if (_createdOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order ID not found. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get first attendee details for payment
    final firstAttendee = _attendees.first;
    
    // Open Razorpay checkout
    _razorpayService.openCheckout(
      context: context,
      amount: _totalPrice,
      name: firstAttendee.fullName,
      email: firstAttendee.email,
      contact: firstAttendee.phone,
      description: 'Ticket booking for ${widget.event.title}',
    );
  }

  void _handlePaymentSuccess(DummyPaymentSuccessResponse response) async {
    if (_createdOrderId == null) {
      _showErrorMessage('Order ID not found');
      return;
    }

    try {
      // Show loading
      _showLoadingDialog('Verifying payment...');

      // Prepare selected tickets data for verification with price
      final selectedTickets = widget.ticketSelections.map((selection) => {
        'type': _formatTicketType(selection.ticketType.name),
        'price': selection.ticketType.price.toInt(),
        'quantity': selection.quantity,
      }).toList();

      // Prepare attendees data
      final attendeesData = _attendees.map((attendee) => attendee.toJson()).toList();

      // Verify payment with backend
      final verificationResponse = await TicketService.verifyPayment(
        eventId: widget.event.id,
        orderId: _createdOrderId!,
        razorpayPaymentId: response.paymentId,
        razorpaySignature: response.signature,
        selectedTickets: selectedTickets,
        attendees: attendeesData,
      );

      // Hide loading
      if (mounted) Navigator.of(context).pop();

      // Handle successful verification
      if (mounted) {
        // Navigate to success screen with booking response
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

  void _showAuthenticationDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Authentication Required',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'You need to login to book tickets. Please login and try again.',
          style: TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/main',
                (route) => false,
                arguments: 0, // Home tab index
              );
            },
            child: const Text(
              'Go to Home',
              style: TextStyle(color: Color(0xFF6958CA)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // For testing - simulate login
              await TestAuthHelper.simulateLogin();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test login successful! You can now book tickets.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Test Login'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLogin();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6958CA),
            ),
            child: const Text('Real Login'),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    // For now, show a simple dialog with login instructions
    // In a real app, this would navigate to the login screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Login Required',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Please use the phone number authentication in the app to login before booking tickets.',
          style: TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/main',
                (route) => false,
                arguments: 0, // Home tab index
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6958CA),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        title: Text(
          'Attendee Details (${_currentPage + 1}/${_attendees.length})',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isCreatingOrder
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF6958CA)),
                  SizedBox(height: 16),
                  Text(
                    'Creating your order...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Progress indicator
                Container(
                  padding: const EdgeInsets.all(20),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / _attendees.length,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6958CA)),
                  ),
                ),
                
                // Form content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _attendees.length,
                    itemBuilder: (context, index) {
                      return _buildAttendeeForm(index);
                    },
                  ),
                ),
                
                // Bottom navigation
                _buildBottomNavigation(),
              ],
            ),
    );
  }

  Widget _buildAttendeeForm(int index) {
    final attendee = _attendees[index];
    final isCouple = attendee.passType.toUpperCase().contains('COUPLE');
    
    // For couple tickets, determine if this is person 1 or 2
    String attendeeTitle = 'Attendee ${index + 1}';
    if (isCouple) {
      // Find if there's a previous attendee with the same pass type
      int coupleIndex = 1;
      for (int i = 0; i < index; i++) {
        if (_attendees[i].passType == attendee.passType) {
          coupleIndex++;
        }
      }
      attendeeTitle = 'Couple - Person $coupleIndex (${attendee.gender})';
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[index],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              attendeeTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pass Type: ${attendee.passType}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            if (isCouple) ...[
              const SizedBox(height: 4),
              Text(
                'Gender: ${attendee.gender}',
                style: TextStyle(
                  color: attendee.gender == 'Male' ? Colors.blue[300] : Colors.pink[300],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 24),
            
            // Full Name
            _buildTextField(
              label: 'Full Name',
              initialValue: _attendees[index].fullName,
              onChanged: (value) {
                _attendees[index] = _attendees[index].copyWith(fullName: value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter full name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Email
            _buildTextField(
              label: 'Email',
              initialValue: _attendees[index].email,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                _attendees[index] = _attendees[index].copyWith(email: value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Phone
            _buildTextField(
              label: 'Phone Number',
              initialValue: _attendees[index].phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (value) {
                _attendees[index] = _attendees[index].copyWith(phone: value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                if (value.length != 10) {
                  return 'Phone number must be exactly 10 digits';
                }
                if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Gender
            _buildGenderSelector(index),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
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
              borderSide: const BorderSide(color: Color(0xFF6958CA)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            counterText: keyboardType == TextInputType.phone ? '' : null, // Hide counter for phone
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildGenderSelector(int index) {
    final attendee = _attendees[index];
    final passTypeUpper = attendee.passType.toUpperCase();
    final isCouple = passTypeUpper.contains('COUPLE');
    final isMalePass = passTypeUpper.contains('MALE') && !passTypeUpper.contains('FEMALE');
    final isFemalePass = passTypeUpper.contains('FEMALE');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (isCouple) ...[
          // For couple tickets, show fixed gender
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF6958CA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6958CA)),
            ),
            child: Center(
              child: Text(
                '${attendee.gender} (Fixed for Couple)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ] else if (isMalePass) ...[
          // For male pass, show only male option (fixed)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF6958CA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6958CA)),
            ),
            child: const Center(
              child: Text(
                'Male (Fixed for Male Pass)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ] else if (isFemalePass) ...[
          // For female pass, show only female option (fixed)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF6958CA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6958CA)),
            ),
            child: const Center(
              child: Text(
                'Female (Fixed for Female Pass)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ] else ...[
          // For other tickets, allow gender selection
          Row(
            children: [
              Expanded(
                child: _buildGenderOption(index, 'Male'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderOption(index, 'Female'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildGenderOption(int index, String gender) {
    final isSelected = _attendees[index].gender == gender;
    final attendee = _attendees[index];
    final passTypeUpper = attendee.passType.toUpperCase();
    final isCouple = passTypeUpper.contains('COUPLE');
    final isMalePass = passTypeUpper.contains('MALE') && !passTypeUpper.contains('FEMALE');
    final isFemalePass = passTypeUpper.contains('FEMALE');
    
    // Disable interaction for couple tickets or when gender doesn't match pass type
    final isDisabled = isCouple || 
                      (isMalePass && gender == 'Female') || 
                      (isFemalePass && gender == 'Male');
    
    return GestureDetector(
      onTap: isDisabled ? null : () {
        setState(() {
          _attendees[index] = _attendees[index].copyWith(gender: gender);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6958CA) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6958CA) : const Color(0xFF2A2A2A),
          ),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A2A)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: ElevatedButton(
                  onPressed: _previousPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A2A2A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Previous'),
                ),
              ),
            
            if (_currentPage > 0) const SizedBox(width: 16),
            
            Expanded(
              flex: 2,
              child: Container(
                height: 56.0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4081), Color(0xFFE91E63)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28.0),
                ),
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                  ),
                  child: Text(
                    _currentPage == _attendees.length - 1 
                        ? 'Create Order - ₹${_totalPrice.toInt()}'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}