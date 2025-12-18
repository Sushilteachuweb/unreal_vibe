import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/filter_model.dart';
import '../services/event_service.dart';
import 'dart:math' as math;

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  List<Event> _trendingEvents = [];
  bool _isLoading = false;
  bool _isTrendingLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  DateTime? _lastTrendingFetchTime;
  EventFilter _currentFilter = EventFilter.empty();
  static const Duration _cacheValidDuration = Duration(minutes: 5); // Cache for 5 minutes

  List<Event> get events => _events;
  List<Event> get trendingEvents => _trendingEvents;
  bool get isLoading => _isLoading;
  bool get isTrendingLoading => _isTrendingLoading;
  String? get error => _error;
  bool get hasData => _events.isNotEmpty;
  EventFilter get currentFilter => _currentFilter;

  // Check if we need to fetch data (no data or cache expired)
  bool get shouldFetchData {
    if (_events.isEmpty) return true;
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) > _cacheValidDuration;
  }

  // Check if we need to fetch trending data (no data or cache expired)
  bool get shouldFetchTrendingData {
    if (_trendingEvents.isEmpty) return true;
    if (_lastTrendingFetchTime == null) return true;
    return DateTime.now().difference(_lastTrendingFetchTime!) > _cacheValidDuration;
  }

  // Fetch events only if needed (no cache or cache expired)
  Future<void> fetchEventsIfNeeded() async {
    if (!shouldFetchData) return;
    await fetchEvents();
  }

  // Fetch trending events only if needed (no cache or cache expired)
  Future<void> fetchTrendingEventsIfNeeded() async {
    if (!shouldFetchTrendingData) return;
    await fetchTrendingEvents();
  }

  // Force fetch events (for pull-to-refresh)
  Future<void> fetchEvents({bool forceRefresh = false}) async {
    if (!forceRefresh && !shouldFetchData) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await EventService.fetchEvents();
      _error = null;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      _error = e.toString();
      // Keep existing events if fetch fails
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Force fetch trending events (for pull-to-refresh)
  Future<void> fetchTrendingEvents({bool forceRefresh = false}) async {
    if (!forceRefresh && !shouldFetchTrendingData) return;

    _isTrendingLoading = true;
    notifyListeners();

    try {
      _trendingEvents = await EventService.fetchTrendingEvents();
      _lastTrendingFetchTime = DateTime.now();
    } catch (e) {
      print('Error fetching trending events: $e');
      // Keep existing trending events if fetch fails
    } finally {
      _isTrendingLoading = false;
      notifyListeners();
    }
  }

  List<Event> getFilteredEvents(String filter) {
    if (filter == 'All') {
      return _events;
    }
    return _events.where((event) => 
      event.tags.any((tag) => 
        !tag.toUpperCase().startsWith('AGE:') && 
        tag.toLowerCase().contains(filter.toLowerCase())
      )
    ).toList();
  }

  // New comprehensive filtering method
  List<Event> getFilteredEventsWithFilter(EventFilter filter) {
    List<Event> filteredEvents = List.from(_events);

    // Filter by category
    if (filter.category != null && filter.category != 'All') {
      filteredEvents = filteredEvents.where((event) => 
        event.tags.any((tag) => 
          !tag.toUpperCase().startsWith('AGE:') && 
          tag.toLowerCase().contains(filter.category!.toLowerCase())
        )
      ).toList();
    }

    // Filter by location
    if (filter.location != null && filter.location!.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) => 
        event.city.toLowerCase().contains(filter.location!.toLowerCase()) ||
        event.location.toLowerCase().contains(filter.location!.toLowerCase()) ||
        event.fullAddress.toLowerCase().contains(filter.location!.toLowerCase())
      ).toList();
    }

    // Filter by date range
    if (filter.startDate != null || filter.endDate != null) {
      filteredEvents = filteredEvents.where((event) {
        if (event.eventDateTime == null) return false;
        
        final eventDate = event.eventDateTime!;
        
        if (filter.startDate != null && eventDate.isBefore(filter.startDate!)) {
          return false;
        }
        
        if (filter.endDate != null && eventDate.isAfter(filter.endDate!.add(const Duration(days: 1)))) {
          return false;
        }
        
        return true;
      }).toList();
    }

    // Filter by distance (if user location and max distance are provided)
    if (filter.maxDistance != null && 
        filter.userLatitude != null && 
        filter.userLongitude != null) {
      filteredEvents = filteredEvents.where((event) {
        if (event.eventLocation?.coordinates == null || 
            event.eventLocation!.coordinates.length < 2) {
          return true; // Include events without location data
        }
        
        final eventLat = event.eventLocation!.coordinates[1];
        final eventLng = event.eventLocation!.coordinates[0];
        
        final distance = _calculateDistance(
          filter.userLatitude!,
          filter.userLongitude!,
          eventLat,
          eventLng,
        );
        
        return distance <= filter.maxDistance!;
      }).toList();
    }

    return filteredEvents;
  }

  // Apply filter and notify listeners
  void applyFilter(EventFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Fetch filtered events from API
  Future<void> fetchFilteredEvents(EventFilter filter) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? startDateStr;
      String? endDateStr;
      
      if (filter.startDate != null) {
        startDateStr = filter.startDate!.toIso8601String();
      }
      if (filter.endDate != null) {
        endDateStr = filter.endDate!.toIso8601String();
      }

      _events = await EventService.filterEvents(
        category: filter.category,
        location: filter.location,
        startDate: startDateStr,
        endDate: endDateStr,
        latitude: filter.userLatitude,
        longitude: filter.userLongitude,
        maxDistance: filter.maxDistance,
      );
      
      _currentFilter = filter;
      _error = null;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      _error = e.toString();
      // Keep existing events if fetch fails
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all filters
  void clearFilters() {
    _currentFilter = EventFilter.empty();
    notifyListeners();
  }

  // Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  List<Event> getEventsByCategory(String category) {
    if (category == 'All') {
      return _events;
    }
    return _events.where((event) => 
      event.tags.any((tag) => 
        !tag.toUpperCase().startsWith('AGE:') && 
        tag.toLowerCase().contains(category.toLowerCase())
      )
    ).toList();
  }

  // Get unique categories from all events
  List<String> getAvailableCategories() {
    final Set<String> categories = {'All'}; // Always include 'All' as first option
    
    for (final event in _events) {
      for (final tag in event.tags) {
        // Clean up the tag and add to categories
        final cleanTag = tag.trim();
        
        // Skip empty tags, 'all', and age restrictions
        if (cleanTag.isNotEmpty && 
            cleanTag.toLowerCase() != 'all' && 
            !cleanTag.toUpperCase().startsWith('AGE:')) {
          categories.add(cleanTag);
        }
      }
    }
    
    // Convert to list and sort (keeping 'All' first)
    final List<String> sortedCategories = categories.toList();
    sortedCategories.remove('All');
    sortedCategories.sort();
    sortedCategories.insert(0, 'All');
    
    return sortedCategories;
  }
}