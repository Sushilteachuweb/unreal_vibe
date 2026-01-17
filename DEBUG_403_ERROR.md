# 403 Forbidden Error - Debug Guide

## ✅ Verified Configuration

I've verified that your code is correctly configured:

1. **Authentication**: Using both Bearer token AND Cookie (same as other working APIs)
2. **Request Body Format**: Matches your schema exactly:
   - `eventId` ✓
   - `items[]` with `passType`, `price`, `quantity` ✓
   - `attendees[]` with `fullName`, `email`, `phone`, `gender`, `passType` ✓
3. **Headers**: Content-Type, Accept, Authorization (Bearer), Cookie ✓

## Problem
You're getting a **403 Forbidden** error when trying to create an order, with the message:
```
{"success":false,"message":"Forbidden: Insufficient permissions"}
```

## What We've Done

### Enhanced Logging
I've added comprehensive debug logging to `lib/services/ticket_service.dart` that will show:

1. **Authentication Status**
   - Whether token exists
   - Token length and preview
   - Cookie information
   - Login status

2. **Request Details**
   - Full request body
   - All headers being sent
   - Endpoint being called

3. **Response Details**
   - Status code
   - Response body
   - Response headers

## What to Check When You Run the App

### 1. First, check the login process

When you log in (verify OTP), look for this output:
```
═══════════════════════════════════════════════════════
🔐 TOKEN RECEIVED FROM LOGIN
═══════════════════════════════════════════════════════
🔐 Token from API: [full token]
🔐 Token length: [number]
🔐 Token starts with: [first 30 chars]
🔐 Token ends with: [last 20 chars]
✅ Token saved to storage
✅ Token save verified successfully
✅ Saved token matches API token
═══════════════════════════════════════════════════════
```

**IMPORTANT**: Copy this entire token and compare it with the token that works in Postman!

### 2. Then, try to create an order

Look for this debug output in your terminal:

```
═══════════════════════════════════════════════════════
🎫 CREATE ORDER DEBUG LOG
═══════════════════════════════════════════════════════
📍 Endpoint: https://api.unrealvibe.com/api/payment/create-order
🎯 Event ID: [your event id]

🔐 AUTHENTICATION STATUS:
  ├─ Token exists: true/false
  ├─ Is logged in: true/false
  ├─ Cookie exists: true/false
  ├─ Token length: [number]
  ├─ Token preview: [first 50 chars]
  └─ Token ends with: [last 20 chars]

📦 REQUEST BODY:
[JSON body]

🔍 REQUEST VALIDATION:
  ├─ Event ID: [event id]
  ├─ Items count: [number]
  ├─ Attendees count: [number]
  └─ Items structure:
      [0] passType: Male, price: 1500, quantity: 1
  └─ Attendees structure:
      [0] fullName: John Doe, email: john@example.com, phone: 1234567890, gender: Male, passType: Male

📋 REQUEST HEADERS:
  ├─ Content-Type: application/json
  ├─ Accept: application/json
  ├─ Authorization: Bearer [token preview]
  └─ Cookie: accessToken=[token preview]

🚀 SENDING REQUEST...

📥 RESPONSE RECEIVED:
  ├─ Status Code: 403
  ├─ Response Body: {"success":false,"message":"Forbidden: Insufficient permissions"}
  └─ Response Headers: [headers]
```

## Possible Causes of 403 Error

### 1. **Token is Valid but User Role is Insufficient**
   - The token authenticates you, but your user account doesn't have permission to create orders
   - **Solution**: Check if your account needs to be verified or upgraded

### 2. **Token Format Issue**
   - The token might be malformed or not in the expected format
   - **Solution**: Compare the token format with what works in Postman

### 3. **Backend Permission Check Failing**
   - The backend might be checking for specific user properties (verified status, role, etc.)
   - **Solution**: Check your user profile status on the backend

### 4. **Cookie vs Bearer Token Mismatch**
   - The backend might expect only one authentication method
   - **Solution**: Try using only Bearer token OR only Cookie

## Next Steps

1. **Log in to the app** (or log out and log back in)
2. **Copy the token from the login debug log**
3. **Compare it with your Postman token**:
   - Are they the same format?
   - Do they have the same length?
   - Are they JWT tokens (format: xxxxx.yyyyy.zzzzz)?

4. **Try to create an order**
5. **Copy the entire create order debug log** from the terminal
6. **Share both logs** (login token + create order attempt)

7. **Key things to check**:
   - Does the token from login match the token used in create order?
   - Is the token format correct (JWT format)?
   - What's the exact error message from the backend?
   - Are the request headers correct?

## Debugging Checklist

- [ ] Token is being saved during login
- [ ] Token is being retrieved during create order
- [ ] Token format matches Postman (JWT: xxx.yyy.zzz)
- [ ] Token length is reasonable (usually 200-500 characters for JWT)
- [ ] Headers include both Authorization and Cookie
- [ ] Request body format matches Postman
- [ ] User account has proper permissions on backend
- [ ] No special characters or encoding issues in token

## Quick Test

If you want to test if it's a token issue, try this:
1. Get a working token from Postman (one that successfully creates an order)
2. Manually set that token in the app using:
   ```dart
   await UserStorage.saveToken('your_working_token_from_postman');
   ```
3. Try creating an order again

## Code Changes Made

- Added `dart:math` import for `min()` function
- Enhanced logging throughout the `createOrder()` method
- Added detailed error messages for 403 errors
- Added token clearing when 403 occurs (forces re-login)
