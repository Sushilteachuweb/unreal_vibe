import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Event> get trendingEvents => _events.where((event) => event.isTrending).toList();

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await EventService.fetchEvents();
      _error = null;
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