import 'package:flutter/foundation.dart';

/// Centralized error handling utility to ensure users see friendly messages
/// while developers get detailed debug information in console
class ErrorHandler {
  /// Shows user-friendly error message while logging technical details for developers
  static String getUserFriendlyMessage(dynamic error, {String? fallbackMessage}) {
    // Log detailed error for developers
    if (kDebugMode) {
      debugPrint('🚨 [ERROR] ${error.toString()}');
      debugPrint('🚨 [ERROR TYPE] ${error.runtimeType}');
      if (error is Exception) {
        debugPrint('🚨 [STACK TRACE] ${StackTrace.current}');
      }
    }

    final errorString = error.toString().toLowerCase();
    
    // Authentication errors
    if (errorString.contains('authentication') || 
        errorString.contains('unauthorized') ||
        errorString.contains('401') ||
        errorString.contains('403')) {
      return 'Please log in to continue';
    }
    
    // Network errors
    if (errorString.contains('socketexception') || 
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network connection error. Please check your internet connection';
    }
    
    // Timeout errors
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again';
    }
    
    // Permission errors
    if (errorString.contains('permission')) {
      return 'Permission required. Please check app permissions';
    }
    
    // Server errors
    if (errorString.contains('500') || 
        errorString.contains('server error') ||
        errorString.contains('internal server')) {
      return 'Server error. Please try again later';
    }
    
    // Format/parsing errors
    if (errorString.contains('format') || 
        errorString.contains('parsing') ||
        errorString.contains('json')) {
      return 'Data format error. Please try again';
    }
    
    // SSL/Security errors
    if (errorString.contains('handshake') || 
        errorString.contains('ssl') ||
        errorString.contains('certificate')) {
      return 'Security connection error. Please check your network settings';
    }
    
    // File/storage errors
    if (errorString.contains('file') || 
        errorString.contains('storage') ||
        errorString.contains('directory')) {
      return 'File access error. Please try again';
    }
    
    // Location errors
    if (errorString.contains('location') || 
        errorString.contains('gps')) {
      return 'Location access error. Please check location permissions';
    }
    
    // Payment errors
    if (errorString.contains('payment') || 
        errorString.contains('razorpay') ||
        errorString.contains('transaction')) {
      return 'Payment error. Please try again';
    }
    
    // API specific errors
    if (errorString.contains('api') || 
        errorString.contains('endpoint')) {
      return 'Service temporarily unavailable. Please try again';
    }
    
    // Default fallback
    return fallbackMessage ?? 'Something went wrong. Please try again';
  }

  /// Logs error details for developers without exposing to users
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('🚨 [$context] ERROR: $error');
      debugPrint('🚨 [$context] ERROR TYPE: ${error.runtimeType}');
      if (stackTrace != null) {
        debugPrint('🚨 [$context] STACK TRACE: $stackTrace');
      }
    }
  }

  /// Checks if error is authentication related
  static bool isAuthError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('authentication') || 
           errorString.contains('unauthorized') ||
           errorString.contains('401') ||
           errorString.contains('403') ||
           errorString.contains('login required');
  }

  /// Checks if error is network related
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') || 
           errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout');
  }

  /// Gets appropriate retry message based on error type
  static String getRetryMessage(dynamic error) {
    if (isNetworkError(error)) {
      return 'Check your internet connection and try again';
    }
    if (isAuthError(error)) {
      return 'Please log in and try again';
    }
    return 'Please try again';
  }
}