class EventHost {
  final String id;
  final String role;
  final String name;
  final int eventsHosted;

  EventHost({
    required this.id,
    required this.role,
    required this.name,
    required this.eventsHosted,
  });

  factory EventHost.fromJson(Map<String, dynamic> json) {
    return EventHost(
      id: json['_id'] ?? '',
      role: json['role'] ?? 'host',
      name: json['name'] ?? 'Unknown Host',
      eventsHosted: json['eventsHosted'] ?? 0,
    );
  }
}

class EventLocation {
  final String type;
  final List<double> coordinates;

  EventLocation({
    required this.type,
    required this.coordinates,
  });

  factory EventLocation.fromJson(Map<String, dynamic> json) {
    return EventLocation(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(json['coordinates'] ?? [0.0, 0.0]),
    );
  }
}

class TicketPass {
  final String id;
  final String type;
  final double price;
  final int totalQuantity;
  final int remainingQuantity;

  TicketPass({
    required this.id,
    required this.type,
    required this.price,
    required this.totalQuantity,
    required this.remainingQuantity,
  });

  factory TicketPass.fromJson(Map<String, dynamic> json) {
    return TicketPass(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      totalQuantity: json['totalQuantity'] ?? 0,
      remainingQuantity: json['remainingQuantity'] ?? 0,
    );
  }
}

class Event {
  final String id;
  final String title;
  final String? subtitle;
  final String date;
  final String? day;
  final DateTime? eventDateTime;
  final String location;
  final String fullAddress;
  final String city;
  final String coverCharge;
  final String imageUrl;
  final List<String> tags;
  final bool isTrending;
  final String? status;
  final String? time;
  final String? ageRestriction;
  final String? genderPreference;
  final String? entryFee;
  final String? aboutParty;
  final String? partyFlow;
  final String? thingsToKnow;
  final String? partyTerms;
  final String? partyEtiquette;
  final String? whatsIncluded;
  final String? houseRules;
  final String? howItWorks;
  final String? cancellationPolicy;
  final EventHost? hostInfo;
  final String? hostName;
  final EventLocation? eventLocation;
  final int? maxCapacity;
  final int currentBookings;
  final List<String>? categories;
  // New fields from API
  final String? whatsIncludedInTicket;
  final String? expectedGuestCount;
  final String? maleToFemaleRatio;
  final List<TicketPass>? passes;
  // Legacy fields for backward compatibility
  final String? djName;
  final String? djImage;
  final double? rating;
  final int? ratingCount;
  final int? partiesHosted;
  final String? maleTicketPrice;
  final String? femaleTicketPrice;
  final String? coupleTicketPrice;

  Event({
    required this.id,
    required this.title,
    this.subtitle,
    required this.date,
    this.day,
    this.eventDateTime,
    required this.location,
    required this.fullAddress,
    required this.city,
    required this.coverCharge,
    required this.imageUrl,
    required this.tags,
    this.isTrending = false,
    this.status,
    this.time,
    this.ageRestriction,
    this.genderPreference,
    this.entryFee,
    this.aboutParty,
    this.partyFlow,
    this.thingsToKnow,
    this.partyTerms,
    this.partyEtiquette,
    this.whatsIncluded,
    this.houseRules,
    this.howItWorks,
    this.cancellationPolicy,
    this.hostInfo,
    this.hostName,
    this.eventLocation,
    this.maxCapacity,
    this.currentBookings = 0,
    this.categories,
    // New fields from API
    this.whatsIncludedInTicket,
    this.expectedGuestCount,
    this.maleToFemaleRatio,
    this.passes,
    // Legacy fields for backward compatibility
    this.djName,
    this.djImage,
    this.rating,
    this.ratingCount,
    this.partiesHosted,
    this.maleTicketPrice,
    this.femaleTicketPrice,
    this.coupleTicketPrice,
  });

  // Factory constructor to create Event from API JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    // Convert categories to tags with proper formatting
    List<String> tags = [];
    
    // Handle both array format (old) and string format (new)
    if (json['categories'] != null) {
      if (json['categories'] is List) {
        // Old format: array of categories
        tags = (json['categories'] as List<dynamic>)
            .map((category) => category.toString().toUpperCase())
            .toList();
      } else if (json['categories'] is String) {
        // New format: comma-separated string
        tags = (json['categories'] as String)
            .split(',')
            .map((category) => category.trim().toUpperCase())
            .where((category) => category.isNotEmpty)
            .toList();
      }
    }
    
    // Handle category field (string format)
    if (json['category'] != null && json['category'] is String) {
      final categoryTags = (json['category'] as String)
          .split(',')
          .map((category) => category.trim().toUpperCase())
          .where((category) => category.isNotEmpty)
          .toList();
      tags.addAll(categoryTags);
    }
    
    // Add age restriction as a tag if available (will be styled in yellow)
    if (json['ageRestriction'] != null) {
      tags.add('AGE: ${json['ageRestriction']}');
    }

    // Format date from ISO string to readable format
    String formattedDate = json['date'] ?? '';
    if (formattedDate.isNotEmpty) {
      try {
        DateTime dateTime = DateTime.parse(formattedDate);
        List<String> months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        formattedDate = '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
      } catch (e) {
        formattedDate = json['date'] ?? '';
      }
    }

    // Parse event date time
    DateTime? eventDateTime;
    if (json['eventDateTime'] != null) {
      try {
        eventDateTime = DateTime.parse(json['eventDateTime']);
      } catch (e) {
        eventDateTime = null;
      }
    }

    // Parse host information
    EventHost? hostInfo;
    if (json['hostId'] != null) {
      hostInfo = EventHost.fromJson(json['hostId']);
    }

    // Parse location information
    EventLocation? eventLocation;
    if (json['location'] != null) {
      eventLocation = EventLocation.fromJson(json['location']);
    }

    // Build image URL - handle both object and string formats
    String imageUrl = 'assets/images/house_party.jpg';
    
    if (json['eventImage'] != null) {
      if (json['eventImage'] is Map) {
        // New format: object with url, publicId, version
        imageUrl = json['eventImage']['url'] ?? 'assets/images/house_party.jpg';
        print('📸 Parsed image URL from object: $imageUrl');
      } else if (json['eventImage'] is String) {
        // Old format: string URL
        imageUrl = json['eventImage'];
        if (imageUrl.startsWith('/uploads/')) {
          imageUrl = 'http://api.unrealvibe.com$imageUrl';
        }
        print('📸 Parsed image URL from string: $imageUrl');
      }
    } else {
      print('⚠️ No eventImage found in JSON, using default');
    }

    // Parse categories
    List<String>? categories;
    if (json['categories'] != null) {
      categories = List<String>.from(json['categories']);
    }

    // Parse passes
    List<TicketPass>? passes;
    if (json['passes'] != null) {
      passes = (json['passes'] as List)
          .map((pass) => TicketPass.fromJson(pass))
          .toList();
    }

    return Event(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['eventName'] ?? 'Untitled Event',
      subtitle: json['subtitle'],
      date: formattedDate,
      day: json['day'],
      eventDateTime: eventDateTime,
      location: json['city'] ?? 'Unknown Location',
      fullAddress: json['fullAddress'] ?? '',
      city: json['city'] ?? '',
      coverCharge: _formatCoverCharge(json),
      imageUrl: imageUrl,
      tags: tags,
      isTrending: json['trending'] ?? false,
      status: json['status'],
      time: json['time'],
      ageRestriction: json['ageRestriction'],
      genderPreference: json['genderPreference'],
      entryFee: _formatCoverCharge(json),
      aboutParty: json['about'],
      partyFlow: json['partyFlow'],
      thingsToKnow: json['thingsToKnow'],
      partyTerms: json['partyTerms'],
      partyEtiquette: json['partyEtiquette'],
      whatsIncluded: json['whatsIncluded'],
      houseRules: json['houseRules'],
      howItWorks: json['howItWorks'],
      cancellationPolicy: json['cancellationPolicy'],
      hostInfo: hostInfo,
      hostName: json['hostedBy'],
      eventLocation: eventLocation,
      maxCapacity: json['maxCapacity'],
      currentBookings: json['currentBookings'] ?? 0,
      categories: categories,
      // New fields from API
      whatsIncludedInTicket: json['whatsIncludedInTicket'],
      expectedGuestCount: json['expectedGuestCount'],
      maleToFemaleRatio: json['maleToFemaleRatio'],
      passes: passes,
      // Legacy fields for backward compatibility
      djName: null, // Not available in new API
      djImage: null, // Not available in new API
      rating: null, // Not available in new API
      ratingCount: null, // Not available in new API
      partiesHosted: hostInfo?.eventsHosted ?? json['totalEventsHosted'],
      maleTicketPrice: json['maleTicketPrice'] ?? '₹ 1500',
      femaleTicketPrice: json['femaleTicketPrice'] ?? '₹ 1200',
      coupleTicketPrice: json['coupleTicketPrice'] ?? '₹ 2500',
    );
  }

  // Helper method to format cover charge from different possible fields
  static String _formatCoverCharge(Map<String, dynamic> json) {
    // Try entryFees first (legacy)
    if (json['entryFees'] != null) {
      return '₹ ${json['entryFees']}';
    }
    
    // Try passes array (new format)
    if (json['passes'] != null && json['passes'] is List && (json['passes'] as List).isNotEmpty) {
      final passes = json['passes'] as List;
      final prices = passes.map((pass) => pass['price'] ?? 0).where((price) => price > 0).toList();
      
      if (prices.isNotEmpty) {
        prices.sort();
        if (prices.length == 1) {
          return '₹ ${prices.first}';
        } else {
          return '₹ ${prices.first} - ${prices.last}';
        }
      }
    }
    
    // Default fallback
    return 'Free';
  }


}
