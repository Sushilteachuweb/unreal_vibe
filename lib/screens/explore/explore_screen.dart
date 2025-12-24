import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../home/event_card.dart';
import '../home/event_details_screen.dart';
import '../home/search_bar.dart';
import '../../providers/user_provider.dart';
import '../../providers/event_provider.dart';
import '../../services/search_service.dart';
import '../../utils/error_handler.dart';
import '../../widgets/skeleton_loading.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<Event> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Only fetch events if needed (no cache or cache expired)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = context.read<EventProvider>();
      eventProvider.fetchEventsIfNeeded();
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
      
      final results = await SearchService.searchInCity(query, userCity);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      if (mounted) {
        // Log detailed error for developers
        debugPrint('🚨 [ExploreScreen] Search error: $e');
        
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
    await eventProvider.fetchEvents(forceRefresh: true);
  }

  Widget _buildSkeletonLoading() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Search bar skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonLoading(width: double.infinity, height: 48),
          ),
          const SizedBox(height: 16),
          // Category chips skeleton
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: const SkeletonLoading(
                    width: 80,
                    height: 36,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Upcoming events skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoading(width: 150, height: 18),
                SizedBox(height: 12),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
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
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final filteredEvents = eventProvider.getFilteredEvents(selectedCategory);

        return _buildExploreContent(context, eventProvider, filteredEvents);
      },
    );
  }

  Widget _buildExploreContent(BuildContext context, EventProvider eventProvider, List<Event> filteredEvents) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: eventProvider.isLoading && !eventProvider.hasData
          ? _buildSkeletonLoading()
          : eventProvider.error != null && !eventProvider.hasData
              ? ErrorHandler.buildEmptyState(
                  context: 'events',
                  onRetry: () => eventProvider.fetchEvents(),
                )
              : RefreshLoadingIndicator(
                  isLoading: eventProvider.isLoading && eventProvider.hasData,
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: const Color(0xFF6958CA),
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          
                          // Search Bar
                          _buildSearchBar(),
                          
                          const SizedBox(height: 16),
                          
                          // Show search results or normal content
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildSearchResults(),
                          ] else ...[
                            // Category Chips
                            _buildCategoryChips(),
                            
                            const SizedBox(height: 20),
                            
                            // Upcoming Events
                            _buildUpcomingEventsSection(filteredEvents),
                          ],
                          
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 36,
      child: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          final availableCategories = eventProvider.getAvailableCategories();
          
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: availableCategories.length,
            itemBuilder: (context, index) {
              final category = availableCategories[index];
              final isSelected = category == selectedCategory;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6958CA) : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[400],
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUpcomingEventsSection(List<Event> filteredEvents) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Events',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
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
      ),
    );
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      'Search Results',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
                            fontSize: 14,
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
            ErrorHandler.buildEmptyState(
              context: 'search',
              customMessage: 'No events found matching "$_searchQuery"',
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
}
