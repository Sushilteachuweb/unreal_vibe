import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'onboarding_slider.dart';
import '../../navigation/main_navigation.dart';
import '../../providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for UserProvider to load data
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Show splash for 2-3 seconds like other apps
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Navigate based on login status
    if (userProvider.isLoggedIn && userProvider.user != null) {
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingSlider()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/images/Logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
