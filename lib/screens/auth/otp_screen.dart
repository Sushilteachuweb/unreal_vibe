import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'create_account_screen.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/user_provider.dart';
import '../../navigation/main_navigation.dart';
import '../../services/app_initialization_service.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  String _timerText = '00:30';
  bool _isResendEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    int seconds = 30;
    _updateTimer(seconds);
  }

  void _updateTimer(int seconds) {
    if (seconds >= 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _timerText = '00:${seconds.toString().padLeft(2, '0')}';
            _isResendEnabled = seconds == 0;
          });
          _updateTimer(seconds - 1);
        }
      });
    }
  }

  Future<void> _resendOTP() async {
    if (!_isResendEnabled) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final result = await userProvider.requestOtp(widget.phoneNumber);

      if (!mounted) return;

      if (result['success']) {
        setState(() {
          _isResendEnabled = false;
          for (var controller in _otpControllers) {
            controller.clear();
          }
        });
        _startTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'OTP resent successfully'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to resend OTP'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String maskedNumber = '${widget.phoneNumber.substring(0, 2)}XXXXXXXX';
    final padding = ResponsiveHelper.getResponsivePadding(context, 24.0);
    final titleSize = ResponsiveHelper.getResponsiveFontSize(context, 22);
    final maxWidth = ResponsiveHelper.getMaxContentWidth(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/SplashScreen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.95),
              ],
              stops: const [0.0, 0.2, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(flex: 3, child: Container()),
                Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(padding, 30.0, padding, 40.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFAB3965).withOpacity(0.85),
                          Color(0xFF2F1518).withOpacity(0.98),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Verify OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '4-digit code was sent to $maskedNumber',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
                          ),
                        ),
                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          4,
                              (index) => Container(
                            width: 45,
                            height: 45,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _otpControllers[index].text.isNotEmpty
                                    ? Color(0xFFE91E63)
                                    : Colors.grey.withOpacity(0.3),
                                width: _otpControllers[index].text.isNotEmpty ? 2 : 1,
                              ),
                            ),
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              maxLines: 1,
                              minLines: 1,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                isCollapsed: true,
                              ),
                              onChanged: (value) {
                                setState(() {}); // Rebuild to update border color
                                if (value.length == 1) {
                                  if (index < 3) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else {
                                    _focusNodes[index].unfocus();
                                  }
                                } else if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: _isResendEnabled ? _resendOTP : null,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            backgroundColor: _isResendEnabled
                                ? Color(0xFFE91E63).withOpacity(0.2)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: _isResendEnabled
                                    ? Color(0xFFE91E63)
                                    : Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Resend OTP ',
                                  style: TextStyle(
                                    color: _isResendEnabled
                                        ? Color(0xFFE91E63)
                                        : Colors.white.withOpacity(0.6),
                                    fontSize: 15,
                                    fontWeight: _isResendEnabled
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                TextSpan(
                                  text: _timerText,
                                  style: TextStyle(
                                    color: _isResendEnabled
                                        ? Color(0xFFE91E63)
                                        : Colors.white.withOpacity(0.8),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 56.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: !_isLoading
                                  ? const LinearGradient(
                                      colors: [Color(0xFFFF4081), Color(0xFFE91E63)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: _isLoading ? Colors.grey.withOpacity(0.3) : null,
                              borderRadius: BorderRadius.circular(28.0),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _verifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledBackgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.0),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Verify OTP',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    String enteredOtp = _otpControllers
        .map((controller) => controller.text)
        .join();

    // Validate OTP length
    if (enteredOtp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete 4-digit OTP'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final result = await userProvider.verifyOtp(widget.phoneNumber, enteredOtp);

      if (!mounted) return;

      if (result['success']) {
        final isProfileComplete = result['isProfileComplete'] ?? false;

        // Initialize notification services after successful login
        await AppInitializationService.reinitializeAfterLogin();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Login successful'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );

        // Always fetch profile to verify actual user data
        await userProvider.fetchProfile();
        final user = userProvider.user;

        // Check if user has required fields for basic profile
        final hasRequiredFields = user != null && 
          user.name != null && user.name!.isNotEmpty &&
          user.email != null && user.email!.isNotEmpty &&
          user.city != null && user.city!.isNotEmpty &&
          user.gender != null && user.gender!.isNotEmpty;

        // Navigate based on actual user data, not just backend flag
        if (isProfileComplete || hasRequiredFields) {
          // Profile exists and has required fields, go to main app
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigation(),
            ),
          );
        } else {
          // Profile incomplete or missing required fields, go to create account
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CreateAccountScreen(
                phoneNumber: widget.phoneNumber,
              ),
            ),
          );
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Invalid OTP'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}