# Search API Integration Guide

## Overview
This document describes the integration of the search API (`https://api.unrealvibe.com/api/event/search?city=Delhi`) into the Unreal Vibe Flutter app's home and explore screens.

## API Endpoint
```
GET https://api.unrealvibe.com/api/event/search?city=Delhi
```

### Parameters
- `q` (optional): Search query for events (title, description, etc.)
- `city` (optional): City to filter events by (e.g., "Delhi", "Mumbai")

### Response Format
```json
{
  "success": true,
  "data": {
    "events": [
      {
        "id": "event_id",
        "title": "Event Title",
        "subtitle": "Event Subtitle",
        "date": "2024-01-15",
        "location": "Event Location",
        "coverCharge": "₹500",
        "imageUrl": "https://...",
        "tags": ["music", "concert"],
        "status": "active"
      }
    ],
    "pagination": {
      "total": 0,
      "page": 1,
      "limit": 15,
      "totalPages": 0,
      "hasNext": false,
      "hasPrev": false
    },
    "appliedFilters": {
      "textSearch": true,
      "city": "Noida",
      "nearbyApplied": false,
      "radiusKm": null
    }
  }
}
```

## Implementation

### 1. Search Service (`lib/services/search_service.dart`)
A dedicated service for handling all search-related functionality:

```dart
// Search with both query and city
SearchService.searchEvents(query: "music", city: "Delhi")

// Search by city only
SearchService.searchEventsByCity("Delhi")

// Search by query only
SearchService.searchEventsByQuery("concert")

// Get search suggestions
SearchService.getSearchSuggestions("Delhi")
```

### 2. Enhanced Search Bar (`lib/screens/home/search_bar.dart`)
Updated search bar with:
- City-aware placeholder text
- Search suggestions dropdown
- Clear button functionality
- Better UX with loading states

### 3. Home Screen Integration
- Uses user's city from `UserProvider`
- Defaults to "Delhi" if no city is set
- Shows search suggestions when typing
- Displays search results with clear/retry options

### 4. Explore Screen Integration
- Same city-aware search functionality
- Consistent UI/UX with home screen
- Proper error handling and loading states

## Features

### ✅ Implemented
1. **City-based Search**: Automatically uses user's city for search
2. **Query + City Search**: Combines search terms with city filtering
3. **Search Suggestions**: Shows popular search terms for the user's city
4. **Error Handling**: Proper error messages and retry functionality
5. **Loading States**: Shows loading indicators during search
6. **Clear Functionality**: Easy to clear search and return to normal view
7. **Responsive Design**: Works on mobile, tablet, and desktop
8. **Search Validation**: Validates search queries and city names
9. **Pagination Support**: Handles paginated search results
10. **Response Format Handling**: Correctly parses the API's nested response format

### 🎯 Search Suggestions
Default suggestions include:
- Music concerts
- Comedy shows
- Art exhibitions
- Food festivals
- Tech meetups
- Dance performances
- Theater shows
- Sports events
- Workshops
- Networking events

### 🔧 Configuration
The search functionality can be configured in `SearchService`:
- Timeout duration (default: 15 seconds)
- Minimum query length (default: 2 characters)
- Number of suggestions shown (default: 5)

## Usage Examples

### Basic Search
```dart
// In home screen or explore screen
final results = await SearchService.searchEvents(
  query: "music concert",
  city: userCity,
);
```

### City-only Search
```dart
// Get all events in a specific city
final delhiEvents = await SearchService.searchEventsByCity("Delhi");
```

### Search with Pagination
```dart
// Get search results with pagination info
final searchResult = await SearchService.searchEventsWithPagination(
  query: "music",
  city: "Delhi",
  page: 1,
  limit: 15,
);

print('Found ${searchResult.events.length} events');
print('Total: ${searchResult.totalResults}');
print('Has more pages: ${searchResult.hasMorePages}');
```

### Search Validation
```dart
if (SearchService.isValidSearchQuery(query)) {
  // Perform search
}
```

## Error Handling
The search implementation includes comprehensive error handling:
- Network timeouts
- Invalid API responses
- JSON parsing errors
- Empty results
- User-friendly error messages

## Testing
Run the search API test:
```bash
dart test_search_api.dart
```

This will test:
- City-based search
- Query + city search
- Query-only search
- Search suggestions
- Validation functions

## Future Enhancements
1. **Search History**: Store and show recent searches
2. **Auto-complete**: Real-time search suggestions from API
3. **Advanced Filters**: Date range, price range, category filters in search
4. **Search Analytics**: Track popular search terms
5. **Offline Search**: Cache recent searches for offline use
6. **Voice Search**: Add voice input for search queries

## API Integration Notes
- The API endpoint supports both `q` and `city` parameters
- Parameters are properly URL-encoded
- Default city is "Delhi" if user hasn't set their location
- Search is case-insensitive on the server side
- Results are returned in JSON format with success/error indicators

## Performance Considerations
- Search requests have a 15-second timeout
- Results are not cached (implement caching for better performance)
- Debouncing can be added for real-time search (not implemented yet)
- Search suggestions are static (can be made dynamic from API)

## Security
- All search queries are properly URL-encoded
- No sensitive data is sent in search requests
- API calls use standard HTTP headers
- No authentication required for search endpoint