import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/event_model.dart';
import '../../models/purchased_ticket_model.dart';

class TicketsScreen extends StatelessWidget {
  final Event event;
  final BookingResponse bookingResponse;

  const TicketsScreen({
    Key? key,
    required this.event,
    required this.bookingResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Tickets',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Event Header
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 8),
                    Text(
                      event.date,
                      style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.location,
                        style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Booking ID: ${bookingResponse.bookingId.substring(bookingResponse.bookingId.length - 8)}',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tickets List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: bookingResponse.tickets.length,
              itemBuilder: (context, index) {
                final ticket = bookingResponse.tickets[index];
                return _buildTicketCard(context, ticket, index);
              },
            ),
          ),
          
          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/main',
                        (route) => false,
                        arguments: 0, // Home tab index
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6958CA),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTicketCard(BuildContext context, PurchasedTicket ticket, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          // Ticket Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF6958CA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ticket ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.ticketNumber,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.ticketType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Ticket Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Attendee Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem(
                        Icons.person,
                        'Attendee',
                        ticket.attendee.fullName,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        Icons.email,
                        'Email',
                        ticket.attendee.email,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        Icons.phone,
                        'Phone',
                        ticket.attendee.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        Icons.wc,
                        'Gender',
                        ticket.attendee.gender,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        Icons.payment,
                        'Price',
                        '₹${ticket.price.toInt()}',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // QR Code - Made bigger and more prominent
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showQrCodeDetails(context, ticket),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Builder(
                          builder: (context) {
                            // Debug QR code data
                            print('🔍 QR Code Data for ${ticket.ticketNumber}: ${ticket.qrCode}');
                            print('🔍 QR Code Length: ${ticket.qrCode.length}');
                            
                            // Check if QR code data is valid
                            if (ticket.qrCode.isEmpty) {
                              return Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'No QR Data',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              );
                            }
                            
                            // Format QR code data for better scanning experience
                            String qrData = _formatQrCodeData(ticket);
                            
                            try {
                              return QrImageView(
                                data: qrData,
                                version: QrVersions.auto,
                                size: 160,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                errorCorrectionLevel: QrErrorCorrectLevel.H, // Higher error correction
                              );
                            } catch (e) {
                              // Fallback: try with just the ticket number
                              try {
                                return QrImageView(
                                  data: ticket.ticketNumber,
                                  version: QrVersions.auto,
                                  size: 160,
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                                );
                              } catch (e2) {
                                return Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6958CA).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.qr_code,
                                          color: Color(0xFF6958CA),
                                          size: 40,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'QR code\nunavailable',
                                          style: TextStyle(
                                            color: Color(0xFF6958CA),
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Show this QR code\nat the venue',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap to view details',
                      style: TextStyle(
                        color: Color(0xFF6958CA),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Ticket Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 8),
                Text(
                  'Active Ticket',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6958CA)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatQrCodeData(PurchasedTicket ticket, {bool humanReadable = true}) {
    try {
      // Try to parse the JSON QR code data
      final qrJson = json.decode(ticket.qrCode);
      
      if (humanReadable) {
        // Create human-readable QR code content that looks good when scanned
        final readableData = '''🎫 EVENT TICKET 🎫

📅 EVENT: ${event.title}
📍 VENUE: ${event.location}
🗓️ DATE: ${event.date}

🎟️ TICKET: ${qrJson['ticketNumber'] ?? ticket.ticketNumber}
💳 TYPE: ${qrJson['passType'] ?? ticket.ticketType}
💰 PRICE: ₹${ticket.price.toInt()}
✅ STATUS: ${ticket.status.toUpperCase()}

👤 ATTENDEE: ${qrJson['attendeeName'] ?? ticket.attendee.fullName}
⚧️ GENDER: ${ticket.attendee.gender}
📧 EMAIL: ${ticket.attendee.email}
📱 PHONE: ${ticket.attendee.phone}

🔖 BOOKING ID: ${qrJson['bookingId'] ?? ticket.bookingId}

🚪 Show this QR code at venue entrance for verification
🔋 Keep phone screen bright for better scanning''';

        print('🔍 Human-Readable QR Data: $readableData');
        return readableData;
      } else {
        // Create structured JSON for machine processing
        final Map<String, dynamic> qrData = {
          'ticketNumber': qrJson['ticketNumber'] ?? ticket.ticketNumber,
          'bookingId': qrJson['bookingId'] ?? ticket.bookingId,
          'eventId': qrJson['eventId'] ?? ticket.eventId,
          'eventName': event.title,
          'attendeeName': qrJson['attendeeName'] ?? ticket.attendee.fullName,
          'attendeeEmail': ticket.attendee.email,
          'attendeePhone': ticket.attendee.phone,
          'passType': qrJson['passType'] ?? ticket.ticketType,
          'gender': ticket.attendee.gender,
          'price': ticket.price.toInt(),
          'status': ticket.status.toUpperCase(),
          'eventDate': event.date,
          'eventLocation': event.location,
          'scanInstructions': 'Show this QR code at venue for entry verification'
        };

        final jsonString = json.encode(qrData);
        print('🔍 Machine-Readable QR Data (JSON): $jsonString');
        return jsonString;
      }
      
    } catch (e) {
      print('❌ Failed to parse QR JSON, using fallback format: $e');
      print('❌ Original QR Code: ${ticket.qrCode}');
      
      if (humanReadable) {
        // Fallback: Create human-readable format with available data
        final fallbackData = '''🎫 EVENT TICKET 🎫

📅 EVENT: ${event.title}
📍 VENUE: ${event.location}
🗓️ DATE: ${event.date}

🎟️ TICKET: ${ticket.ticketNumber}
💳 TYPE: ${ticket.ticketType}
💰 PRICE: ₹${ticket.price.toInt()}
✅ STATUS: ${ticket.status.toUpperCase()}

👤 ATTENDEE: ${ticket.attendee.fullName}
⚧️ GENDER: ${ticket.attendee.gender}
📧 EMAIL: ${ticket.attendee.email}
📱 PHONE: ${ticket.attendee.phone}

🔖 BOOKING ID: ${ticket.bookingId}

🚪 Show this QR code at venue entrance for verification
🔋 Keep phone screen bright for better scanning''';

        print('🔍 Fallback Human-Readable QR Data: $fallbackData');
        return fallbackData;
      } else {
        // Fallback JSON format
        final fallbackData = {
          'ticketNumber': ticket.ticketNumber,
          'bookingId': ticket.bookingId,
          'eventId': ticket.eventId,
          'eventName': event.title,
          'attendeeName': ticket.attendee.fullName,
          'attendeeEmail': ticket.attendee.email,
          'attendeePhone': ticket.attendee.phone,
          'passType': ticket.ticketType,
          'gender': ticket.attendee.gender,
          'price': ticket.price.toInt(),
          'status': ticket.status.toUpperCase(),
          'eventDate': event.date,
          'eventLocation': event.location,
          'scanInstructions': 'Show this QR code at venue for entry verification',
          'originalQrData': ticket.qrCode
        };

        final fallbackJson = json.encode(fallbackData);
        print('🔍 Fallback Machine-Readable QR Data (JSON): $fallbackJson');
        return fallbackJson;
      }
    }
  }

  void _showQrCodeDetails(BuildContext context, PurchasedTicket ticket) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'QR Code Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large QR Code
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: QrImageView(
                          data: _formatQrCodeData(ticket),
                          version: QrVersions.auto,
                          size: 250,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // QR Data Information
                    const Text(
                      'QR Code Information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildQrDetailItem('Ticket Number', ticket.ticketNumber),
                    _buildQrDetailItem('Attendee Name', ticket.attendee.fullName),
                    _buildQrDetailItem('Pass Type', ticket.ticketType),
                    _buildQrDetailItem('Event', event.title),
                    _buildQrDetailItem('Date', event.date),
                    _buildQrDetailItem('Location', event.location),
                    _buildQrDetailItem('Booking ID', ticket.bookingId),
                    _buildQrDetailItem('Status', ticket.status.toUpperCase()),
                    
                    const SizedBox(height: 24),
                    
                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFF3B82F6),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Instructions',
                                style: TextStyle(
                                  color: Color(0xFF3B82F6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '• Show this QR code at the venue entrance\n'
                            '• Keep your phone screen bright for better scanning\n'
                            '• Have a backup screenshot saved in your gallery\n'
                            '• Arrive early to avoid entry queues\n'
                            '• Contact support if you face any issues',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}