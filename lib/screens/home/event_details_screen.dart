import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/event_provider.dart';
import '../ticket/ticket_selection_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Event get event => widget.event;
  int _selectedAboutTab = 0; // 0 for About The Party, 1 for Party Terms

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
                    _buildEventDetailsInfo(context),
                    // _buildEventGallery(context),
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
            widget.event.imageUrl.startsWith('http')
                ? Image.network(
                    widget.event.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.image, color: Colors.grey, size: 48),
                      );
                    },
                  )
                : Image.asset(
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
            child: _buildInfoCard(
              context: context,
              icon: Icons.location_on,
              title: widget.event.location,
              subtitle: widget.event.location,
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

  Widget _buildEventDetailsInfo(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
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
      child: Column(
        children: [
          _buildInfoItem(
            icon: Icons.people_outline,
            iconColor: const Color(0xFFE91E63),
            iconBgColor: const Color(0xFFE91E63).withOpacity(0.15),
            text: widget.event.ageRestriction ?? 'For age 23 - 34 years',
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.star_outline,
            iconColor: const Color(0xFFFFA726),
            iconBgColor: const Color(0xFFFFA726).withOpacity(0.15),
            text: widget.event.whatsIncluded ?? 'Price Includes 1 Beverage, Nibbles, Experience + BYOB',
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.groups_outlined,
            iconColor: const Color(0xFF7E57C2),
            iconBgColor: const Color(0xFF7E57C2).withOpacity(0.15),
            text: 'You can expect 8 - 20 people in the party',
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.favorite_outline,
            iconColor: const Color(0xFF26A69A),
            iconBgColor: const Color(0xFF26A69A).withOpacity(0.15),
            text: 'This party maintains at least a 60 : 40 male to female ratio',
          ),
        ],
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          widget.event.partyFlow ??
              'Kick off the night with some chill lo-fi beats, transitioning into groovy house music as the vibe picks up. Expect a surprise guest DJ set around midnight! The dance floor will be open all night long.',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
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
          widget.event.thingsToKnow ??
              'We\'ve got a fully stocked bar with signature cocktails. No outside food or drinks allowed. Coat check is available at the entrance.',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPartyTermsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Terms & Conditions',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '• Must be 21+ with valid ID\n• No refunds or exchanges\n• Event may be cancelled due to weather\n• Photography and videography allowed\n• Management reserves the right to refuse entry',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Safety Guidelines',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '• Please drink responsibly\n• Report any incidents to security\n• Emergency exits are clearly marked\n• First aid station available on-site',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            height: 1.5,
          ),
        ),
      ],
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
    
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        // Exclude current event from the list
        final otherEvents = eventProvider.events.where((event) => event.id != widget.event.id).take(5).toList();
        
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
                      child: _buildEventCard(event, context),
                    );
                  },
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
                      'DEC 01 | SUN',
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
              backgroundImage: widget.event.djImage != null
                  ? NetworkImage(widget.event.djImage!)
                  : null,
              backgroundColor: Colors.grey[800],
              child: widget.event.djImage == null
                  ? const Icon(Icons.person, color: Colors.white, size: 25)
                  : null,
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
                    widget.event.hostName ?? widget.event.djName ?? 'Vishal Singh',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
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
                  '${widget.event.partiesHosted ?? 3} Parties',
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
                  'Starting From',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  widget.event.coverCharge,
                  style: TextStyle(
                    color: Color(0xFF00D9A5),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
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
          ],
        ),
      ),
    );
  }
}
