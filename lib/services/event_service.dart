import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import 'api_routes.dart';

class EventService {
  static Future<List<Event>> fetchEvents() async {
    // List of endpoints to try
    final endpoints = [
      ApiConfig.getEvents,
      ApiConfig.getEventsAlt1,
      ApiConfig.getEventsAlt2,
      ApiConfig.getEventsAlt3,
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
}