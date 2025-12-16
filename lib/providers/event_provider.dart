import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5); // Cache for 5 minutes

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _events.isNotEmpty;

  List<Event> get trendingEvents => _events.where((event) => event.isTrending).toList();

  // Check if we need to fetch data (no data or cache expired)
  bool get shouldFetchData {
    if (_events.isEmpty) return true;
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) > _cacheValidDuration;
  }

  // Fetch events only if needed (no cache or cache expired)
  Future<void> fetchEventsIfNeeded() async {
    if (!shouldFetchData) return;
    await fetchEvents();
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

  List<Event> getFilteredEvents(String filter) {
    if (filter == 'All') {
      return _events;
    }
    return _events.where((event) => 
      event.tags.any((tag) => tag.toLowerCase().contains(filter.toLowerCase()))
    ).toList();
  }

  List<Event> getEventsByCategory(String category) {
    if (category == 'All') {
      return _events;
    }
    return _events.where((event) => 
      event.tags.any((tag) => tag.toLowerCase().contains(category.toLowerCase()))
    ).toList();
  }
}