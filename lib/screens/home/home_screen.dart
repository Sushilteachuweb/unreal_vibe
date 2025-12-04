import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unreal_vibe/screens/home/event_card.dart';
import 'package:unreal_vibe/screens/home/search_bar.dart';
import '../../models/event_model.dart';
import 'event_details_screen.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/user_provider.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Event> events = Event.getMockEvents();
  final List<String> filterTags = ['All', 'Music', 'Favorite'];
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final trendingEvents = events.where((event) => event.isTrending).toList();
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxContentWidth(context),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildHeroSection(context),
                      const SizedBox(height: 20),
                      CustomSearchBar(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _buildTrendingEvents(trendingEvents, context),
                const SizedBox(height: 32),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: _buildAllEvents(context),
                ),
                const SizedBox(height: 100),
              ],
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
            'Unrealvibes',
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
                      fontSize: 14,
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
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 32);
    final subtitleSize = ResponsiveHelper.getResponsiveFontSize(context, 13);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              height: 1.2,
              letterSpacing: -0.5,
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
        const SizedBox(height: 8),
        Text(
          'Discover unforgettable events and create\nyour own.',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: subtitleSize,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingEvents(List<Event> events, BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final cardWidth = isDesktop ? 300.0 : 240.0;
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

  Widget _buildAllEvents(BuildContext context) {
    final filteredEvents = selectedFilter == 'All'
        ? events
        : events.where((event) => event.tags.any((tag) =>
            tag.toLowerCase().contains(selectedFilter.toLowerCase()))).toList();
    
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'All Events',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
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
            ),
          ],
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
