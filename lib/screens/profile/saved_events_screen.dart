import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/error_handler.dart';
import '../../widgets/skeleton_loading.dart';
import '../home/event_card.dart';
import '../home/event_details_screen.dart';

class SavedEventsScreen extends StatefulWidget {
  const SavedEventsScreen({Key? key}) : super(key: key);

  @override
  State<SavedEventsScreen> createState() => _SavedEventsScreenState();
}

class _SavedEventsScreenState extends State<SavedEventsScreen> {
  List<Event> _savedEvents = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSavedEvents();
  }

  Future<void> _fetchSavedEvents() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final events = await EventService.fetchSavedEvents();
      setState(() {
        _savedEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final events = await EventService.fetchSavedEvents(forceRefresh: true);
      setState(() {
        _savedEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved Events',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF6366F1),
        backgroundColor: Colors.white,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxContentWidth(context),
          ),
          width: double.infinity,
          child: _buildBody(padding),
        ),
      ),
    );
  }

  Widget _buildBody(double padding) {
    if (_isLoading) {
      return _buildLoadingState(padding);
    }

    if (_hasError) {
      return ErrorHandler.buildEmptyState(
        context: 'saved',
        customMessage: _errorMessage,
        onRetry: _fetchSavedEvents,
      );
    }

    if (_savedEvents.isEmpty) {
      return _buildEmptyState(padding);
    }

    return _buildEventsList(padding);
  }

  Widget _buildLoadingState(double padding) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: const EventCardSkeleton(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(double padding) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load saved events',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage.contains('Authentication required')
                    ? 'Please log in to view your saved events'
                    : 'Please check your internet connection and try again',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchSavedEvents,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(double padding) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const Icon(
                Icons.bookmark_border,
                color: Colors.grey,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Saved Events',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You haven\'t saved any events yet.\nStart exploring and save events you\'re interested in!',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to home or explore tab
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Explore Events'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList(double padding) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '${_savedEvents.length} Saved Event${_savedEvents.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _savedEvents.length,
              itemBuilder: (context, index) {
                final event = _savedEvents[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: EventCard(
                    title: event.title,
                    subtitle: event.aboutParty,
                    date: event.date,
                    location: event.location,
                    coverCharge: event.passes?.isNotEmpty == true 
                        ? '₹${event.passes!.first.price.toInt()}' 
                        : 'Free',
                    imageUrl: event.imageUrl,
                    tags: event.tags,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsScreen(event: event),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}