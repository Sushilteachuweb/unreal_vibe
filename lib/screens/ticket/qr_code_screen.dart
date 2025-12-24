import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/my_pass_model.dart';
import '../../services/ticket_service.dart';
import '../../services/download_service.dart';
import '../../utils/error_handler.dart';

class QRCodeScreen extends StatefulWidget {
  final MyPass pass;

  const QRCodeScreen({Key? key, required this.pass}) : super(key: key);

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  String? _qrCode;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _qrCode = widget.pass.qrCode;
    
    // If QR code is not available, try to fetch it
    if (_qrCode == null || _qrCode!.isEmpty) {
      _fetchQRCode();
    }
  }

  Future<void> _fetchQRCode() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await TicketService.getPassQRCode(
        passId: widget.pass.id,
        eventId: widget.pass.eventId,
      );

      if (response['success'] == true && response['qrCode'] != null) {
        setState(() {
          _qrCode = response['qrCode'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'QR code not available';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(e);
        _isLoading = false;
      });
    }
  }

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
          'QR Code',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Event Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: widget.pass.eventImage.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(_getFullImageUrl(widget.pass.eventImage)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: widget.pass.eventImage.isEmpty 
                              ? const Color(0xFF6958CA).withOpacity(0.2)
                              : null,
                        ),
                        child: widget.pass.eventImage.isEmpty
                            ? const Icon(
                                Icons.event,
                                color: Color(0xFF6958CA),
                                size: 30,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.pass.eventName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.pass.passType} | x${widget.pass.quantity}',
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF6958CA),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.pass.formattedDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF6958CA),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${widget.pass.venue}, ${widget.pass.city}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // QR Code Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  if (_isLoading)
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF6958CA),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading QR Code...',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_qrCode != null && _qrCode!.isNotEmpty)
                    QrImageView(
                      data: _formatQrCodeData(widget.pass),
                      version: QrVersions.auto,
                      size: 250.0,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    )
                  else
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error ?? 'QR Code not available',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _fetchQRCode,
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  color: Color(0xFF6958CA),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Show this QR code at the venue entrance',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Download Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await DownloadService.downloadTicket(
                      bookingId: widget.pass.bookingId,
                      eventName: widget.pass.eventName,
                      context: context,
                    );
                  } catch (e) {
                    // Error handling is done in DownloadService
                    print('Download failed: $e');
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text(
                  'Download Ticket',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6958CA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatQrCodeData(MyPass pass) {
    try {
      // Try to parse the JSON QR code data if it exists
      Map<String, dynamic>? qrJson;
      if (pass.qrCode != null && pass.qrCode!.isNotEmpty) {
        try {
          qrJson = json.decode(pass.qrCode!);
        } catch (e) {
          print('Failed to parse QR JSON: $e');
        }
      }
      
      // Create human-readable QR code content that looks good when scanned
      final readableData = '''🎫 EVENT TICKET 🎫

📅 EVENT: ${pass.eventName}
📍 VENUE: ${pass.venue}, ${pass.city}
🗓️ DATE: ${pass.formattedDate}

🎟️ TICKET: ${qrJson?['ticketNumber'] ?? 'N/A'}
💳 TYPE: ${pass.passType}
✅ STATUS: ${pass.status.toUpperCase()}

👤 ATTENDEE: ${qrJson?['attendeeName'] ?? 'N/A'}

🔖 BOOKING ID: ${pass.bookingId}

🚪 Show this QR code at venue entrance for verification
🔋 Keep phone screen bright for better scanning''';

      print('🔍 Formatted QR Data: $readableData');
      return readableData;
      
    } catch (e) {
      print('❌ Failed to format QR data, using fallback: $e');
      
      // Fallback: Create simple format with available data
      final fallbackData = '''🎫 EVENT TICKET 🎫

📅 EVENT: ${pass.eventName}
📍 VENUE: ${pass.venue}, ${pass.city}
🗓️ DATE: ${pass.formattedDate}

💳 TYPE: ${pass.passType}
✅ STATUS: ${pass.status.toUpperCase()}

🔖 BOOKING ID: ${pass.bookingId}

🚪 Show this QR code at venue entrance for verification''';

      return fallbackData;
    }
  }

  String _getFullImageUrl(String imagePath) {
    // If the image path is already a full URL, return it as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // If it's a relative path, construct the full URL
    const String baseUrl = 'https://api.unrealvibe.com';
    
    // Remove leading slash if present to avoid double slashes
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    
    final fullUrl = '$baseUrl/$cleanPath';
    print('🖼️ QR Screen - Constructed image URL: $fullUrl');
    return fullUrl;
  }
}