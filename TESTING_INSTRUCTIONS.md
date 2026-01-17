# Testing Instructions for 403 Error

## ✅ What I've Verified

Your code is **correctly configured**:

1. **Authentication Method**: ✅ Using both Bearer token AND Cookie (same as all other working APIs)
   - Location: `lib/services/api_routes.dart` → `getAuthHeadersWithCookies()`
   - Sends: `Authorization: Bearer <token>` + `Cookie: accessToken=<token>`

2. **Request Body Format**: ✅ Matches your schema exactly
   ```json
   {
     "eventId": "string",
     "items": [
       {
         "passType": "string",
         "price": number,
         "quantity": number
       }
     ],
     "attendees": [
       {
         "fullName": "string",
         "email": "string",
         "phone": "string",
         "gender": "string",
         "passType": "string"
       }
     ]
   }
   ```

3. **Attendee Model**: ✅ All required fields present
   - `lib/models/attendee_model.dart` has: fullName, email, phone, gender, passType

## 🔍 Enhanced Debug Logging

I've added comprehensive logging that will show:

### During Login (OTP Verification)
```
═══════════════════════════════════════════════════════
🔐 TOKEN RECEIVED FROM LOGIN
═══════════════════════════════════════════════════════
🔐 Token from API: [FULL TOKEN - COPY THIS!]
🔐 Token length: [number]
🔐 Token starts with: [first 30 chars]
🔐 Token ends with: [last 20 chars]
✅ Token saved to storage
✅ Token save verified successfully
✅ Saved token matches API token
═══════════════════════════════════════════════════════
```

### During Create Order
```
═══════════════════════════════════════════════════════
🎫 CREATE ORDER DEBUG LOG
═══════════════════════════════════════════════════════
📍 Endpoint: https://api.unrealvibe.com/api/payment/create-order
🎯 Event ID: [event id]

🔐 AUTHENTICATION STATUS:
  ├─ Token exists: true
  ├─ Is logged in: true
  ├─ Cookie exists: true
  ├─ Token length: [number]
  ├─ Token preview: [first 50 chars]
  └─ Token ends with: [last 20 chars]

📦 REQUEST BODY:
{"eventId":"...","items":[...],"attendees":[...]}

🔍 REQUEST VALIDATION:
  ├─ Event ID: [id]
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

❌ 403 FORBIDDEN - INSUFFICIENT PERMISSIONS
  ├─ Token exists but lacks required permissions
  ├─ This usually means:
  │  • Token is valid but user role is insufficient
  │  • User account needs verification
  │  • Backend permission check is failing
  └─ Clearing stored credentials and requiring re-login
═══════════════════════════════════════════════════════
```

## 📋 Testing Steps

### Step 1: Log Out and Log In Again
1. Open the app
2. Log out if already logged in
3. Log in with OTP
4. **IMPORTANT**: Copy the FULL token from the login debug log
5. Save it somewhere for comparison

### Step 2: Try to Create an Order
1. Select an event
2. Select tickets
3. Fill in attendee details
4. Click "Create Order"
5. **IMPORTANT**: Copy the entire debug log from terminal

### Step 3: Compare with Postman
Open your Postman and compare:

| Item | App | Postman | Match? |
|------|-----|---------|--------|
| Token format | [from log] | [from Postman] | ✓ or ✗ |
| Token length | [from log] | [from Postman] | ✓ or ✗ |
| Request body | [from log] | [from Postman] | ✓ or ✗ |
| Headers | [from log] | [from Postman] | ✓ or ✗ |

## 🎯 What to Look For

### If Token Formats Don't Match
- **Problem**: App token might be different from Postman token
- **Solution**: Check if you're using the same user account in both

### If Token Lengths Don't Match
- **Problem**: Token might be truncated or corrupted
- **Solution**: Check UserStorage implementation

### If Request Body Doesn't Match
- **Problem**: Data transformation issue
- **Solution**: Check the validation log to see exact structure

### If Headers Don't Match
- **Problem**: Missing or incorrect headers
- **Solution**: Already verified - should be correct

## 🔧 Possible Root Causes

Based on 403 Forbidden error, the most likely causes are:

### 1. User Role/Permission Issue (Most Likely)
- **Symptom**: Token is valid but user doesn't have permission
- **Check**: 
  - Is your user account verified on the backend?
  - Does your user have the correct role?
  - Are there any account restrictions?
- **Test**: Try with a different user account that you know works in Postman

### 2. Token Scope Issue
- **Symptom**: Token is valid for some APIs but not for create-order
- **Check**: 
  - Does the token have the required scopes/permissions?
  - Is there a difference between read and write permissions?
- **Test**: Compare token claims (JWT payload) between app and Postman

### 3. Backend Permission Logic
- **Symptom**: Backend has specific checks for create-order endpoint
- **Check**: 
  - Does backend check for verified email/phone?
  - Does backend check for minimum account age?
  - Does backend check for previous successful orders?
- **Test**: Check backend logs for the exact permission check that's failing

## 📤 What to Share

After testing, please share:

1. **Login Token Log** (the full token from login)
2. **Create Order Debug Log** (the entire log from create order attempt)
3. **Postman Token** (for comparison)
4. **User Account Details**:
   - Is account verified?
   - What's the user role?
   - Any special permissions?

## 🚀 Quick Fix to Test

If you want to quickly test if it's a token issue:

1. Get a working token from Postman (one that successfully creates orders)
2. In your app, before creating order, manually set that token:
   ```dart
   // Add this temporarily in attendee_details_screen.dart before createOrder
   await UserStorage.saveToken('YOUR_WORKING_TOKEN_FROM_POSTMAN');
   ```
3. Try creating an order
4. If it works → Token issue
5. If it still fails → Something else

## ✅ Next Steps

1. Run the tests above
2. Copy all the debug logs
3. Share them so we can identify the exact issue
4. We'll fix it based on what we find!
