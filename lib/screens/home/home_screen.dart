import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unreal_vibe/screens/home/event_card.dart';
import 'package:unreal_vibe/screens/home/search_bar.dart';
import '../../models/event_model.dart';
import 'event_details_screen.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/user_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/api_debug.dart';
import '../search/search_screen.dart';
import '../../widgets/skeleton_loading.dart';
import '../../widgets/hero_video_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> filterTags = ['All', 'Music', 'Favorite'];
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Only fetch events if needed (no cache or cache expired)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEventsIfNeeded();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<EventProvider>().fetchEvents(forceRefresh: true);
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
                      child: Row(
                        children: [
                          const SkeletonLoading(width: 60, height: 36, borderRadius: BorderRadius.all(Radius.circular(18))),
                          const SizedBox(width: 8),
                          const SkeletonLoading(width: 80, height: 36, borderRadius: BorderRadius.all(Radius.circular(18))),
                          const SizedBox(width: 8),
                          const SkeletonLoading(width: 70, height: 36, borderRadius: BorderRadius.all(Radius.circular(18))),
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
                                    child: CustomSearchBar(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const SearchScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              _buildTrendingEvents(trendingEvents, context),
                              const SizedBox(height: 32),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: padding),
                                child: _buildAllEvents(context, eventProvider),
                              ),
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
    final filteredEvents = eventProvider.getFilteredEvents(selectedFilter);
    
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
            Row(
              children: [
                Icon(
                  Icons.filter_list_sharp,
                  color: Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filters',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Filter tags below the header
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filterTags.length,
            itemBuilder: (context, index) {
              final tag = filterTags[index];
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
}
