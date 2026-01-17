import 'package:flutter/material.dart';

class ErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString();
    print('🔍 Processing error: $errorString');
    
    if (errorString.startsWith('SOLD_OUT:')) {
      return errorString.substring(9); // Remove prefix
    } else if (errorString.startsWith('VALIDATION_ERROR:')) {
      return errorString.substring(17); // Remove prefix
    } else if (errorString.startsWith('BOOKING_ERROR:')) {
      return errorString.substring(14); // Remove prefix
    } else if (errorString.startsWith('AUTHENTICATION_REQUIRED:')) {
      return 'Please log in to continue with your booking.';
    } else if (errorString.startsWith('PERMISSION_DENIED:')) {
      return 'We\'re having trouble processing your request. Please try logging in again or contact support if the issue persists.';
    } else if (errorString.startsWith('EVENT_NOT_FOUND:')) {
      return errorString.substring(16); // Remove prefix
    } else if (errorString.startsWith('SERVER_ERROR:')) {
      return errorString.substring(13); // Remove prefix
    } else if (errorString.contains('sold out') || errorString.contains('capacity')) {
      return 'This event is sold out or has insufficient capacity. Please try a different event or ticket type.';
    } else if (errorString.contains('authentication') || errorString.contains('login')) {
      return 'Your session has expired. Please log in again to continue.';
    } else if (errorString.contains('permission') || errorString.contains('forbidden')) {
      return 'We couldn\'t process your request. Please try logging in again or contact support.';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (errorString.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (errorString.contains('computeEventExtras is not defined')) {
      return 'Saved events feature is temporarily unavailable due to a server issue. Please try again later or contact support.';
    } else if (errorString.contains('server') || errorString.contains('500')) {
      return 'The server is temporarily unavailable. Please try again in a few minutes.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
  
  static bool requiresReauth(String error) {
    return error.startsWith('AUTHENTICATION_REQUIRED:') ||
           error.contains('session expired') ||
           error.contains('login again');
  }
  
  static bool isRetryable(String error) {
    return error.startsWith('SERVER_ERROR:') ||
           error.startsWith('BOOKING_ERROR:') ||
           error.contains('network') ||
           error.contains('timeout') ||
           error.contains('temporarily unavailable');
  }

  // Add missing methods that the existing code expects
  static Widget buildEmptyState({
    String? title,
    String? message,
    String? context, // Context parameter for icon selection
    String? customMessage, // Custom message parameter
    BuildContext? navigatorContext, // Navigator context parameter
    IconData? icon,
    VoidCallback? onRetry,
    String? retryText,
  }) {
    // Use customMessage if provided, otherwise use message, otherwise use default
    final displayMessage = customMessage ?? message ?? 'No data available';
    final displayTitle = title ?? _getTitleForContext(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? _getIconForContext(context),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              displayTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              displayMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryText ?? 'Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper method to get appropriate title based on context
  static String _getTitleForContext(String? context) {
    switch (context) {
      case 'events':
        return 'No Events';
      case 'tickets':
        return 'No Tickets';
      case 'search':
        return 'No Results';
      case 'saved':
        return 'No Saved Events';
      default:
        return 'No Data';
    }
  }

  // Helper method to get appropriate icon based on context
  static IconData _getIconForContext(String? context) {
    switch (context) {
      case 'events':
        return Icons.event_busy;
      case 'tickets':
        return Icons.confirmation_number_outlined;
      case 'search':
        return Icons.search_off;
      case 'saved':
        return Icons.bookmark_border;
      default:
        return Icons.error_outline;
    }
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getUserFriendlyMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}