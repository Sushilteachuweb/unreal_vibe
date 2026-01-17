import 'package:flutter/material.dart';

class PhonePeConfig {
  // Replace these with your actual PhonePe credentials
  static const String merchantId = 'PGTESTPAYUAT'; // Your PhonePe Merchant ID
  static const String saltKey = '099eb0cd-02cf-4e2a-8aca-3e6c6aff0399'; // Your Salt Key
  static const String saltIndex = '1'; // Your Salt Index
  
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
  
  // PhonePe URLs
  static const String testBaseUrl = 'https://api-preprod.phonepe.com/apis/pg-sandbox';
  static const String prodBaseUrl = 'https://api.phonepe.com/apis/hermes';
  
  // Test credentials (for development)
  static const String testMerchantId = 'PGTESTPAYUAT';
  static const String testSaltKey = '099eb0cd-02cf-4e2a-8aca-3e6c6aff0399';
  
  // Get current credentials based on mode
  static String get currentMerchantId => isTestMode ? testMerchantId : merchantId;
  static String get currentSaltKey => isTestMode ? testSaltKey : saltKey;
  static String get currentBaseUrl => isTestMode ? testBaseUrl : prodBaseUrl;
  
  // PhonePe App Package Names
  static const String phonePePackageName = 'com.phonepe.app';
  static const String phonePePackageNameStaging = 'com.phonepe.app.preprod';
  
  // Get current package name based on mode
  static String get currentPackageName => isTestMode ? phonePePackageNameStaging : phonePePackageName;
}