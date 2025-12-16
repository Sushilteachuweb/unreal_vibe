import 'package:flutter/material.dart';

class RazorpayConfig {
  // Replace these with your actual Razorpay credentials
  static const String keyId = 'rzp_test_xxxxxxxxxx'; // Your Razorpay Key ID
  static const String keySecret = 'your_secret_key'; // Keep this on backend only!
  
  // Your backend API base URL
  static const String apiBaseUrl = 'http://api.unrealvibe.com';
  
  // Payment configuration
  static const String currency = 'INR';
  static const String companyName = 'Unreal Vibe';
  static const String companyLogo = 'https://your-logo-url.com/logo.png';
  static const Color themeColor = Color(0xFF6958CA);
  
  // Payment timeout in seconds
  static const int paymentTimeout = 300; // 5 minutes
  
  // Test mode flag
  static const bool isTestMode = true; // Set to false for production
  
  // Test credentials (for development)
  static const String testKeyId = 'rzp_test_xxxxxxxxxx';
  
  // Get current key based on mode
  static String get currentKeyId => isTestMode ? testKeyId : keyId;
}