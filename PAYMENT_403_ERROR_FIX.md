# Payment 403 Error - Troubleshooting Guide

## Issue
When attempting to create an order for event tickets, the API returns a **403 Forbidden** error with the message "Insufficient permissions".

## Root Cause
The 403 error indicates one of the following issues:

1. **Expired Authentication Token**: The user's JWT token has expired
2. **Invalid Token**: The token is malformed or has been invalidated
3. **Insufficient Permissions**: The user account doesn't have the required permissions to create orders
4. **Backend Authorization Issue**: The API endpoint requires specific user roles or permissions

## Implemented Solutions

### 1. Enhanced Error Handling
- Added specific handling for 403 errors in `ticket_service.dart`
- Differentiated between 401 (Unauthorized) and 403 (Forbidden) errors
- Added detailed logging to track authentication status

### 2. Improved Token Validation
- Added `isTokenValid()` method in `auth_service.dart` with multiple endpoint fallbacks
- Tests multiple endpoints to find one that works for token validation
- Gracefully handles cases where validation endpoints are not available
- Uses soft validation approach - doesn't block order creation if validation fails

### 3. Robust Authentication Flow
- Pre-order authentication check with detailed logging
- Soft token validation that doesn't block the process
- Lets the actual order API handle final authentication decisions
- Automatic token cleanup when clearly invalid (401/403 responses)

### 4. Enhanced User Feedback
- Added specific error messages for permission-related issues
- Prompts users to re-authenticate when token is clearly invalid
- Provides clear guidance on what action to take
- Better error differentiation between expired tokens and permission issues

### 5. Comprehensive Debug Logging
- Added detailed logging throughout the authentication flow
- Logs token status, authentication state, and API responses
- Shows which endpoints are being tested for validation
- Helps identify the exact point of failure

### 6. Debug Tools
- Created `debug_auth_test.dart` for manual authentication testing
- Allows testing different endpoints with actual tokens
- Helps identify backend issues vs client issues

## How to Test

1. **Check Authentication Status**:
   ```dart
   final isLoggedIn = await UserStorage.getLoginStatus();
   final token = await UserStorage.getToken();
   print('Is logged in: $isLoggedIn');
   print('Token exists: ${token != null}');
   ```

2. **Test Token Validity**:
   ```dart
   final isValid = await AuthService.isTokenValid();
   print('Token is valid: $isValid');
   ```

3. **Monitor Logs**:
   - Look for "🔐 Authentication Status" logs
   - Check for "❌ 403 Forbidden" messages
   - Review token preview in logs

## Recommended Actions

### For Users:
1. **Log out and log back in** to get a fresh token
2. **Clear app data** if the issue persists
3. **Contact support** if the problem continues after re-authentication

### For Developers:
1. **Check Backend Permissions**: Verify that the user role has permission to create orders
2. **Review Token Expiry**: Ensure tokens have appropriate expiration times
3. **Implement Token Refresh**: Add automatic token refresh mechanism
4. **Check API Authorization**: Verify the `/api/payment/create-order` endpoint permissions

## Backend Requirements

The create order endpoint requires:
- Valid JWT token in Authorization header
- User must be authenticated
- User must have permission to create orders
- Token must not be expired

## Next Steps

1. **Implement Token Refresh**: Add automatic token refresh when token is about to expire
2. **Add Retry Logic**: Automatically retry with new token if 403 occurs
3. **Backend Investigation**: Check backend logs to see why the token is being rejected
4. **User Role Verification**: Ensure all users have the correct permissions assigned

## Testing Checklist

- [ ] User can log in successfully
- [ ] Token is saved correctly
- [ ] Token validation works
- [ ] Order creation succeeds with valid token
- [ ] Appropriate error message shown on 403
- [ ] User is prompted to re-authenticate
- [ ] Re-authentication resolves the issue

## Code Changes

### Files Modified:
1. `lib/services/ticket_service.dart` - Enhanced error handling and logging
2. `lib/services/auth_service.dart` - Added token validation method
3. `lib/screens/ticket/attendee_details_screen.dart` - Added token validation before order creation

### Key Improvements:
- Better error differentiation (401 vs 403)
- Proactive token validation
- Improved user feedback
- Comprehensive debug logging
