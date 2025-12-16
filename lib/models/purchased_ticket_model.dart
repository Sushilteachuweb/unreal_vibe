class PurchasedTicket {
  final String id;
  final String bookingId;
  final String eventId;
  final String userId;
  final String ticketNumber;
  final String qrCode;
  final TicketAttendee attendee;
  final String ticketType;
  final double price;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PurchasedTicket({
    required this.id,
    required this.bookingId,
    required this.eventId,
    required this.userId,
    required this.ticketNumber,
    required this.qrCode,
    required this.attendee,
    required this.ticketType,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchasedTicket.fromJson(Map<String, dynamic> json) {
    return PurchasedTicket(
      id: json['_id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      ticketNumber: json['ticketNumber'] ?? '',
      qrCode: json['qrCode'] ?? '',
      attendee: TicketAttendee.fromJson(json['attendee'] ?? {}),
      ticketType: json['ticketType'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      status: json['status'] ?? 'active',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class TicketAttendee {
  final String fullName;
  final String email;
  final String phone;
  final String gender;

  TicketAttendee({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
  });

  factory TicketAttendee.fromJson(Map<String, dynamic> json) {
    return TicketAttendee(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
    );
  }
}

class BookingResponse {
  final bool success;
  final String message;
  final String bookingId;
  final List<PurchasedTicket> tickets;

  BookingResponse({
    required this.success,
    required this.message,
    required this.bookingId,
    required this.tickets,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      bookingId: json['bookingId'] ?? '',
      tickets: (json['tickets'] as List<dynamic>?)
          ?.map((ticketJson) => PurchasedTicket.fromJson(ticketJson))
          .toList() ?? [],
    );
  }
}