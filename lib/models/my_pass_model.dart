class MyPass {
  final String id;
  final String eventId;
  final String bookingId;
  final String eventName;
  final String eventImage;
  final String passType;
  final int quantity;
  final DateTime eventDate;
  final String eventTime;
  final String venue;
  final String city;
  final String status; // upcoming, past, cancelled
  final String? qrCode;
  final DateTime createdAt;

  MyPass({
    required this.id,
    required this.eventId,
    required this.bookingId,
    required this.eventName,
    required this.eventImage,
    required this.passType,
    required this.quantity,
    required this.eventDate,
    required this.eventTime,
    required this.venue,
    required this.city,
    required this.status,
    this.qrCode,
    required this.createdAt,
  });

  factory MyPass.fromJson(Map<String, dynamic> json) {
    print('Parsing MyPass from JSON: $json');
    
    try {
      // Handle eventId which can be either a string or an object
      final eventData = json['eventId'];
      String eventIdString = '';
      String eventName = '';
      String eventImage = '';
      String eventTime = '';
      String city = '';
      DateTime eventDate = DateTime.now();
      
      if (eventData is Map<String, dynamic>) {
        // eventId is an object with event details
        eventIdString = eventData['_id'] ?? '';
        eventName = eventData['eventName'] ?? '';
        eventImage = eventData['eventImage'] ?? '';
        eventTime = eventData['time'] ?? '';
        city = eventData['city'] ?? '';
        eventDate = DateTime.tryParse(eventData['date'] ?? '') ?? DateTime.now();
      } else if (eventData is String) {
        // eventId is just a string
        eventIdString = eventData;
        eventName = json['eventName'] ?? '';
        eventImage = json['eventImage'] ?? '';
        eventTime = json['eventTime'] ?? '';
        city = json['city'] ?? '';
        eventDate = DateTime.tryParse(json['eventDate'] ?? '') ?? DateTime.now();
      }
      
      final pass = MyPass(
        id: json['_id'] ?? json['id'] ?? '',
        eventId: eventIdString,
        bookingId: json['bookingId'] ?? json['booking_id'] ?? json['_id'] ?? '',
        eventName: eventName,
        eventImage: eventImage,
        passType: json['ticketType'] ?? json['passType'] ?? json['type'] ?? '',
        quantity: json['quantity'] ?? 1,
        eventDate: eventDate,
        eventTime: eventTime,
        venue: json['venue'] ?? 'Venue', // Default venue since it's not in the API response
        city: city,
        status: json['status'] ?? 'active',
        qrCode: json['qrCode'],
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
      
      print('Successfully created MyPass: ${pass.eventName} (${pass.passType})');
      return pass;
    } catch (e) {
      print('Error parsing MyPass: $e');
      rethrow;
    }
  }

  bool get isUpcoming => (status == 'active' || status == 'upcoming') && eventDate.isAfter(DateTime.now());
  bool get isPast => status == 'past' || eventDate.isBefore(DateTime.now());
  bool get isCancelled => status == 'cancelled';

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return '${months[eventDate.month - 1]} ${eventDate.day} | ${weekdays[eventDate.weekday - 1]} | $eventTime';
  }
}

class MyPassesResponse {
  final bool success;
  final String message;
  final List<MyPass> passes;

  MyPassesResponse({
    required this.success,
    required this.message,
    required this.passes,
  });

  factory MyPassesResponse.fromJson(Map<String, dynamic> json) {
    print('Parsing MyPassesResponse from JSON: $json');
    
    try {
      final passesList = json['passes'] as List<dynamic>? ?? 
                        json['data'] as List<dynamic>? ?? 
                        [];
      
      print('Found ${passesList.length} passes in response');
      
      final passes = passesList
          .map((passJson) => MyPass.fromJson(passJson as Map<String, dynamic>))
          .toList();
      
      final response = MyPassesResponse(
        success: json['success'] ?? true, // Default to true if not specified
        message: json['message'] ?? '',
        passes: passes,
      );
      
      print('Successfully created MyPassesResponse with ${response.passes.length} passes');
      return response;
    } catch (e) {
      print('Error parsing MyPassesResponse: $e');
      // Return empty response on error
      return MyPassesResponse(
        success: false,
        message: 'Failed to parse response: $e',
        passes: [],
      );
    }
  }
}