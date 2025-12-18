import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import 'api_routes.dart';

class SearchService {
  /// Search events by query and city
  /// 
  /// [query] - Search term for events (title, description, etc.)
  /// [city] - City to search in (e.g., "Delhi", "Mumbai")
  /// [page] - Page number for pagination (default: 1)
  /// [limit] - Number of results per page (default: 15)
  /// 
  /// Returns a list of events matching the search criteria
  static Future<List<Event>> searchEvents({
    String? query,
    String? city,
    int page = 1,
    int limit = 15,
  }) async {
    try {
      print('🔍 Searching events - Query: "$query", City: "$city"');
      
      // Build query parameters
      Map<String, String> queryParams = {};
      
      // Special handling: if query is the same as city, only use city parameter
      // This is because the API treats 'q' as text search within events, not city filter
      if (query != null && query.trim().isNotEmpty && city != null) {
        final trimmedQuery = query.trim();
        final trimmedCity = city.trim();
        
        if (trimmedQuery.toLowerCase() == trimmedCity.toLowerCase()) {
          // If searching for the city name, only use city parameter
          print('🎯 Query matches city name, using city-only search');
          queryParams['city'] = trimmedCity;
        } else {
          // Different query and city, use both
          queryParams['q'] = trimmedQuery;
          queryParams['city'] = trimmedCity;
        }
      } else {
        // Add individual parameters
        if (query != null && query.trim().isNotEmpty) {
          queryParams['q'] = query.trim();
        }
        
        if (city != null && city.trim().isNotEmpty) {
          queryParams['city'] = city.trim();
        }
      }
      
      // Add pagination parameters
      if (page > 1) {
        queryParams['page'] = page.toString();
      }
      
      if (limit != 15) {
        queryParams['limit'] = limit.toString();
      }
      
      // If no parameters provided, return empty list
      if (queryParams.isEmpty) {
        print('⚠️ No search parameters provided');
        return [];
      }
      
      // Build URL with query parameters
      String url = ApiConfig.searchEvents;
      final queryString = queryParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url = '$url?$queryString';
      
      print('📡 Search API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headers,
      ).timeout(const Duration(seconds: 15));

      print('📊 Search API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Search API Response Body: ${response.body}');
        
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          
          if (data['success'] == true) {
            // Handle the actual API response format: data.events
            List<dynamic> eventsJson = [];
            
            if (data['data'] != null && data['data']['events'] != null) {
              eventsJson = data['data']['events'];
            } else if (data['events'] != null) {
              // Fallback for direct events format
              eventsJson = data['events'];
            }
            
            // Parse events with error handling for each event
            List<Event> events = [];
            print('🔄 Starting to parse ${eventsJson.length} events...');
            
            for (int i = 0; i < eventsJson.length; i++) {
              try {
                print('   Parsing event ${i + 1}: ${eventsJson[i]['eventName'] ?? 'Unknown'}');
                final event = Event.fromJson(eventsJson[i]);
                events.add(event);
                print('   ✅ Successfully parsed: ${event.title}');
              } catch (eventError, stackTrace) {
                print('⚠️ Error parsing event at index $i: $eventError');
                print('   Stack trace: $stackTrace');
                print('   Event JSON: ${eventsJson[i]}');
                // Continue parsing other events
              }
            }
            
            print('🎉 Successfully parsed ${events.length} out of ${eventsJson.length} events');
            
            // Log first event details for debugging
            if (events.isNotEmpty) {
              final firstEvent = events.first;
              print('📋 First event details:');
              print('   ID: ${firstEvent.id}');
              print('   Title: ${firstEvent.title}');
              print('   City: ${firstEvent.city}');
              print('   Cover Charge: ${firstEvent.coverCharge}');
            }
            
            // Log pagination info if available
            if (data['data'] != null && data['data']['pagination'] != null) {
              final pagination = data['data']['pagination'];
              print('📄 Pagination: ${pagination['total']} total events, page ${pagination['page']}/${pagination['totalPages']}');
            }
            
            return events;
          } else {
            print('❌ API returned success: false - $data');
            return [];
          }
        } catch (jsonError) {
          print('🚨 JSON parsing error in search: $jsonError');
          print('🚨 Response body: ${response.body}');
          return [];
        }
      } else {
        print('❌ Search HTTP ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('🚨 Error searching events: $e');
      return [];
    }
  }

  /// Search events by city only
  /// 
  /// [city] - City to search in (e.g., "Delhi", "Mumbai")
  /// 
  /// Returns a list of events in the specified city
  static Future<List<Event>> searchEventsByCity(String city) async {
    return searchEvents(city: city);
  }

  /// Search for events when user types a city name
  /// 
  /// This method handles the case where user searches for their own city name
  /// by using city-only search instead of text search
  static Future<List<Event>> searchInCity(String query, String userCity) async {
    // If user is searching for their own city or a city name, use city-only search
    if (query.toLowerCase().trim() == userCity.toLowerCase().trim()) {
      print('🏙️ User searching for their own city, using city-only search');
      return searchEventsByCity(userCity);
    }
    
    // Check if query looks like a city name (common Indian cities)
    final commonCities = [
      'delhi', 'mumbai', 'bangalore', 'chennai', 'kolkata', 'hyderabad',
      'pune', 'ahmedabad', 'jaipur', 'surat', 'lucknow', 'kanpur',
      'nagpur', 'indore', 'thane', 'bhopal', 'visakhapatnam', 'pimpri',
      'patna', 'vadodara', 'ghaziabad', 'ludhiana', 'agra', 'nashik',
      'faridabad', 'meerut', 'rajkot', 'kalyan', 'vasai', 'varanasi',
      'srinagar', 'aurangabad', 'dhanbad', 'amritsar', 'navi mumbai',
      'allahabad', 'ranchi', 'howrah', 'coimbatore', 'jabalpur',
      'gwalior', 'vijayawada', 'jodhpur', 'madurai', 'raipur',
      'kota', 'guwahati', 'chandigarh', 'solapur', 'hubli', 'tiruchirappalli',
      'bareilly', 'mysore', 'tiruppur', 'gurgaon', 'aligarh', 'jalandhar',
      'bhubaneswar', 'salem', 'warangal', 'guntur', 'bhiwandi', 'saharanpur',
      'gorakhpur', 'bikaner', 'amravati', 'noida', 'jamshedpur', 'bhilai',
      'cuttack', 'firozabad', 'kochi', 'nellore', 'bhavnagar', 'dehradun'
    ];
    
    if (commonCities.contains(query.toLowerCase().trim())) {
      print('🏙️ Query appears to be a city name, using city-only search');
      return searchEventsByCity(query);
    }
    
    // Otherwise, use regular search with both query and city
    return searchEvents(query: query, city: userCity);
  }

  /// Search events by query only (no city filter)
  /// 
  /// [query] - Search term for events
  /// 
  /// Returns a list of events matching the query
  static Future<List<Event>> searchEventsByQuery(String query) async {
    return searchEvents(query: query);
  }

  /// Get popular search suggestions based on city
  /// 
  /// This could be extended to call a suggestions API in the future
  static List<String> getSearchSuggestions(String city) {
    // Default suggestions - could be made dynamic from API
    final suggestions = <String>[
      'Music concerts',
      'Comedy shows',
      'Art exhibitions',
      'Food festivals',
      'Tech meetups',
      'Dance performances',
      'Theater shows',
      'Sports events',
      'Workshops',
      'Networking events',
    ];
    
    return suggestions;
  }

  /// Validate search query
  static bool isValidSearchQuery(String? query) {
    return query != null && query.trim().isNotEmpty && query.trim().length >= 2;
  }

  /// Validate city name
  static bool isValidCity(String? city) {
    return city != null && city.trim().isNotEmpty && city.trim().length >= 2;
  }

  /// Search events with detailed response including pagination
  /// 
  /// Returns a SearchResult object with events and pagination info
  static Future<SearchResult> searchEventsWithPagination({
    String? query,
    String? city,
    int page = 1,
    int limit = 15,
  }) async {
    try {
      print('🔍 Searching events with pagination - Query: "$query", City: "$city", Page: $page');
      
      // Build query parameters
      Map<String, String> queryParams = {};
      
      if (query != null && query.trim().isNotEmpty) {
        queryParams['q'] = query.trim();
      }
      
      if (city != null && city.trim().isNotEmpty) {
        queryParams['city'] = city.trim();
      }
      
      // Add pagination parameters
      if (page > 1) {
        queryParams['page'] = page.toString();
      }
      
      if (limit != 15) {
        queryParams['limit'] = limit.toString();
      }
      
      // If no parameters provided, return empty result
      if (queryParams.isEmpty) {
        print('⚠️ No search parameters provided');
        return SearchResult.empty();
      }
      
      // Build URL with query parameters
      String url = ApiConfig.searchEvents;
      final queryString = queryParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url = '$url?$queryString';
      
      print('📡 Search API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headers,
      ).timeout(const Duration(seconds: 15));

      print('📊 Search API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Search API Response Body: ${response.body}');
        
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          
          if (data['success'] == true) {
            // Handle the actual API response format: data.events
            List<dynamic> eventsJson = [];
            Map<String, dynamic>? paginationData;
            Map<String, dynamic>? filtersData;
            
            if (data['data'] != null) {
              if (data['data']['events'] != null) {
                eventsJson = data['data']['events'];
              }
              paginationData = data['data']['pagination'];
              filtersData = data['data']['appliedFilters'];
            } else if (data['events'] != null) {
              // Fallback for direct events format
              eventsJson = data['events'];
            }
            
            // Parse events with error handling for each event
            List<Event> events = [];
            for (int i = 0; i < eventsJson.length; i++) {
              try {
                final event = Event.fromJson(eventsJson[i]);
                events.add(event);
              } catch (eventError) {
                print('⚠️ Error parsing event at index $i: $eventError');
                print('   Event JSON: ${eventsJson[i]}');
                // Continue parsing other events
              }
            }
            
            print('🎉 Successfully parsed ${events.length} out of ${eventsJson.length} events');
            
            return SearchResult(
              events: events,
              pagination: paginationData != null ? PaginationInfo.fromJson(paginationData) : null,
              appliedFilters: filtersData,
              success: true,
            );
          } else {
            print('❌ API returned success: false - $data');
            return SearchResult.error('Search failed');
          }
        } catch (jsonError) {
          print('🚨 JSON parsing error in search: $jsonError');
          print('🚨 Response body: ${response.body}');
          return SearchResult.error('Failed to parse search results');
        }
      } else {
        print('❌ Search HTTP ${response.statusCode}: ${response.body}');
        return SearchResult.error('Search request failed');
      }
    } catch (e) {
      print('🚨 Error searching events: $e');
      return SearchResult.error('Network error occurred');
    }
  }
}

/// Search result with pagination information
class SearchResult {
  final List<Event> events;
  final PaginationInfo? pagination;
  final Map<String, dynamic>? appliedFilters;
  final bool success;
  final String? error;

  SearchResult({
    required this.events,
    this.pagination,
    this.appliedFilters,
    required this.success,
    this.error,
  });

  factory SearchResult.empty() {
    return SearchResult(
      events: [],
      success: true,
    );
  }

  factory SearchResult.error(String errorMessage) {
    return SearchResult(
      events: [],
      success: false,
      error: errorMessage,
    );
  }

  bool get hasResults => events.isNotEmpty;
  bool get hasMorePages => pagination?.hasNext ?? false;
  int get totalResults => pagination?.total ?? 0;
}

/// Pagination information from API response
class PaginationInfo {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationInfo({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 15,
      totalPages: json['totalPages'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}