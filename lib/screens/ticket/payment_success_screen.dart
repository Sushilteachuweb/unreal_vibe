import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../models/purchased_ticket_model.dart';
import 'tickets_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final Event event;
  final BookingResponse bookingResponse;

  const PaymentSuccessScreen({
    Key? key,
    required this.event,
    required this.bookingResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Debug booking response
    print('🎫 Payment Success - Booking Response:');
    print('  - Success: ${bookingResponse.success}');
    print('  - Message: ${bookingResponse.message}');
    print('  - Booking ID: ${bookingResponse.bookingId}');
    print('  - Tickets Count: ${bookingResponse.tickets.length}');
    
    for (int i = 0; i < bookingResponse.tickets.length; i++) {
      final ticket = bookingResponse.tickets[i];
      print('  - Ticket $i: ${ticket.ticketNumber}');
      print('    - QR Code: ${ticket.qrCode.substring(0, ticket.qrCode.length > 50 ? 50 : ticket.qrCode.length)}...');
      print('    - Attendee: ${ticket.attendee.fullName}');
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    // Success Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF10B981),
                        size: 80,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Success Title
                    const Text(
                      'Payment Successful!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Success Message
                    Text(
                      bookingResponse.message,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Booking Details Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Event',
                            event.title,
                            Icons.event,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            'Booking ID',
                            bookingResponse.bookingId.substring(bookingResponse.bookingId.length - 8),
                            Icons.confirmation_number,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            'Tickets',
                            '${bookingResponse.tickets.length} ticket${bookingResponse.tickets.length > 1 ? 's' : ''}',
                            Icons.local_activity,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            'Total Amount',
                            '₹${bookingResponse.tickets.fold(0.0, (sum, ticket) => sum + ticket.price).toInt()}',
                            Icons.payment,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Info Message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your tickets have been sent to your email. You can also view them anytime in the app.',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 14,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  ),
                ),
              ),
              
              // Action Buttons
              Column(
                children: [
                  // View Tickets Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TicketsScreen(
                              event: event,
                              bookingResponse: bookingResponse,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6958CA),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'View My Tickets',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Back to Home Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/main',
                          (route) => false,
                          arguments: 0, // Home tab index
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF2A2A2A)),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF6958CA).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6958CA),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}