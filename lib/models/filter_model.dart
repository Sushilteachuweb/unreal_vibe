class EventFilter {
  final String? category;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? maxDistance; // in kilometers
  final double? userLatitude;
  final double? userLongitude;

  EventFilter({
    this.category,
    this.location,
    this.startDate,
    this.endDate,
    this.maxDistance,
    this.userLatitude,
    this.userLongitude,
  });

  EventFilter copyWith({
    String? category,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    double? maxDistance,
    double? userLatitude,
    double? userLongitude,
  }) {
    return EventFilter(
      category: category ?? this.category,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxDistance: maxDistance ?? this.maxDistance,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
    );
  }

  bool get hasActiveFilters {
    return category != null && category != 'All' ||
           location != null && location!.isNotEmpty ||
           startDate != null ||
           endDate != null ||
           maxDistance != null;
  }

  void clear() {
    // This creates a new empty filter
  }

  static EventFilter empty() {
    return EventFilter(
      category: 'All',
    );
  }
}