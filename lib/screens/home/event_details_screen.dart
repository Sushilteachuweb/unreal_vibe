import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../utils/responsive_helper.dart';
import '../ticket/ticket_booking_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Event get event => widget.event;

  @override
  Widget build(BuildContext context) {
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
                    // _buildEventGallery(context),
                    _buildAboutSection(context),
                    _buildPartyFlow(context),
                    _buildThingsToKnow(context),
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
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.white),
          ),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              widget.event.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.image, color: Colors.grey, size: 48),
                );
              },
            ),
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
        ],
      ),
    );
  }

  Widget _buildDJSection(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: widget.event.djImage != null
                ? NetworkImage(widget.event.djImage!)
                : null,
            backgroundColor: Colors.grey[800],
            child: widget.event.djImage == null
                ? const Icon(Icons.person, color: Colors.white, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.djName ?? 'DJ Marcos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      widget.event.location,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${widget.event.rating ?? 4.8}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' (${widget.event.ratingCount ?? 4853})',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                ),
              ),
            ],
          ),
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
              title: 'September 18,',
              subtitle: '2025, 8:00 PM to 2:00 AM',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              context: context,
              icon: Icons.location_on,
              title: 'Grand Avenue',
              subtitle: 'Gurgaon, ID',
            ),
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

  Widget _buildActionButtons(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
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
              onPressed: () {},
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


  Widget _buildGalleryPlaceholder(int index) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/house_party.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[800],
              child: const Icon(Icons.person, color: Colors.grey, size: 40),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGalleryImage(String imageUrl) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMoreImagesCard() {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          '+12',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          const SizedBox(height: 8),
          Text(
            widget.event.aboutParty ??
                'Join us for an unforgettable night of music, dancing, and great vibes. This party promises to be an experience you won\'t forget!',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyFlow(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Party Flow',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.event.partyFlow ??
                'Dive into the night with house music at 10 PM till 2 AM. Expect an electrifying atmosphere with top DJs spinning the best tracks.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThingsToKnow(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Things to Know',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.event.thingsToKnow ??
                'Please note that this event has age restrictions. Valid ID required at the entrance.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSections(BuildContext context) {
    return Column(
      children: [
        _buildExpandableSection(
          context,
          'Party Etiquette',
          widget.event.partyEtiquette ?? 'Respect others, dress appropriately, and enjoy responsibly.',
        ),
        _buildExpandableSection(
          context,
          'What\'s Included',
          widget.event.whatsIncluded ?? 'Entry to the venue, welcome drink, and access to all areas.',
        ),
        _buildExpandableSection(
          context,
          'House Rules',
          widget.event.houseRules ?? 'No outside food or drinks. Photography allowed. Be respectful.',
        ),
        _buildExpandableSection(
          context,
          'How it works',
          widget.event.howItWorks ?? 'Book your ticket, arrive at the venue, show your ticket, and enjoy!',
        ),
        _buildExpandableSection(
          context,
          'Cancellation Policy',
          widget.event.cancellationPolicy ?? 'Tickets are non-refundable. Transfers allowed up to 24 hours before the event.',
        ),
      ],
    );
  }

  Widget _buildExpandableSection(BuildContext context, String title, String content) {
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
    final allEvents = Event.getMockEvents();
    // Exclude current event from the list
    final otherEvents = allEvents.where((event) => event.id != widget.event.id).take(5).toList();
    
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Events',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
              fontWeight: FontWeight.bold,
            ),
          ),

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
                  child: _buildEventCard(event.title, event.location, event.imageUrl, context),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, String location, String imageUrl, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Find the event from mock events and navigate to its details
        final allEvents = Event.getMockEvents();
        final clickedEvent = allEvents.firstWhere(
          (event) => event.title == title && event.location == location,
          orElse: () => allEvents.first, // fallback to first event
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: clickedEvent),
          ),
        );
      },
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Image.asset(
                imageUrl,
                width: 140,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 140,
                    height: 160,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image, color: Colors.grey, size: 40),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DEC 01 | SUN',
                      style: TextStyle(
                        color: const Color(0xFF8B7FD9),
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostedBy(BuildContext context) {
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
              radius: 35,
              backgroundImage: widget.event.djImage != null
                  ? NetworkImage(widget.event.djImage!)
                  : null,
              backgroundColor: Colors.grey[800],
              child: widget.event.djImage == null
                  ? const Icon(Icons.person, color: Colors.white, size: 35)
                  : null,
            ),
            const SizedBox(width: 16),
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
                    widget.event.hostName ?? widget.event.djName ?? 'Vishal Singh',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${widget.event.partiesHosted ?? 3} Parties Hosted',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Entry Fee',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  widget.event.coverCharge,
                  style: const TextStyle(
                    color: Color(0xFF00D9A5),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[700]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white),
                          onPressed: () {},
                        ),
                        const Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TicketBookingScreen(event: widget.event),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6958CA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
