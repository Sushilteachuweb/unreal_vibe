// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_routes.dart';
import 'user_storage.dart';
import '../models/user_model.dart';

class ProfileService {
  // Create Profile
  static Future<Map<String, dynamic>> createProfile({
    required String name,
    required String email,
    required String city,
    required String gender,
  }) async {
    try {
      final token = await UserStorage.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      }

      print("👤 Calling Create Profile API: ${ApiConfig.createProfile}");
      print("👤 Request Body: {name: $name, email: $email, city: $city, gender: $gender}");

      final response = await http.post(
        Uri.parse(ApiConfig.createProfile),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode({
          "name": name,
          "email": email,
          "city": city,
          "gender": gender,
        }),
      );

      print("👤 Raw Response: ${response.body}");
      print("👤 Status Code: ${response.statusCode}");

      final data = jsonDecode(response.body);
      print("👤 Decoded JSON: $data");

      if (response.statusCode == 200 && data['success'] == true) {
        // Update user data in storage
        if (data['user'] != null) {
          final user = User.fromJson(data['user']);
          await UserStorage.saveUser(user);
          print("👤 Profile created and saved: ${user.id}");
        }

        print("👤 Profile created successfully");
        return {
          'success': true,
          'message': data['message'] ?? 'Profile created successfully',
          'user': data['user'],
          'isProfileComplete': data['isProfileComplete'] ?? true,
        };
      } else {
        print("👤 Create profile failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create profile',
        };
      }
    } catch (e) {
      print("👤 Create profile error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // Complete Profile (with documents and profile photo)
  static Future<Map<String, dynamic>> completeProfile({
    required String name,
    required String email,
    required String city,
    required String gender,
    String? bio,
    String? funFact,
    List<String>? interests,
    File? aadhaar,
    File? drivingLicense,
    File? pan,
    File? profilePhoto,
  }) async {
    try {
      final token = await UserStorage.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      }

      print("👤 Calling Complete Profile API: ${ApiConfig.completeProfile}");
      print("👤 Request Data: {name: $name, email: $email, city: $city, gender: $gender, bio: $bio, funFact: $funFact, interests: $interests}");

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(ApiConfig.completeProfile),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['city'] = city;
      request.fields['gender'] = gender;
      
      // Add optional text fields
      if (bio != null && bio.isNotEmpty) {
        request.fields['bio'] = bio;
      }
      
      if (funFact != null && funFact.isNotEmpty) {
        request.fields['funFact'] = funFact;
      }
      
      // Add interests as JSON array string
      if (interests != null && interests.isNotEmpty) {
        request.fields['interests'] = jsonEncode(interests);
      }

      // Add file fields with explicit content type
      if (aadhaar != null) {
        final mimeType = _getMimeType(aadhaar.path);
        request.files.add(await http.MultipartFile.fromPath(
          'aadhaar',
          aadhaar.path,
          contentType: mimeType,
        ));
        print("👤 Added aadhaar file: ${aadhaar.path} (${mimeType?.mimeType})");
      }

      if (drivingLicense != null) {
        final mimeType = _getMimeType(drivingLicense.path);
        request.files.add(await http.MultipartFile.fromPath(
          'drivingLicense',
          drivingLicense.path,
          contentType: mimeType,
        ));
        print("👤 Added drivingLicense file: ${drivingLicense.path} (${mimeType?.mimeType})");
      }

      if (pan != null) {
        final mimeType = _getMimeType(pan.path);
        request.files.add(await http.MultipartFile.fromPath(
          'pan',
          pan.path,
          contentType: mimeType,
        ));
        print("👤 Added pan file: ${pan.path} (${mimeType?.mimeType})");
      }

      if (profilePhoto != null) {
        final mimeType = _getMimeType(profilePhoto.path);
        request.files.add(await http.MultipartFile.fromPath(
          'profilePhoto',
          profilePhoto.path,
          contentType: mimeType,
        ));
        print("👤 Added profilePhoto file: ${profilePhoto.path} (${mimeType?.mimeType})");
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("👤 Raw Response: ${response.body}");
      print("👤 Status Code: ${response.statusCode}");

      // Handle 413 error (file too large)
      if (response.statusCode == 413) {
        print("👤 Complete profile failed: Files too large");
        return {
          'success': false,
          'message': 'Files are too large. Please use smaller images (max 1MB each).',
        };
      }

      // Handle non-JSON responses
      if (!response.body.startsWith('{')) {
        print("👤 Complete profile failed: Invalid response format");
        return {
          'success': false,
          'message': 'Server error. Please try again later.',
        };
      }

      final data = jsonDecode(response.body);
      print("👤 Decoded JSON: $data");

      if (response.statusCode == 200 && data['success'] == true) {
        // Update user data in storage
        if (data['user'] != null) {
          final user = User.fromJson(data['user']);
          await UserStorage.saveUser(user);
          print("👤 Profile completed and saved: ${user.id}");
        }

        print("👤 Profile completed successfully");
        return {
          'success': true,
          'message': data['message'] ?? 'Profile completed successfully',
          'user': data['user'],
          'isProfileComplete': data['isProfileComplete'] ?? true,
        };
      } else {
        print("👤 Complete profile failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to complete profile',
        };
      }
    } catch (e) {
      print("👤 Complete profile error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // Get Profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await UserStorage.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      }

      print("👤 Calling Get Profile API: ${ApiConfig.getProfile}");
      print("👤 Using token: ${token.substring(0, 20)}...");

      final response = await http.get(
        Uri.parse(ApiConfig.getProfile),
        headers: ApiConfig.getAuthHeaders(token),
      );

      print("👤 Raw Response: ${response.body}");
      print("👤 Status Code: ${response.statusCode}");

      final data = jsonDecode(response.body);
      print("👤 Decoded JSON: $data");

      if (response.statusCode == 200 && data['success'] == true) {
        if (data['user'] != null) {
          final user = User.fromJson(data['user']);
          await UserStorage.saveUser(user);
          print("👤 Profile fetched and saved: ${user.id}");
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Profile fetched successfully',
          'user': data['user'],
        };
      } else {
        print("👤 Get profile failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch profile',
        };
      }
    } catch (e) {
      print("👤 Get profile error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // Helper function to get MIME type from file path
  static MediaType? _getMimeType(String path) {
    final extension = path.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg'); // Default to jpeg
    }
  }
}
