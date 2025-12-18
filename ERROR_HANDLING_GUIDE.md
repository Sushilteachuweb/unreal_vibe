# Error Handling Guide

## Overview
This guide ensures users see friendly error messages while developers get detailed debug information in the console.

## Key Principles

### 1. User-Friendly Messages
- Users should NEVER see technical error details like stack traces, exception types, or raw error messages
- Always show actionable, understandable messages
- Provide clear next steps when possible

### 2. Developer Debug Information
- All technical details are logged to console using `debugPrint()` in debug mode only
- Include error type, stack trace, and context information
- Use consistent logging format: `🚨 [CONTEXT] ERROR: details`

## Implementation Pattern

### ✅ CORRECT Pattern
```dart
} catch (e) {
  // Log detailed error for developers
  debugPrint('🚨 [ScreenName] Operation error: $e');
  debugPrint('🚨 [ScreenName] Error type: ${e.runtimeType}');
  
  // Show user-friendly message
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Operation failed. Please try again'),
      backgroundColor: Colors.red,
    ),
  );
}
```

### ❌ INCORRECT Pattern
```dart
} catch (e) {
  // DON'T expose technical details to users
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: ${e.toString()}'), // ❌ Technical details exposed
      backgroundColor: Colors.red,
    ),
  );
}
```

## Error Message Categories

### Authentication Errors
- **User sees**: "Please log in to continue"
- **Developer logs**: Full authentication error details

### Network Errors
- **User sees**: "Network connection error. Please check your internet connection"
- **Developer logs**: SocketException, timeout details, etc.

### Permission Errors
- **User sees**: "Permission required. Please check app permissions"
- **Developer logs**: Specific permission type and error

### Server Errors
- **User sees**: "Server error. Please try again later"
- **Developer logs**: HTTP status codes, response body, etc.

### Generic Errors
- **User sees**: "Something went wrong. Please try again"
- **Developer logs**: Full error details and stack trace

## Screen-Specific Guidelines

### Home Screen
- Search failures: "Search failed. Please try again"
- Event loading: "Failed to load events. Please try again"

### Profile Screens
- Image upload: "Failed to select/upload image. Please try again"
- Profile update: "Failed to update profile. Please try again"
- Data loading: "Failed to load profile data. Please try again"

### Event Details
- Save/unsave: "Failed to save event. Please try again"
- Share: "Failed to share event. Please try again"
- Directions: "Failed to open directions. Please try again"

### Ticket Booking
- Order creation: "Booking failed. Please try again"
- Payment: "Payment error. Please try again"
- Validation: Clear field-specific messages

## Debugging in Production

### Console Logs (Debug Mode Only)
```dart
if (kDebugMode) {
  debugPrint('🚨 [Context] Error: $error');
  debugPrint('🚨 [Context] Stack: $stackTrace');
}
```

### Error Tracking
- Use the `ErrorHandler` utility class for consistent error handling
- Log errors with context for easier debugging
- Include user actions that led to the error

## Testing Error Scenarios

### Network Issues
- Test with airplane mode
- Test with slow/unstable connection
- Test API endpoint failures

### Authentication Issues
- Test with expired tokens
- Test without login
- Test with invalid credentials

### Permission Issues
- Test with denied permissions
- Test with limited permissions
- Test permission request flows

### Data Issues
- Test with malformed API responses
- Test with empty/null data
- Test with large datasets

## Common Fixes Applied

### Fixed Files
1. `lib/widgets/filter_bottom_sheet.dart` - Location errors
2. `lib/screens/profile/widgets/settings_card.dart` - Logout errors
3. `lib/screens/profile/upload_documents_screen.dart` - Image and profile errors
4. `lib/screens/profile/edit_profile_screen.dart` - Profile update errors
5. `lib/screens/profile/saved_events_screen.dart` - Event loading errors
6. `lib/screens/home/home_screen.dart` - Search errors
7. `lib/screens/explore/explore_screen.dart` - Search errors
8. `lib/screens/home/event_details_screen.dart` - Directions and sharing errors
9. `lib/services/maps_service.dart` - Maps service errors

### Error Handler Utility
- Created `lib/utils/error_handler.dart` for centralized error handling
- Provides user-friendly messages based on error type
- Logs detailed information for developers

## Best Practices

### Do's
- ✅ Always log errors with context
- ✅ Show actionable user messages
- ✅ Provide retry options when appropriate
- ✅ Use consistent error message format
- ✅ Test error scenarios thoroughly

### Don'ts
- ❌ Never show raw error messages to users
- ❌ Don't expose stack traces in UI
- ❌ Don't show technical jargon
- ❌ Don't leave users without guidance
- ❌ Don't ignore errors silently

## Monitoring

### Debug Console
- All errors are logged with 🚨 prefix for easy filtering
- Include screen/component context
- Log error type and details

### User Feedback
- Monitor user reports of "something went wrong" messages
- Track which screens have most error reports
- Improve error handling based on user feedback

## Future Improvements

### Error Analytics
- Consider adding crash reporting (Firebase Crashlytics)
- Track error frequency by screen
- Monitor error patterns

### Enhanced Error Messages
- Add more specific error categories
- Provide better recovery suggestions
- Add offline mode handling

### User Experience
- Add loading states for better UX
- Implement retry mechanisms
- Show progress indicators for long operations