import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import 'api_routes.dart';
import 'user_storage.dart';
import 'search_service.dart';

class EventService {
  // Cache for saved events to avoid repeated API calls
  static List<Event>? _cachedSavedEvents;
  static DateTime? _lastSavedEventsFetch;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  static Future<List<Event>> fetchEvents() async {
    // List of endpoints to try
    final endpoints = [
      ApiConfig.getEvents,
      // ApiConfig.getEventsAlt1,
      // ApiConfig.getEventsAlt2,
      // ApiConfig.getEventsAlt3,
    ];

    Exception? lastException;

    for (String endpoint in endpoints) {
      try {
        print('Attempting to fetch events from: $endpoint');
        
        final response = await http.get(
          Uri.parse(endpoint),
          headers: ApiConfig.headers,
        ).timeout(const Duration(seconds: 10));

        print('API Response Status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          print('API Response Body: ${response.body}');
          
          try {
            final Map<String, dynamic> data = json.decode(response.body);
            
            if (data['success'] == true && data['events'] != null) {
              final List<dynamic> eventsJson = data['events'];
              final events = eventsJson.map((eventJson) => Event.fromJson(eventJson)).toList();
              print('Successfully parsed ${events.length} events from $endpoint');
              return events;
            } else {
              print('Invalid response format from $endpoint: $data');
              lastException = Exception('Invalid API response format from $endpoint');
              continue;
            }
          } catch (jsonError) {
            print('JSON parsing error from $endpoint: $jsonError');
            lastException = Exception('Failed to parse JSON from $endpoint: $jsonError');
            continue;
          }
        } else {
          print('HTTP ${response.statusCode} from $endpoint: ${response.body}');
          lastException = Exception('HTTP ${response.statusCode} from $endpoint');
          continue;
        }
      } catch (e) {
        print('Error with endpoint $endpoint: $e');
        lastException = e is Exception ? e : Exception(e.toString());
        continue;
      }
    }

    // If we get here, all endpoints failed
    print('All API endpoints failed. Last error: $lastException');
    
    // Provide helpful error message
    String errorMessage = 'Unable to fetch events from the server.\n\n';
    errorMessage += 'Tried endpoints:\n';
    for (String endpoint in endpoints) {
      errorMessage += '• $endpoint\n';
    }
    errorMessage += '\nPlease check:\n';
    errorMessage += '1. Your internet connection\n';
    errorMessage += '2. If the API server is running\n';
    errorMessage += '3. The correct API endpoint with the developer';
    
    throw Exception(errorMessage);
  }

  static Future<List<Event>> fetchTrendingEvents() async {
    try {
      print('Attempting to fetch trending events from: ${ApiConfig.getTrendingEvents}');
      
      // Get auth token
      final token = await UserStorage.getToken();
      if (token == null) {
        throw Exception('Authentication required. Please log in to view trending events.');
      }
      
      final response = await http.get(
        Uri.parse(ApiConfig.getTrendingEvents),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(const Duration(seconds: 10));

      print('Trending Events API Response Status: ${response.statusCode}');
      print('Trending Events API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          
          if (data['success'] == true && data['events'] != null) {
            final List<dynamic> eventsJson = data['events'];
            final events = eventsJson.map((eventJson) => Event.fromJson(eventJson)).toList();
            print('Successfully parsed ${events.length} trending events');
            return events;
          } else {
            print('Invalid trending events response format: $data');
            return [];
          }
        } catch (jsonError) {
          print('JSON parsing error in trending events: $jsonError');
          return [];
        }
      } else {
        print('Trending Events HTTP ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching trending events: $e');
      return [];
    }
  }

  static Future<bool> toggleSaveEvent(String eventId) async {
    try {
      print('Toggling save for event: $eventId');
      
      // Get auth token
      final token = await UserStorage.getToken();
      if (token == null) {
        throw Exception('Authentication required. Please log in to save events.');
      }
      
      final response = await http.post(
        Uri.parse(ApiConfig.saveEvent(eventId)),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(const Duration(seconds: 10));

      print('Save API Response Status: ${response.statusCode}');
      print('Save API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          
          if (data['success'] == true) {
            // Clear saved events cache since the save state changed
            _cachedSavedEvents = null;
            _lastSavedEventsFetch = null;
            
            // Return the isSaved value from API response
            return data['isSaved'] ?? false;
          } else {
            print('Save API returned success: false');
            return false;
          }
        } catch (jsonError) {
          print('JSON parsing error in save: $jsonError');
          return false;
        }
      } else {
        print('Save HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error toggling save event: $e');
      return false;
    }
  }

  static Future<List<Event>> searchEvents(String query, {String? city}) async {
    // Delegate to SearchService for better organization
    return SearchService.searchEvents(query: query, city: city);
  }

  static Future<bool> shareEvent(String eventId) async {
    try {
      print('Sharing event: $eventId');
      
      // Get auth token
      final token = await UserStorage.getToken();
      if (token == null) {
        throw Exception('Authentication required. Please log in to share events.');
      }
      
      final response = await http.post(
        Uri.parse(ApiConfig.shareEvent(eventId)),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(const Duration(seconds: 10));

      print('Share API Response Status: ${response.statusCode}');
      print('Share API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          
          if (data['success'] == true) {
            return true;
          } else {
            print('Share API returned success: false');
            return false;
          }
        } catch (jsonError) {
          print('JSON parsing error in share: $jsonError');
          return false;
        }
      } else {
        print('Share HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sharing event: $e');
      return false;
    }
  }

  static Future<List<Event>> fetchSavedEvents({bool forceRefresh = false}) async {
    // Check cache first (unless force refresh is requested)
    if (!forceRefresh && 
        _cachedSavedEvents != null && 
        _lastSavedEventsFetch != null &&
        DateTime.now().difference(_lastSavedEventsFetch!) < _cacheExpiry) {
      print('Returning cached saved events');
      return _cachedSavedEvents!;
    }

    try {
      print('Fetching saved events from API');
      
      // Get auth token
      final token = await UserStorage.getToken();
      if (token == null) {
        throw Exception('Authentication required. Please log in to view saved events.');
      }
      
      final response = await http.get(
        Uri.parse(ApiConfig.getSavedEvents),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(const Duration(seconds: 10));

      print('Saved Events API Response Status: ${response.statusCode}');
      print('Saved Events API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          
          if (data['success'] == true && data['savedEvents'] != null) {
            final List<dynamic> eventsJson = data['savedEvents'];
            final events = eventsJson.map((eventJson) => Event.fromJson(eventJson)).toList();
            
            // Cache the results
            _cachedSavedEvents = events;
            _lastSavedEventsFetch = DateTime.now();
            
            print('Successfully fetched ${events.length} saved events');
            return events;
          } else {
            print('Invalid saved events response format: $data');
            return [];
          }
        } catch (jsonError) {
          print('JSON parsing error in saved events: $jsonError');
          return [];
        }
      } else {
        print('Saved Events HTTP ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching saved events: $e');
      return [];
    }
  }

  static Future<bool> isEventSaved(String eventId) async {
    try {
      final savedEvents = await fetchSavedEvents();
      return savedEvents.any((event) => event.id == eventId);
    } catch (e) {
      print('Error checking if event is saved: $e');
      return false;
    }
  }

  static Future<List<Event>> filterEvents({
    String? category,
    String? location,
    String? startDate,
    String? endDate,
    double? latitude,
    double? longitude,
    double? maxDistance,
  }) async {
    try {
      print('Filtering events with parameters:');
      print('Category: $category');
      print('Location: $location');
      print('Start Date: $startDate');
      print('End Date: $endDate');
      print('Coordinates: $latitude, $longitude');
      print('Max Distance: $maxDistance');

      // Build query parameters
      Map<String, String> queryParams = {};
      
      if (category != null && category != 'All') {
        queryParams['category'] = category;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate;
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate;
      }
      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude.toString();
        queryParams['longitude'] = longitude.toString();
      }
      if (maxDistance != null) {
        queryParams['maxDistance'] = maxDistance.toString();
      }

      // Build URL with query parameters
      String url = ApiConfig.filterEvents;
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url = '$url?$queryString';
      }

      print('Filter API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headers,
      ).timeout(const Duration(seconds: 10));

      print('Filter API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Filter API Response Body: ${response.body}');
        
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          
          if (data['success'] == true && data['events'] != null) {
            final List<dynamic> eventsJson = data['events'];
            final events = eventsJson.map((eventJson) => Event.fromJson(eventJson)).toList();
            print('Successfully filtered ${events.length} events');
            return events;
          } else {
            print('Invalid filter response format: $data');
            // Fallback to regular events if filter API fails
            return await fetchEvents();
          }
        } catch (jsonError) {
          print('JSON parsing error in filter: $jsonError');
          // Fallback to regular events if parsing fails
          return await fetchEvents();
        }
      } else {
        print('Filter HTTP ${response.statusCode}: ${response.body}');
        // Fallback to regular events if API fails
        return await fetchEvents();
      }
    } catch (e) {
      print('Error filtering events: $e');
      // Fallback to regular events if filtering fails
      return await fetchEvents();
    }
  }
}