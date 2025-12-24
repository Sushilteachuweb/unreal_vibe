import 'package:flutter/material.dart';
import '../../models/my_pass_model.dart';
import '../../services/ticket_service.dart';
import '../../services/downloads_folder_service.dart';
import '../../utils/error_handler.dart';
import 'qr_code_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({Key? key}) : super(key: key);

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  List<MyPass> _allPasses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMyPasses();
  }

  Future<void> _fetchMyPasses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await TicketService.fetchMyPasses();
      
      print('Screen: Response success: ${response.success}');
      print('Screen: Response message: ${response.message}');
      print('Screen: Passes count: ${response.passes.length}');
      
      if (response.success) {
        setState(() {
          _allPasses = response.passes;
          _isLoading = false;
        });
        print('Screen: Updated _allPasses with ${_allPasses.length} passes');
      } else {
        setState(() {
          _error = response.message;
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
        title: const Text(
          'Your Passes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMyPasses,
        color: const Color(0xFF6958CA),
        backgroundColor: Colors.white,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6958CA),
                ),
              )
            : _error != null
                ? ErrorHandler.buildEmptyState(
                    context: 'tickets',
                    customMessage: _error!,
                    onRetry: _fetchMyPasses,
                    navigatorContext: context,
                  )
                : _allPasses.isEmpty
                    ? ErrorHandler.buildEmptyState(
                        context: 'tickets',
                        onRetry: _fetchMyPasses,
                        navigatorContext: context,
                      )
                    : _buildPassList(_allPasses),
      ),
    );
  }





  Widget _buildPassList(List<MyPass> passes) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: passes.length,
      itemBuilder: (context, index) {
        final pass = passes[index];
        return _buildPassCard(pass);
      },
    );
  }

  Widget _buildPassCard(MyPass pass) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event header with image and title
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF4A9B8E), // Teal color like in Figma
                ),
                child: pass.eventImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          _getFullImageUrl(pass.eventImage),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: const Color(0xFF4A9B8E).withOpacity(0.3),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF4A9B8E),
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('❌ Failed to load image: ${_getFullImageUrl(pass.eventImage)}');
                            print('❌ Error: $error');
                            return _buildDefaultEventIcon();
                          },
                        ),
                      )
                    : _buildDefaultEventIcon(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pass.eventName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${pass.passType} | x${pass.quantity}',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Dotted line separator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            height: 1,
            child: CustomPaint(
              painter: DottedLinePainter(),
              size: const Size(double.infinity, 1),
            ),
          ),
          
          // Date and location info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6958CA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF6958CA),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                pass.formattedDate,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6958CA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF6958CA),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${pass.venue}, ${pass.city}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRCodeScreen(pass: pass),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_2, size: 20),
                  label: const Text(
                    'View QR Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63), // Pink color like in Figma
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () async {
                    try {
                      await DownloadsFolderService.downloadTicket(
                        bookingId: pass.bookingId,
                        eventName: pass.eventName,
                        context: context,
                      );
                    } catch (e) {
                      // Error handling is done in DownloadsFolderService
                      print('Download failed: $e');
                    }
                  },
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white,
                    size: 22,
                  ),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
    print('🖼️ Constructed image URL: $fullUrl');
    return fullUrl;
  }

  Widget _buildDefaultEventIcon() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF4A9B8E),
      ),
      child: const Center(
        child: Icon(
          Icons.event,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF374151)
      ..strokeWidth = 1;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}