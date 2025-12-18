import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event_model.dart';

class MapsService {
  /// Opens Google Maps with directions to the event location
  static Future<bool> openDirections(Event event) async {
    try {
      // Get coordinates from event
      double? latitude;
      double? longitude;
      
      if (event.eventLocation?.coordinates != null && 
          event.eventLocation!.coordinates.length >= 2) {
        // Coordinates are stored as [longitude, latitude] in GeoJSON format
        longitude = event.eventLocation!.coordinates[0];
        latitude = event.eventLocation!.coordinates[1];
      }

      String url;
      
      if (latitude != null && longitude != null) {
        // Use coordinates for precise location
        url = _buildMapsUrlWithCoordinates(latitude, longitude, event);
      } else {
        // Fallback to address-based search
        url = _buildMapsUrlWithAddress(event);
      }

      print('Opening maps URL: $url');
      
      final Uri uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        print('Could not launch maps URL: $url');
        return false;
      }
    } catch (e) {
      print('Error opening directions: $e');
      return false;
    }
  }

  /// Builds Google Maps URL using coordinates
  static String _buildMapsUrlWithCoordinates(double latitude, double longitude, Event event) {
    final String destination = '$latitude,$longitude';
    final String label = Uri.encodeComponent(event.title);
    
    if (Platform.isIOS) {
      // iOS: Use Apple Maps or Google Maps
      return 'https://maps.apple.com/?daddr=$destination&dirflg=d&t=m';
    } else {
      // Android: Use Google Maps
      return 'https://www.google.com/maps/dir/?api=1&destination=$destination&destination_place_id=&travelmode=driving';
    }
  }

  /// Builds Google Maps URL using address search
  static String _buildMapsUrlWithAddress(Event event) {
    String searchQuery = '';
    
    // Build search query from available location data
    if (event.fullAddress.isNotEmpty) {
      searchQuery = event.fullAddress;
    } else if (event.location.isNotEmpty) {
      searchQuery = event.location;
    } else {
      searchQuery = event.title; // Fallback to event title
    }
    
    final String encodedQuery = Uri.encodeComponent(searchQuery);
    
    if (Platform.isIOS) {
      // iOS: Use Apple Maps
      return 'https://maps.apple.com/?q=$encodedQuery&dirflg=d';
    } else {
      // Android: Use Google Maps
      return 'https://www.google.com/maps/search/?api=1&query=$encodedQuery';
    }
  }

  /// Opens Google Maps to show the event location (without directions)
  static Future<bool> openLocation(Event event) async {
    try {
      double? latitude;
      double? longitude;
      
      if (event.eventLocation?.coordinates != null && 
          event.eventLocation!.coordinates.length >= 2) {
        longitude = event.eventLocation!.coordinates[0];
        latitude = event.eventLocation!.coordinates[1];
      }

      String url;
      
      if (latitude != null && longitude != null) {
        // Use coordinates for precise location
        final String location = '$latitude,$longitude';
        final String label = Uri.encodeComponent(event.title);
        
        if (Platform.isIOS) {
          url = 'https://maps.apple.com/?q=$location';
        } else {
          url = 'https://www.google.com/maps/search/?api=1&query=$location';
        }
      } else {
        // Fallback to address-based search
        String searchQuery = event.fullAddress.isNotEmpty 
            ? event.fullAddress 
            : event.location.isNotEmpty 
                ? event.location 
                : event.title;
        
        final String encodedQuery = Uri.encodeComponent(searchQuery);
        
        if (Platform.isIOS) {
          url = 'https://maps.apple.com/?q=$encodedQuery';
        } else {
          url = 'https://www.google.com/maps/search/?api=1&query=$encodedQuery';
        }
      }

      print('Opening location URL: $url');
      
      final Uri uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        print('Could not launch location URL: $url');
        return false;
      }
    } catch (e) {
      print('Error opening location: $e');
      return false;
    }
  }

  /// Shows a dialog to choose between directions and just viewing location
  static Future<void> showMapsOptions(Event event, Function(String) showSnackBar) async {
    try {
      // For now, directly open directions
      final success = await openDirections(event);
      
      if (!success) {
        showSnackBar('Unable to open maps. Please check if you have a maps app installed.');
      }
    } catch (e) {
      print('Error in showMapsOptions: $e');
      // Log detailed error for developers
      debugPrint('🚨 [MapsService] Maps error: $e');
      showSnackBar('Failed to open maps. Please try again');
    }
  }

  /// Opens Google Maps with a specific coordinate and label
  static Future<bool> openMapsWithCoordinates(double latitude, double longitude, String label) async {
    try {
      final String destination = '$latitude,$longitude';
      final String encodedLabel = Uri.encodeComponent(label);
      
      String url;
      if (Platform.isIOS) {
        url = 'https://maps.apple.com/?q=$destination&ll=$destination';
      } else {
        url = 'https://www.google.com/maps/search/?api=1&query=$destination';
      }

      final Uri uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error opening maps with coordinates: $e');
      return false;
    }
  }

  /// Gets the best available location string for display
  static String getBestLocationString(Event event) {
    if (event.fullAddress.isNotEmpty) {
      return event.fullAddress;
    }
    
    if (event.location.isNotEmpty && event.city.isNotEmpty && event.location != event.city) {
      return '${event.location}, ${event.city}';
    }
    
    if (event.location.isNotEmpty) {
      return event.location;
    }
    
    if (event.city.isNotEmpty) {
      return event.city;
    }
    
    return 'Location not specified';
  }

  /// Validates if the event has location data
  static bool hasLocationData(Event event) {
    return (event.eventLocation?.coordinates != null && 
            event.eventLocation!.coordinates.length >= 2) ||
           event.fullAddress.isNotEmpty ||
           event.location.isNotEmpty;
  }

  /// Gets a formatted address string for display
  static String getFormattedAddress(Event event) {
    if (event.fullAddress.isNotEmpty) {
      return event.fullAddress;
    } else if (event.location.isNotEmpty) {
      return event.location;
    } else {
      return 'Location not specified';
    }
  }

  /// Gets coordinates as a formatted string
  static String? getCoordinatesString(Event event) {
    if (event.eventLocation?.coordinates != null && 
        event.eventLocation!.coordinates.length >= 2) {
      final longitude = event.eventLocation!.coordinates[0];
      final latitude = event.eventLocation!.coordinates[1];
      return '$latitude, $longitude';
    }
    return null;
  }
}