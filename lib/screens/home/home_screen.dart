import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unreal_vibe/screens/home/event_card.dart';
import 'package:unreal_vibe/screens/home/search_bar.dart';
import '../../models/event_model.dart';
import '../../models/filter_model.dart';
import 'event_details_screen.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/user_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/api_debug.dart';
import '../../services/event_service.dart';
import '../../services/search_service.dart';
import '../../widgets/skeleton_loading.dart';
import '../../widgets/hero_video_widget.dart';
import '../../widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<Event> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';
  EventFilter _currentFilter = EventFilter.empty();

  @override
  void initState() {
    super.initState();
    // Only fetch events if needed (no cache or cache expired)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = context.read<EventProvider>();
      eventProvider.fetchEventsIfNeeded();
      eventProvider.fetchTrendingEventsIfNeeded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    try {
      // Get user's city from UserProvider
      final userProvider = context.read<UserProvider>();
      final userCity = userProvider.user?.city ?? 'Delhi'; // Default to Delhi if no city set
      
      print('🔍 [HomeScreen] Starting search - Query: "$query", City: "$userCity"');
      
      final results = await SearchService.searchInCity(query, userCity);
      
      print('🔍 [HomeScreen] Search completed - Found ${results.length} results');
      if (results.isNotEmpty) {
        print('   First result: ${results.first.title}');
      }
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
      
      print('🔍 [HomeScreen] UI updated - _searchResults.length: ${_searchResults.length}');
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      if (mounted) {
        // Log detailed error for developers
        debugPrint('🚨 [HomeScreen] Search error: $e');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Search failed. Please try again'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
      _searchQuery = '';
    });
  }

  Future<void> _onRefresh() async {
    final eventProvider = context.read<EventProvider>();
    await Future.wait([
      eventProvider.fetchEvents(forceRefresh: true),
      eventProvider.fetchTrendingEvents(forceRefresh: true),
    ]);
  }

  Widget _buildSkeletonLoading(BuildContext context, double padding) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.getMaxContentWidth(context),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Hero section skeleton
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoading(width: 250, height: 32),
                    const SizedBox(height: 8),
                    const SkeletonLoading(width: 200, height: 32),
                    const SizedBox(height: 8),
                    const SkeletonLoading(width: 300, height: 14),
                  ],
                ),
                const SizedBox(height: 20),
                // Search bar skeleton
                const SkeletonLoading(width: double.infinity, height: 48),
                const SizedBox(height: 28),
                // Trending events skeleton
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SkeletonLoading(width: 150, height: 18),
                        const SkeletonLoading(width: 60, height: 14),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          final cardWidth = screenWidth - (padding * 2) - 40;
                          return Container(
                            width: cardWidth,
                            margin: const EdgeInsets.only(right: 12),
                            child: const EventCardSkeleton(isHorizontal: true),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // All events skeleton
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SkeletonLoading(width: 100, height: 18),
                        Row(
                          children: [
                            const SkeletonLoading(width: 20, height: 20),
                            const SizedBox(width: 8),
                            const SkeletonLoading(width: 50, height: 16),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Filter tags skeleton
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          const SkeletonLoading(width: 60, height: 36, borderRadius: BorderRadius.all(Radius.circular(18))),
                          const SizedBox(width: 8),
                          const SkeletonLoading(width: 100, height: 36, borderRadius: BorderRadius.all(Radius.circular(18))),
                          const SizedBox(width: 8),
                          const SkeletonLoading(width: 80, height: 36, borderRadius: BorderRadius.all(Radius.circular(18))),
                          const SizedBox(width: 8),
                          const SkeletonLoading(width: 90, height: 36, borderRadius: BorderRadius.all(Radius.circular(18))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Event cards skeleton
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: const EventCardSkeleton(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final trendingEvents = eventProvider.trendingEvents;
        final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);

        return _buildHomeContent(context, eventProvider, trendingEvents, padding);
      },
    );
  }

  Widget _buildHomeContent(BuildContext context, EventProvider eventProvider, List<Event> trendingEvents, double padding) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: eventProvider.isLoading && !eventProvider.hasData
          ? _buildSkeletonLoading(context, padding)
          : eventProvider.error != null && !eventProvider.hasData
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load events',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          eventProvider.error ?? 'Unknown error',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => eventProvider.fetchEvents(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6958CA),
                              ),
                              child: const Text('Retry'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () async {
                                await ApiDebug.testApiEndpoints();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: const Text('Debug API'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshLoadingIndicator(
                  isLoading: eventProvider.isLoading && eventProvider.hasData,
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: ResponsiveHelper.getMaxContentWidth(context),
                      ),
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: const Color(0xFF6958CA),
                        backgroundColor: Colors.white,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hero section without padding to extend to edges
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  _buildHeroSection(context),
                                  const SizedBox(height: 20),
                                  // Search bar with padding
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: padding),
                                    child: Consumer<UserProvider>(
                                      builder: (context, userProvider, child) {
                                        final userCity = userProvider.user?.city ?? 'Delhi';
                                        return CustomSearchBar(
                                          controller: _searchController,
                                          userCity: userCity,
                                          showSuggestions: true,
                                          onChanged: (value) {
                                            if (value.isEmpty) {
                                              _clearSearch();
                                            }
                                          },
                                          onSearch: _performSearch,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              // Show search results or normal content
                              if (_searchQuery.isNotEmpty) ...[
                                _buildSearchResults(padding),
                              ] else ...[
                                _buildTrendingEvents(trendingEvents, context),
                                const SizedBox(height: 32),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: padding),
                                  child: _buildAllEvents(context, eventProvider),
                                ),
                              ],
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Unrealvibe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final userCity = userProvider.user?.city ?? 'Noida';
              return Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    userCity,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final videoHeight = isDesktop ? 300.0 : 200.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Video Widget with text overlay
        HeroVideoWidget(
          videoPath: 'assets/video/hero_video.mp4',
          height: videoHeight,
          overlay: _buildVideoOverlay(context),
        ),
      ],
    );
  }

  Widget _buildVideoOverlay(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Much larger font sizes to fill the video screen
    final mainFontSize = isDesktop ? 64.0 : isTablet ? 48.0 : screenWidth > 375 ? 36.0 : 32.0;
    final subtitleFontSize = isDesktop ? 18.0 : isTablet ? 16.0 : 14.0;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        // Multi-layered gradient overlay for better text readability and edge blending
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.1),
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Edge blending shadows - Top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Edge blending shadows - Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Edge blending shadows - Left
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: 30,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Edge blending shadows - Right
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: 30,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Centered text content filling the video screen
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 20.0 : 16.0,
                vertical: isDesktop ? 20.0 : 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Main text with large styling to fill screen
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: mainFontSize,
                            fontWeight: FontWeight.w900,
                            height: 0.9,
                            letterSpacing: -1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.9),
                                offset: const Offset(0, 3),
                                blurRadius: 12,
                              ),
                              Shadow(
                                color: Colors.black.withOpacity(0.6),
                                offset: const Offset(0, 6),
                                blurRadius: 24,
                              ),
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 12),
                                blurRadius: 48,
                              ),
                            ],
                          ),
                          children: [
                            const TextSpan(
                              text: 'FIND YOUR ',
                              style: TextStyle(color: Colors.white),
                            ),
                            const TextSpan(
                              text: 'VIBE.\n',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                              ),
                            ),
                            const TextSpan(
                              text: 'LIVE THE ',
                              style: TextStyle(color: Colors.white),
                            ),
                            const TextSpan(
                              text: 'MUSIC.',
                              style: TextStyle(
                                color: Color(0xFF6958CA),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 24 : 16),
                  // Subtitle text with larger styling
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'DISCOVER UNFORGETTABLE EVENTS\nAND CREATE YOUR OWN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.9),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 4),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingEvents(List<Event> events, BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final screenWidth = MediaQuery.of(context).size.width;
    // Make first card take most of the screen width with just a peek of the second card
    final cardWidth = isDesktop ? 300.0 : screenWidth - (padding * 2) - 40; // 40px for peek of next card
    final cardHeight = isDesktop ? 340.0 : 280.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending Events',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: const Color(0xFF6958CA),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: padding, right: 4),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Container(
                width: cardWidth,
                margin: EdgeInsets.only(
                  right: index < events.length - 1 ? 12 : 0,
                ),
                child: EventCard(
                  title: event.title,
                  subtitle: event.subtitle,
                  date: event.date,
                  location: event.location,
                  coverCharge: event.coverCharge,
                  imageUrl: event.imageUrl,
                  tags: event.tags,
                  isHorizontal: true,
                  status: event.status,
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
        ),
      ],
    );
  }

  Widget _buildAllEvents(BuildContext context, EventProvider eventProvider) {
    // Use the new comprehensive filtering system
    final filteredEvents = _currentFilter.hasActiveFilters 
        ? eventProvider.getFilteredEventsWithFilter(_currentFilter)
        : eventProvider.getFilteredEvents(selectedFilter);
    
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with "All Events" and "Filters"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Events',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: _showFilterBottomSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _currentFilter.hasActiveFilters 
                      ? const Color(0xFF6958CA).withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: _currentFilter.hasActiveFilters 
                      ? Border.all(color: const Color(0xFF6958CA), width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_sharp,
                      color: _currentFilter.hasActiveFilters 
                          ? const Color(0xFF6958CA)
                          : Colors.grey[400],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filters',
                      style: TextStyle(
                        color: _currentFilter.hasActiveFilters 
                            ? const Color(0xFF6958CA)
                            : Colors.grey[400],
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_currentFilter.hasActiveFilters) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6958CA),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Active filters display
        if (_currentFilter.hasActiveFilters) ...[
          _buildActiveFilters(),
          const SizedBox(height: 16),
        ],
        // Filter tags below the header - dynamically generated from API data
        SizedBox(
          height: 36,
          child: Consumer<EventProvider>(
            builder: (context, eventProvider, child) {
              final availableCategories = eventProvider.getAvailableCategories();
              
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: availableCategories.length,
                itemBuilder: (context, index) {
                  final tag = availableCategories[index];
                  final isSelected = selectedFilter == tag;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = tag;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF6958CA) : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[500],
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        isDesktop || isTablet
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  return EventCard(
                    title: event.title,
                    subtitle: event.subtitle,
                    date: event.date,
                    location: event.location,
                    coverCharge: event.coverCharge,
                    imageUrl: event.imageUrl,
                    tags: event.tags,
                    isHorizontal: false,
                    status: event.status,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsScreen(event: event),
                        ),
                      );
                    },
                  );
                },
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: EventCard(
                      title: event.title,
                      subtitle: event.subtitle,
                      date: event.date,
                      location: event.location,
                      coverCharge: event.coverCharge,
                      imageUrl: event.imageUrl,
                      tags: event.tags,
                      isHorizontal: false,
                      status: event.status,
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
      ],
    );
  }

  Widget _buildSearchResults(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Search Results',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_searchQuery.isNotEmpty)
                      Flexible(
                        child: Text(
                          'for "$_searchQuery"',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _clearSearch,
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: Color(0xFF6958CA),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isSearching)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6958CA),
              ),
            )
          else if (_searchResults.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No events found',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try searching with different keywords',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    // Debug info
                    if (kDebugMode) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'DEBUG INFO',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Query: "$_searchQuery"',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'Results: ${_searchResults.length}',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'Searching: $_isSearching',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final event = _searchResults[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: EventCard(
                    title: event.title,
                    subtitle: event.subtitle,
                    date: event.date,
                    location: event.location,
                    coverCharge: event.coverCharge,
                    imageUrl: event.imageUrl,
                    tags: event.tags,
                    isHorizontal: false,
                    status: event.status,
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
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    List<Widget> filterChips = [];

    // Category filter
    if (_currentFilter.category != null && _currentFilter.category != 'All') {
      filterChips.add(_buildFilterChip(
        label: _currentFilter.category!,
        onRemove: () {
          setState(() {
            _currentFilter = _currentFilter.copyWith(category: 'All');
            selectedFilter = 'All';
          });
          _applyCurrentFilter();
        },
      ));
    }

    // Location filter
    if (_currentFilter.location != null && _currentFilter.location!.isNotEmpty) {
      filterChips.add(_buildFilterChip(
        label: 'Near ${_currentFilter.location}',
        onRemove: () {
          setState(() {
            _currentFilter = _currentFilter.copyWith(location: '');
          });
          _applyCurrentFilter();
        },
      ));
    }

    // Date filter
    if (_currentFilter.startDate != null || _currentFilter.endDate != null) {
      String dateLabel = '';
      if (_currentFilter.startDate != null && _currentFilter.endDate != null) {
        dateLabel = '${_formatDate(_currentFilter.startDate!)} - ${_formatDate(_currentFilter.endDate!)}';
      } else if (_currentFilter.startDate != null) {
        dateLabel = 'From ${_formatDate(_currentFilter.startDate!)}';
      } else if (_currentFilter.endDate != null) {
        dateLabel = 'Until ${_formatDate(_currentFilter.endDate!)}';
      }
      
      filterChips.add(_buildFilterChip(
        label: dateLabel,
        onRemove: () {
          setState(() {
            _currentFilter = _currentFilter.copyWith(
              startDate: null,
              endDate: null,
            );
          });
          _applyCurrentFilter();
        },
      ));
    }

    // Distance filter
    if (_currentFilter.maxDistance != null) {
      filterChips.add(_buildFilterChip(
        label: 'Within ${_currentFilter.maxDistance!.toInt()}km',
        onRemove: () {
          setState(() {
            _currentFilter = _currentFilter.copyWith(maxDistance: null);
          });
          _applyCurrentFilter();
        },
      ));
    }

    if (filterChips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Active Filters:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentFilter = EventFilter.empty();
                  selectedFilter = 'All';
                });
                _applyCurrentFilter();
              },
              child: Text(
                'Clear All',
                style: TextStyle(
                  color: const Color(0xFF6958CA),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filterChips,
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6958CA).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6958CA), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF6958CA),
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              color: Color(0xFF6958CA),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _applyCurrentFilter() async {
    if (_currentFilter.hasActiveFilters) {
      await context.read<EventProvider>().fetchFilteredEvents(_currentFilter);
    } else {
      await context.read<EventProvider>().fetchEvents(forceRefresh: true);
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => FilterBottomSheet(
          currentFilter: _currentFilter,
          onApplyFilter: (filter) async {
            setState(() {
              _currentFilter = filter;
              // Update selected filter for category chips
              selectedFilter = filter.category ?? 'All';
            });

            // If there are active filters, fetch filtered events from API
            if (filter.hasActiveFilters) {
              await context.read<EventProvider>().fetchFilteredEvents(filter);
            } else {
              // If no filters, fetch all events
              await context.read<EventProvider>().fetchEvents(forceRefresh: true);
            }
          },
        ),
      ),
    );
  }
}
