import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_storage.dart';
import 'api_routes.dart';

class ReviewService {
  static Future<bool> submitReview({
    required String eventId,
    required int rating,
    required String review,
  }) async {
    try {
      print('Submitting review for event: $eventId');
      
      // Get auth token and user ID
      final token = await UserStorage.getToken();
      String? userId = await UserStorage.getUserId();
      
      // If userId is not stored separately, try to get it from user data
      if (userId == null) {
        final user = await UserStorage.getUser();
        userId = user?.id;
      }
      
      print('Token: ${token != null ? "Present" : "Missing"}');
      print('UserId: ${userId != null ? "Present ($userId)" : "Missing"}');
      
      if (token == null || userId == null) {
        throw Exception('Authentication required. Please log in to submit a review.');
      }
      
      final url = ApiConfig.submitReview(eventId);
      
      final requestBody = {
        'eventId': eventId,
        'userId': userId,
        'rating': rating,
        'review': review,
      };
      
      print('Review API URL: $url');
      print('Review request body: $requestBody');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 10));

      print('Review API Response Status: ${response.statusCode}');
      print('Review API Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          
          if (data['success'] == true || response.statusCode == 201) {
            return true;
          } else {
            print('Review API returned success: false');
            return false;
          }
        } catch (jsonError) {
          print('JSON parsing error in review: $jsonError');
          // If JSON parsing fails but status is 200/201, assume success
          return true;
        }
      } else {
        print('Review HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error submitting review: $e');
      return false;
    }
  }
}