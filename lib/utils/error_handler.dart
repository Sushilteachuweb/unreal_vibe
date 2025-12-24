import 'package:flutter/material.dart';

class ErrorHandler {
  /// Convert technical errors to user-friendly messages
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Network errors
    if (errorString.contains('socketexception') || 
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return 'Please check your internet connection and try again';
    }
    
    // Authentication errors
    if (errorString.contains('authentication_required') ||
        errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return 'Please login to continue';
    }
    
    // Server errors
    if (errorString.contains('500') || 
        errorString.contains('server error') ||
        errorString.contains('internal server')) {
      return 'Our servers are temporarily unavailable. Please try again later';
    }
    
    // Not found errors
    if (errorString.contains('404') || 
        errorString.contains('not found')) {
      return 'The requested information is not available';
    }
    
    // Permission errors
    if (errorString.contains('permission') ||
        errorString.contains('forbidden') ||
        errorString.contains('403')) {
      return 'You don\'t have permission to access this feature';
    }
    
    // Location errors
    if (errorString.contains('location') ||
        errorString.contains('gps') ||
        errorString.contains('coordinates')) {
      return 'Unable to access your location. Please enable location services';
    }
    
    // Image/file errors
    if (errorString.contains('image') ||
        errorString.contains('file') ||
        errorString.contains('camera') ||
        errorString.contains('gallery')) {
      return 'Unable to process the image. Please try again';
    }
    
    // Payment errors
    if (errorString.contains('payment') ||
        errorString.contains('razorpay') ||
        errorString.contains('transaction')) {
      return 'Payment processing failed. Please try again';
    }
    
    // QR code errors
    if (errorString.contains('qr') ||
        errorString.contains('code')) {
      return 'Unable to generate QR code. Please try again';
    }
    
    // Validation errors
    if (errorString.contains('validation') ||
        errorString.contains('invalid') ||
        errorString.contains('required')) {
      return 'Please check your information and try again';
    }
    
    // Default fallback
    return 'Something went wrong. Please try again';
  }
  
  /// Get empty state message based on context
  static String getEmptyStateMessage(String context) {
    switch (context.toLowerCase()) {
      case 'events':
      case 'trending':
        return 'No trending events near your location';
      case 'search':
        return 'No events found matching your search';
      case 'tickets':
      case 'passes':
        return 'Book Your First Ticket!';
      case 'notifications':
        return 'You\'re all caught up! No new notifications';
      case 'saved':
      case 'favorites':
        return 'You haven\'t saved any events yet';
      case 'categories':
        return 'No events available in this category';
      case 'profile':
        return 'Unable to load profile information';
      default:
        return 'No items found';
    }
  }
  
  /// Show user-friendly error dialog
  static void showErrorDialog(BuildContext context, dynamic error, {
    String? title,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          title ?? 'Oops!',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          getUserFriendlyMessage(error),
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text(
                'Try Again',
                style: TextStyle(color: Color(0xFF6958CA)),
              ),
            ),
        ],
      ),
    );
  }
  
  /// Show user-friendly error snackbar
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getUserFriendlyMessage(error)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  /// Build empty state widget
  static Widget buildEmptyState({
    required String context,
    String? customMessage,
    IconData? icon,
    VoidCallback? onRetry,
    BuildContext? navigatorContext,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF6958CA).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? _getContextIcon(context),
                color: const Color(0xFF6958CA),
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              customMessage ?? getEmptyStateMessage(context),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _getContextSubtitle(context),
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Special handling for tickets context
            if (context.toLowerCase() == 'tickets' || context.toLowerCase() == 'passes') ...[
              ElevatedButton(
                onPressed: () {
                  if (navigatorContext != null) {
                    // Navigate to main screen with home tab (index 0)
                    Navigator.of(navigatorContext).pushNamedAndRemoveUntil(
                      '/main',
                      (route) => false,
                      arguments: 0, // Home tab index
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6958CA),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Browse Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onRetry,
                  child: const Text(
                    'Refresh',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ] else if (onRetry != null) ...[
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6958CA),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  static IconData _getContextIcon(String context) {
    switch (context.toLowerCase()) {
      case 'events':
      case 'trending':
        return Icons.event_busy;
      case 'search':
        return Icons.search_off;
      case 'tickets':
      case 'passes':
        return Icons.confirmation_number_outlined;
      case 'notifications':
        return Icons.notifications_none;
      case 'saved':
      case 'favorites':
        return Icons.bookmark_border;
      case 'profile':
        return Icons.person_outline;
      default:
        return Icons.inbox_outlined;
    }
  }
  
  static String _getContextSubtitle(String context) {
    switch (context.toLowerCase()) {
      case 'events':
      case 'trending':
        return 'Try exploring different areas or check back later for new events';
      case 'search':
        return 'Try different keywords or browse all events';
      case 'tickets':
      case 'passes':
        return 'Discover amazing events and book your first ticket to get started!';
      case 'notifications':
        return 'We\'ll notify you when something new happens';
      case 'saved':
      case 'favorites':
        return 'Save events you\'re interested in to see them here';
      case 'profile':
        return 'Please check your connection and try again';
      default:
        return 'Please try again or contact support if the problem persists';
    }
  }
}