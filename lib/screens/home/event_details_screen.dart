import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/event_model.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/event_provider.dart';
import '../ticket/ticket_selection_screen.dart';
import '../../services/event_service.dart';
import '../../services/review_service.dart';
import '../../services/maps_service.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Event get event => widget.event;
  int _selectedAboutTab = 0; // 0 for About The Party, 1 for Party Terms
  bool _isSaved = false;
  bool _isTogglingSave = false;

  @override
  void initState() {
    super.initState();
    _checkIfEventIsSaved();
  }

  Future<void> _checkIfEventIsSaved() async {
    try {
      final isSaved = await EventService.isEventSaved(event.id);
      if (mounted) {
        setState(() {
          _isSaved = isSaved;
        });
      }
    } catch (e) {
      // If there's an error checking saved status, keep default false state
      print('Error checking saved status: $e');
    }
  }

  Future<void> _toggleSaveEvent() async {
    if (_isTogglingSave) return;

    setState(() {
      _isTogglingSave = true;
    });

    try {
      final result = await EventService.toggleSaveEvent(event.id);
      setState(() {
        _isSaved = result;
        _isTogglingSave = false;
      });

      // Show feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSaved ? 'Event saved!' : 'Event unsaved'),
            backgroundColor: _isSaved ? Colors.green : Colors.grey,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isTogglingSave = false;
      });
      
      if (mounted) {
        String errorMessage = 'Failed to save event. Please try again.';
        if (e.toString().contains('Authentication required')) {
          errorMessage = 'Please log in to save events.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _shareEvent() async {
    try {
      print('=== Starting share event process ===');
      print('Event ID: ${event.id}');
      print('Event Title: ${event.title}');
      
      // Create a formatted share message with event details
      String shareText = _buildShareMessage();
      
      print('Share text length: ${shareText.length}');
      
      // Validate share text is not empty
      if (shareText.trim().isEmpty) {
        throw Exception('Share text is empty');
      }
      
      // Try simple share first
      print('Attempting to share via Share.share...');
      await Share.share(shareText);
      
      print('Share completed successfully');
      
      // Also call the API to track the share (optional)
      _trackShareEvent();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event shared successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      print('=== Share Error Details ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: ${StackTrace.current}');
      
      // Try fallback simple share
      try {
        print('Attempting fallback simple share...');
        await Share.share('Check out this event: ${event.title ?? "Awesome Event"}\n\nDownload Unreal Vibe app!');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event shared successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      } catch (fallbackError) {
        print('Fallback share also failed: $fallbackError');
      }
      
      if (mounted) {
        String errorMessage = 'Failed to share event. Please try again.';
        
        // Provide more specific error messages
        if (e.toString().contains('No Activity found')) {
          errorMessage = 'No sharing apps available on this device.';
        } else if (e.toString().contains('Permission')) {
          errorMessage = 'Permission denied. Please check app permissions.';
        } else if (e.toString().contains('PlatformException')) {
          errorMessage = 'Platform error occurred. Try restarting the app.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _shareEvent,
            ),
          ),
        );
      }
    }
  }

  String _buildShareMessage() {
    try {
      // Build a comprehensive share message with event details
      StringBuffer message = StringBuffer();
      
      // Safely add title
      final title = event.title ?? 'Untitled Event';
      message.writeln('🎉 $title');
      
      // Safely add description
      if (event.aboutParty?.isNotEmpty == true) {
        message.writeln('${event.aboutParty}');
      }
      
      message.writeln();
      
      // Safely add date
      final date = event.date ?? 'Date TBD';
      message.writeln('📅 Date: $date');
      
      // Safely add time
      if (event.time?.isNotEmpty == true) {
        message.writeln('🕐 Time: ${event.time}');
      }
      
      // Safely add location
      final location = event.location ?? 'Location TBD';
      message.writeln('📍 Location: $location');
      
      // Safely add full address
      if (event.fullAddress.isNotEmpty) {
        message.writeln('   ${event.fullAddress}');
      }
      
      // Add ticket pricing if available
      if (event.passes != null && event.passes!.isNotEmpty) {
        message.writeln();
        message.writeln('🎫 Tickets:');
        for (var pass in event.passes!) {
          try {
            final passType = pass.type ?? 'General';
            final passPrice = pass.price ?? 0.0;
            message.writeln('   $passType: ₹${passPrice.toInt()}');
          } catch (e) {
            print('Error formatting pass: $e');
          }
        }
      }
      
      // Add host information
      if (event.hostName?.isNotEmpty == true) {
        message.writeln();
        message.writeln('👤 Hosted by: ${event.hostName}');
      }
      
      // Add age restriction if available
      if (event.ageRestriction?.isNotEmpty == true) {
        message.writeln('🔞 Age: ${event.ageRestriction}');
      }
      
      message.writeln();
      message.writeln('Download Unreal Vibe app to book your tickets!');
      message.writeln('🔗 https://unrealvibe.com');
      
      final result = message.toString();
      print('Built share message (${result.length} chars): $result');
      return result;
      
    } catch (e) {
      print('Error building share message: $e');
      // Return a fallback message
      return '''
🎉 ${event.title ?? 'Event'}
📅 ${event.date ?? 'Date TBD'}
📍 ${event.location ?? 'Location TBD'}

Download Unreal Vibe app to book your tickets!
🔗 https://unrealvibe.com
      '''.trim();
    }
  }

  // Optional: Track share event in analytics (call API in background)
  void _trackShareEvent() async {
    try {
      print('Tracking share event for: ${event.id}');
      final success = await EventService.shareEvent(event.id);
      print('Share tracking result: $success');
    } catch (e) {
      // Silently fail - this is just for analytics
      print('Failed to track share event: $e');
    }
  }

  Future<void> _getDirections() async {
    try {
      print('=== Getting directions for event ===');
      print('Event ID: ${event.id}');
      print('Event Title: ${event.title}');
      print('Event Location: ${event.location}');
      print('Event Full Address: ${event.fullAddress}');
      
      // Check if event has location data
      if (!MapsService.hasLocationData(event)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location information not available for this event'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Log coordinate information
      if (event.eventLocation?.coordinates != null) {
        print('Event Coordinates: ${event.eventLocation!.coordinates}');
        print('Latitude: ${event.eventLocation!.coordinates[1]}');
        print('Longitude: ${event.eventLocation!.coordinates[0]}');
      }

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Opening maps...'),
              ],
            ),
            backgroundColor: Color(0xFF6958CA),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Open directions
      final success = await MapsService.openDirections(event);
      
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to open maps. Please check if you have a maps app installed.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _getDirections,
            ),
          ),
        );
      }
    } catch (e) {
      // Log detailed error for developers
      debugPrint('🚨 [EventDetails] Directions error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to open directions. Please try again'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _getDirections,
            ),
          ),
        );
      }
    }
  }

  void _showReviewDialog(BuildContext context) {
    print('Review button tapped - showing dialog');
    int selectedRating = 0;
    final TextEditingController reviewController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFF6958CA),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Rate & Review Event',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Event title
                    Text(
                      event.title,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Rating stars
                    Text(
                      'Rating',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              index < selectedRating ? Icons.star : Icons.star_border,
                              color: index < selectedRating 
                                  ? const Color(0xFFFFD700) 
                                  : Colors.grey[600],
                              size: 32,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    
                    // Review text field
                    Text(
                      'Review',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reviewController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Share your experience about this event...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6958CA), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting || selectedRating == 0 
                            ? null 
                            : () async {
                                setState(() {
                                  isSubmitting = true;
                                });
                                
                                try {
                                  final success = await ReviewService.submitReview(
                                    eventId: event.id,
                                    rating: selectedRating,
                                    review: reviewController.text.trim(),
                                  );
                                  
                                  if (success) {
                                    Navigator.pop(dialogContext);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Review submitted successfully!'),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  } else {
                                    throw Exception('Failed to submit review');
                                  }
                                } catch (e) {
                                  String errorMessage = 'Failed to submit review. Please try again.';
                                  if (e.toString().contains('Authentication required')) {
                                    errorMessage = 'Please log in to submit a review.';
                                  }
                                  
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(errorMessage),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } finally {
                                  setState(() {
                                    isSubmitting = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedRating > 0 
                              ? const Color(0xFF6958CA) 
                              : Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Submit Review',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Add error boundary
    try {
      return Scaffold(
        backgroundColor: Colors.black,
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.getMaxContentWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventHeader(context),
                      _buildHostedBy(context),
                      _buildEventInfo(context),
                      _buildActionButtons(context),
                      _buildEventDetailsInfo(context),
                      // _buildEventGallery(context),
                      _buildTicketPrices(context),
                      _buildAboutSection(context),
                      _buildExpandableSections(context),
                      _buildAllEvents(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context),
      );
    } catch (e) {
      // Fallback UI in case of errors
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Event Details'),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Error loading event details',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Error: $e',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildEventImage() {
    try {
      if (widget.event.imageUrl.startsWith('http')) {
        return Image.network(
          widget.event.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[800],
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF6958CA)),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading network image: $error');
            return Container(
              color: Colors.grey[800],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, color: Colors.grey, size: 48),
                    SizedBox(height: 8),
                    Text('Image not available', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        return Image.asset(
          widget.event.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading asset image: $error');
            return Container(
              color: Colors.grey[800],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, color: Colors.grey, size: 48),
                    SizedBox(height: 8),
                    Text('Image not available', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      print('Error in _buildEventImage: $e');
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 8),
              Text('Error loading image', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isSaved 
                  ? const Color(0xFFFFD700).withOpacity(0.2)
                  : Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
              border: _isSaved 
                  ? Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 1)
                  : null,
            ),
            child: _isTogglingSave
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _isSaved ? const Color(0xFFFFD700) : Colors.white,
                    size: 24,
                  ),
          ),
          onPressed: _isTogglingSave ? null : _toggleSaveEvent,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildEventImage(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeader(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.event.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
              fontWeight: FontWeight.bold,
            ),
          ),
          // Add subtitle from "about" field if available
          if (widget.event.aboutParty != null && widget.event.aboutParty!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.event.aboutParty!,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }



  Widget _buildEventInfo(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              context: context,
              icon: Icons.calendar_today,
              title: widget.event.date,
              subtitle: widget.event.time != null ? '${widget.event.time}' : 'Time TBA',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildLocationInfoCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6958CA), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfoCard(BuildContext context) {
    final locationString = MapsService.getBestLocationString(event);
    final coordinatesString = MapsService.getCoordinatesString(event);
    final hasLocationData = MapsService.hasLocationData(event);
    
    return GestureDetector(
      onTap: hasLocationData ? () async {
        // Quick tap to open location
        final success = await MapsService.openLocation(event);
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open location in maps'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: hasLocationData 
              ? Border.all(color: const Color(0xFF6958CA).withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on, 
              color: hasLocationData ? const Color(0xFF6958CA) : Colors.grey[600], 
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locationString,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (coordinatesString != null) ...[
                    Text(
                      coordinatesString,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 9),
                      ),
                    ),
                  ] else ...[
                    Text(
                      hasLocationData ? 'Tap to view on map' : 'Location not available',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasLocationData) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.open_in_new,
                color: Colors.grey[500],
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _getDirections,
              icon: const Icon(Icons.directions_car, size: 18),
              label: Text(
                'Get Direction',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _shareEvent,
              icon: const Icon(Icons.share, size: 18),
              label: Text(
                'Share Event',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6958CA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsInfo(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    
    // Collect available info items
    List<Widget> infoItems = [];
    
    // Age restriction
    if (widget.event.ageRestriction != null && widget.event.ageRestriction!.isNotEmpty) {
      infoItems.add(_buildInfoItem(
        icon: Icons.people_outline,
        iconColor: const Color(0xFFE91E63),
        iconBgColor: const Color(0xFFE91E63).withOpacity(0.15),
        text: widget.event.ageRestriction!,
      ));
    }
    
    // What's included in ticket
    if ((widget.event.whatsIncludedInTicket != null && widget.event.whatsIncludedInTicket!.isNotEmpty) ||
        (widget.event.whatsIncluded != null && widget.event.whatsIncluded!.isNotEmpty)) {
      infoItems.add(_buildInfoItem(
        icon: Icons.star_outline,
        iconColor: const Color(0xFFFFA726),
        iconBgColor: const Color(0xFFFFA726).withOpacity(0.15),
        text: widget.event.whatsIncludedInTicket ?? widget.event.whatsIncluded!,
      ));
    }
    
    // Expected guest count
    if (widget.event.expectedGuestCount != null && widget.event.expectedGuestCount!.isNotEmpty) {
      infoItems.add(_buildInfoItem(
        icon: Icons.groups_outlined,
        iconColor: const Color(0xFF7E57C2),
        iconBgColor: const Color(0xFF7E57C2).withOpacity(0.15),
        text: 'You can expect ${widget.event.expectedGuestCount} people in the party',
      ));
    }
    
    // Male to female ratio
    if (widget.event.maleToFemaleRatio != null && widget.event.maleToFemaleRatio!.isNotEmpty) {
      infoItems.add(_buildInfoItem(
        icon: Icons.favorite_outline,
        iconColor: const Color(0xFF26A69A),
        iconBgColor: const Color(0xFF26A69A).withOpacity(0.15),
        text: 'This party maintains at least a ${widget.event.maleToFemaleRatio} male to female ratio',
      ));
    }
    
    // Return empty container if no info available
    if (infoItems.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Add spacing between items
    List<Widget> spacedItems = [];
    for (int i = 0; i < infoItems.length; i++) {
      spacedItems.add(infoItems[i]);
      if (i < infoItems.length - 1) {
        spacedItems.add(const SizedBox(height: 16));
      }
    }
    
    return Container(
      margin: EdgeInsets.fromLTRB(padding, 20, padding, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      child: Column(children: spacedItems),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 15),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }




  Widget _buildTicketPrices(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    
    // Only show ticket prices if passes data is available from API
    if (widget.event.passes == null || widget.event.passes!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    List<Widget> ticketCards = [];
    
    // Use passes data from API
    for (var pass in widget.event.passes!) {
      Color accentColor;
      IconData icon;
      
      switch (pass.type.toLowerCase()) {
        case 'male':
          accentColor = const Color(0xFF4FC3F7);
          icon = Icons.person;
          break;
        case 'female':
          accentColor = const Color(0xFFE91E63);
          icon = Icons.person_outline;
          break;
        case 'couple':
          accentColor = const Color(0xFF7E57C2);
          icon = Icons.people;
          break;
        default:
          accentColor = const Color(0xFF6958CA);
          icon = Icons.confirmation_number;
      }
      
      ticketCards.add(
        _buildTicketCard(
          context,
          pass.type,
          '₹ ${pass.price.toInt()}',
          icon,
          accentColor,
        )
      );
      
      if (pass != widget.event.passes!.last) {
        ticketCards.add(const SizedBox(height: 12));
      }
    }
    
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ticket Prices',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Column(children: ticketCards),
        ],
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, String ticketType, String price, IconData icon, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticketType,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Entry Ticket',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: accentColor,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About The Party',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Tab buttons
          Row(
            children: [
              _buildTabButton(
                context,
                'About The Party',
                0,
                _selectedAboutTab == 0,
              ),
              const SizedBox(width: 24),
              _buildTabButton(
                context,
                'Party Terms',
                1,
                _selectedAboutTab == 1,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tab content
          _selectedAboutTab == 0 ? _buildAboutContent(context) : _buildPartyTermsContent(context),
        ],
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String title, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAboutTab = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF6958CA) : Colors.grey[400],
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: title.length * 8.0,
            color: isSelected ? const Color(0xFF6958CA) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutContent(BuildContext context) {
    List<Widget> contentWidgets = [];
    
    // Party Flow section
    if (widget.event.partyFlow != null && widget.event.partyFlow!.isNotEmpty) {
      contentWidgets.addAll([
        Text(
          'Party Flow',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.event.partyFlow!,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            height: 1.5,
          ),
        ),
      ]);
    }
    
    // Things to Know section
    if (widget.event.thingsToKnow != null && widget.event.thingsToKnow!.isNotEmpty) {
      if (contentWidgets.isNotEmpty) {
        contentWidgets.add(const SizedBox(height: 16));
      }
      contentWidgets.addAll([
        Text(
          'Things to Know',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.event.thingsToKnow!,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            height: 1.5,
          ),
        ),
      ]);
    }
    
    // If no content available, show message
    if (contentWidgets.isEmpty) {
      contentWidgets.add(
        Text(
          'No additional party information available.',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            height: 1.5,
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentWidgets,
    );
  }

  Widget _buildPartyTermsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show only party terms from API if available
        if (widget.event.partyTerms != null && widget.event.partyTerms!.isNotEmpty) ...[
          Text(
            widget.event.partyTerms!,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              height: 1.5,
            ),
          ),
        ] else ...[
          // Show fallback message if no party terms available
          Text(
            'No specific party terms provided for this event.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }



  Widget _buildExpandableSections(BuildContext context) {
    return Column(
      children: [
        _buildExpandableSection(
          context,
          'Party Etiquette',
          widget.event.partyEtiquette,
        ),
        _buildExpandableSection(
          context,
          'What\'s Included',
          widget.event.whatsIncluded,
        ),
        _buildExpandableSection(
          context,
          'House Rules',
          widget.event.houseRules,
        ),
        _buildExpandableSection(
          context,
          'How it works',
          widget.event.howItWorks,
        ),
        _buildExpandableSection(
          context,
          'Cancellation Policy',
          widget.event.cancellationPolicy,
        ),
      ],
    );
  }

  Widget _buildExpandableSection(BuildContext context, String title, String? content) {
    // Don't show section if content is null or empty
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                content,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllEvents(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        // Exclude current event from the list
        final otherEvents = eventProvider.events.where((event) => event.id != widget.event.id).take(5).toList();
        
        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Events',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      print('Review button pressed!');
                      _showReviewDialog(context);
                    },
                    icon: const Icon(
                      Icons.star_border,
                      color: Color(0xFF6958CA),
                      size: 20,
                    ),
                    label: Text(
                      'Review',
                      style: TextStyle(
                        color: const Color(0xFF6958CA),
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Add some spacing instead of negative transform
              Transform.translate(
                offset: const Offset(0, -16), // Reduced negative offset
                child: Column(
                  children: [
                    if (otherEvents.isEmpty)
                      Container(
                        height: 200,
                        child: Center(
                          child: Text(
                            'No other events available',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: otherEvents.length,
                        itemBuilder: (context, index) {
                          final event = otherEvents[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildEventCard(event, context),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventCard(Event event, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event),
          ),
        );
      },
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: event.imageUrl.startsWith('http')
                  ? Image.network(
                      event.imageUrl,
                      width: 90,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 90,
                          height: 100,
                          color: Colors.grey[800],
                          child: const Icon(Icons.image, color: Colors.grey, size: 30),
                        );
                      },
                    )
                  : Image.asset(
                      event.imageUrl,
                      width: 90,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 90,
                          height: 100,
                          color: Colors.grey[800],
                          child: const Icon(Icons.image, color: Colors.grey, size: 30),
                        );
                      },
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      event.date.isNotEmpty ? event.date.toUpperCase() : 'DATE TBA',
                      style: TextStyle(
                        color: const Color(0xFF8B7FD9),
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 11),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 15),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.location,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostedBy(BuildContext context) {
    // Only show hosted by section if host information is available
    final hostName = widget.event.hostName ?? widget.event.hostInfo?.name;
    final partiesHosted = widget.event.partiesHosted ?? widget.event.hostInfo?.eventsHosted;
    
    if (hostName == null || hostName.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.person, color: Colors.white, size: 25),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hosted By',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hostName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (partiesHosted != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$partiesHosted Parties',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Hosted',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: 56.0,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF4081), Color(0xFFE91E63)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28.0),
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TicketSelectionScreen(event: widget.event),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.0),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
