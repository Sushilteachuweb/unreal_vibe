# My Tickets API Integration - Debug Guide

## Overview
Integrated the My Passes API (`https://api.unrealvibe.com/api/passes/my-passes`) with enhanced debugging and UI matching Figma design.

## Current Status
✅ API integration complete with detailed logging
✅ UI updated to match Figma design
✅ Dummy data functionality for testing
✅ Download functionality implemented
⚠️ API response not showing - needs debugging

## Debug Steps

### 1. Check API Response Format
The app is calling the API but data isn't showing. Check the console logs for:
- API response status and body
- JSON parsing results
- Model creation success/failure

### 2. Test with Dummy Data
Click the bug icon (🐛) in the app bar to load dummy data and verify the UI works correctly.

### 3. Use Test Script
Run `dart test_my_passes_api.dart` with a valid bearer token to see the exact API response format.

### 4. Common Issues to Check

#### API Response Format
The model expects this structure:
```json
{
  "success": true,
  "message": "Success",
  "passes": [
    {
      "_id": "pass_id",
      "eventName": "Event Name",
      "passType": "General Admission",
      "quantity": 2,
      "eventDate": "2025-01-23T21:00:00Z",
      "eventTime": "9:00 PM",
      "venue": "Venue Name",
      "city": "City Name",
      "status": "upcoming"
    }
  ]
}
```

#### Alternative Response Formats
The model also handles:
- `data` instead of `passes` array
- `id` instead of `_id`
- Nested event object: `event.name`, `event.date`, etc.

### 5. Authentication
Ensure the bearer token is valid and the user is logged in.

## Download Functionality

### Implementation
- **Download Service**: `lib/services/download_service.dart`
- **API Endpoint**: `https://api.unrealvibe.com/api/passes/my-passes/download/{bookingId}`
- **File Format**: PDF
- **Authentication**: Bearer token required

### Features
- ✅ Progress dialog during download
- ✅ Automatic file saving to Downloads folder (Android) or Documents (iOS)
- ✅ Storage permission handling
- ✅ Success notification with file location
- ✅ Error handling and user feedback
- ✅ Cross-platform support (Android/iOS)

### Usage
Click the download button (📥) on any ticket card or in the QR code screen to download the PDF ticket.

### Dependencies Added
- `dio: ^5.4.0` - For file downloading with progress
- `path_provider: ^2.1.1` - For getting device storage paths

### Testing
Use `dart test_download_api.dart` with a valid bearer token and booking ID to test the download API directly.

## Files Modified/Created

### 1. API Routes (`lib/services/api_routes.dart`)
- Added `getMyPasses` endpoint for fetching user's purchased passes

### 2. Data Model (`lib/models/my_pass_model.dart`)
- Created `MyPass` model to represent purchased tickets
- Added `MyPassesResponse` for API response handling
- Includes properties: eventName, passType, quantity, eventDate, venue, city, status, qrCode, etc.
- Added helper methods for date formatting and status checking

### 3. Service Layer (`lib/services/ticket_service.dart`)
- Added `fetchMyPasses()` method to call the API with bearer token authentication
- Added `getPassQRCode()` method to fetch QR code data from verify payment API
- Proper error handling for authentication and network issues

### 4. UI Components

#### My Tickets Screen (`lib/screens/ticket/my_tickets_screen.dart`)
- Converted from StatelessWidget to StatefulWidget
- Added TabController for Upcoming/Past/Saved tabs
- Integrated API calls with loading states and error handling
- Created ticket cards matching the design with event info, dates, and action buttons
- Added pull-to-refresh functionality

#### QR Code Screen (`lib/screens/ticket/qr_code_screen.dart`)
- New screen for displaying QR codes
- Shows event details and QR code using `qr_flutter` package
- Handles cases where QR code needs to be fetched separately
- Includes download button placeholder for future implementation

### 5. Test File (`test_my_passes_api.dart`)
- Simple test script to verify API endpoint functionality
- Replace `YOUR_BEARER_TOKEN_HERE` with actual token for testing

## API Integration Details

### Authentication
- Uses Bearer token authentication from `UserStorage.getToken()`
- Handles 401 errors by clearing invalid tokens
- Redirects to login when authentication is required

### Error Handling
- Network timeouts (10 seconds)
- Authentication errors
- API response validation
- User-friendly error messages

### Data Flow
1. User opens My Tickets screen
2. App fetches passes from `/api/passes/my-passes` with bearer token
3. Passes are categorized into Upcoming/Past/Saved tabs
4. User can tap "View QR Code" to see QR code
5. If QR code not available, app attempts to fetch from verify payment API

## UI Features

### Ticket Cards
- Event image with fallback icon
- Event name and pass type with quantity
- Formatted date and time
- Venue and city information
- "View QR Code" and download buttons

### Tabs
- **Upcoming**: Future events
- **Past**: Completed events  
- **Saved**: All passes (placeholder for future saved functionality)

### States
- Loading spinner during API calls
- Empty state when no tickets found
- Error state with retry functionality
- Refresh button in app bar

## Next Steps

1. **QR Code Integration**: Update the `getPassQRCode()` method once you provide the exact API structure for fetching QR codes from the verify payment endpoint.

2. **Download Functionality**: Implement ticket download feature using the ticket download API you mentioned.

3. **Testing**: Test with real bearer tokens and API responses to ensure proper data mapping.

4. **Error Refinement**: Add more specific error handling based on actual API error responses.

## Usage

The integration is ready to use. Users can:
1. View their purchased tickets organized by status
2. See event details and timing
3. Access QR codes for venue entry
4. Refresh to get latest ticket data

The screen gracefully handles authentication, loading, and error states to provide a smooth user experience.