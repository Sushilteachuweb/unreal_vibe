import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../services/host_service.dart';
import 'success_screen.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _localityController = TextEditingController();
  final _pincodeController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedCity;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  final List<String> _cities = ['Noida', 'Delhi', 'Gurgaon'];

  @override
  void dispose() {
    _dateController.dispose();
    _localityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _selectedDate != null &&
        _localityController.text.isNotEmpty &&
        _selectedCity != null &&
        _pincodeController.text.length == 6 &&
        _agreedToTerms;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF6958CA),
              onPrimary: Colors.white,
              surface: const Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _submitForm() async {
    print('📝 [CreateScreen] Form submission started');
    
    if (!_isFormValid) {
      print('❌ [CreateScreen] Form validation failed');
      return;
    }

    print('✅ [CreateScreen] Form validation passed');
    setState(() {
      _isLoading = true;
    });

    try {
      // Get auth token from UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authToken = userProvider.authToken;
      
      print('� [CreateeScreen] Auth token available: ${authToken != null && authToken.isNotEmpty}');
      if (authToken == null || authToken.isEmpty) {
        print('⚠️ [CreateScreen] WARNING: No authentication token found!');
      }
      
      // Format date for API (YYYY-MM-DD)
      final formattedDate = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      
      print('📅 [CreateScreen] Formatted date: $formattedDate');
      print('📍 [CreateScreen] Locality: ${_localityController.text.trim()}');
      print('🏙️ [CreateScreen] City: $_selectedCity');
      print('📮 [CreateScreen] Pincode: ${_pincodeController.text.trim()}');
      
      final result = await HostService.submitHostRequest(
        preferredPartyDate: formattedDate,
        locality: _localityController.text.trim(),
        city: _selectedCity!,
        pincode: _pincodeController.text.trim(),
        authToken: authToken,
      );

      print('📨 [CreateScreen] API response received');
      print('✅ [CreateScreen] Success: ${result.success}');
      print('💬 [CreateScreen] Message: ${result.message}');
      if (result.error != null) {
        print('❌ [CreateScreen] Error: ${result.error}');
      }
      if (result.statusCode != null) {
        print('📊 [CreateScreen] Status Code: ${result.statusCode}');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result.success) {
          print('🎉 [CreateScreen] Navigating to success screen');
          // Navigate to success screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const SuccessScreen(),
            ),
          );
        } else {
          print('⚠️ [CreateScreen] Showing error dialog');
          
          // Check for specific error types and provide professional messages
          String errorTitle = 'Request Failed';
          String errorMessage = result.message;
          
          if (authToken == null || authToken.isEmpty) {
            errorTitle = 'Authentication Required';
            errorMessage = 'Please log in to submit a host request.';
          } else if (result.statusCode == 401 || result.statusCode == 403) {
            errorTitle = 'Authentication Failed';
            errorMessage = 'Your session has expired. Please log in again.';
          } else if (result.message.toLowerCase().contains('pending request') || 
                     result.message.toLowerCase().contains('already have')) {
            errorTitle = 'Request Already Submitted';
            errorMessage = 'You already have a pending host request. Our team will review it and get back to you soon.';
          } else if (result.message.toLowerCase().contains('duplicate')) {
            errorTitle = 'Duplicate Request';
            errorMessage = 'A similar request has already been submitted. Please wait for our team to review your existing request.';
          }
          
          // Show error message with professional text
          _showProfessionalErrorDialog(errorTitle, errorMessage, result.error);
        }
      }
    } catch (e) {
      print('💥 [CreateScreen] Exception in form submission: $e');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        _showProfessionalErrorDialog(
          'Unexpected Error',
          'Something went wrong while submitting your request. Please try again.',
          e.toString(),
        );
      }
    }
  }

  void _showProfessionalErrorDialog(String title, String message, String? details) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              if (details != null && details.isNotEmpty) ...[
                const SizedBox(height: 16),
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    title: const Text(
                      'Technical Details',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF), 
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    iconColor: const Color(0xFF9CA3AF),
                    collapsedIconColor: const Color(0xFF9CA3AF),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F0F),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF2C2C2E),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          details,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontFamily: 'monospace',
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            Container(
              width: double.infinity,
              height: 44,
              margin: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF6958CA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message, String? details) {
    _showProfessionalErrorDialog('Request Failed', message, details);
  }



  void _navigateToTerms() {
    // Navigate to terms and conditions screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terms & Conditions screen'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Form(
                key: _formKey,
                onChanged: () => setState(() {}),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Host a Party',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 32),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Share some quick details to get one step closer to hosting a great house party.',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                        color: Color(0xFF9CA3AF),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6958CA).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFF6958CA),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Only registered hosts can create party requests',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
                                color: const Color(0xFF6958CA),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 32),
                _buildLabel('Preferred Party Date'),
                const SizedBox(height: 8),
                _buildDateField(),
                const SizedBox(height: 24),
                _buildLabel('Locality'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _localityController,
                  hintText: 'e.g., Sector 18',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter locality';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildLabel('City'),
                const SizedBox(height: 8),
                _buildCityDropdown(),
                const SizedBox(height: 24),
                _buildLabel('Pincode'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _pincodeController,
                  hintText: 'e.g., 201301',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pincode';
                    }
                    if (value.length != 6) {
                      return 'Pincode must be 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _buildTermsCheckbox(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: () => _selectDate(context),
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Select a date',
        hintStyle: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 15,
        ),
        suffixIcon: const Icon(
          Icons.calendar_today,
          color: Color(0xFF6B7280),
          size: 20,
        ),
        filled: true,
        fillColor: const Color(0xFF1C1C1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6958CA)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      validator: (value) {
        if (_selectedDate == null) {
          return 'Please select a date';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 15,
        ),
        filled: true,
        fillColor: const Color(0xFF1C1C1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6958CA)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      dropdownColor: const Color(0xFF1C1C1E),
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Select a city',
        hintStyle: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 15,
        ),
        filled: true,
        fillColor: const Color(0xFF1C1C1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6958CA)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Color(0xFF6B7280),
      ),
      items: _cities.map((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCity = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a city';
        }
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
            activeColor: const Color(0xFF6958CA),
            checkColor: Colors.white,
            side: const BorderSide(color: Color(0xFF4B5563)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _navigateToTerms,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9CA3AF),
                ),
                children: [
                  TextSpan(text: 'I have read and agree to the '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: Color(0xFFFF1B6B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: _isFormValid && !_isLoading
            ? const LinearGradient(
                colors: [Color(0xFFFF4081), Color(0xFFE91E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: _isFormValid && !_isLoading ? null : const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isFormValid && !_isLoading ? _submitForm : null,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Request to Host',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isFormValid ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
          ),
        ),
      ),
    );
  }



  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Unrealvibe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final userCity = userProvider.user?.city ?? 'Noida';
              return Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    userCity,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
