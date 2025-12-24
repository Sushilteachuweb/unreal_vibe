import 'package:flutter/material.dart';
import '../../utils/date_formatter.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String date;
  final String location;
  final String coverCharge;
  final String imageUrl;
  final List<String> tags;
  final bool isHorizontal;
  final VoidCallback? onTap;
  final String? status;

  const EventCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.date,
    required this.location,
    required this.coverCharge,
    required this.imageUrl,
    required this.tags,
    this.isHorizontal = false,
    this.onTap,
    this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalCard();
    } else {
      return _buildVerticalCard();
    }
  }

  Widget _buildHorizontalCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildImageHeader(isHorizontal: true),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEventDetails(),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cover Charge: $coverCharge',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 8),
                  _buildCardFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageHeader(isHorizontal: false),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEventDetails(),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cover Charge: $coverCharge',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 1,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 10),
                  _buildCardFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader({bool isHorizontal = false}) {
    return Stack(
      children: [
        // Main image
        Container(
          height: isHorizontal ? double.infinity : 160,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            color: Colors.grey[800],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  )
                : Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        // Gradient overlay for better text readability
        Container(
          height: isHorizontal ? double.infinity : 160,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.8),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        // Tags at top
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ..._getPriorityTags().asMap().entries.map((entry) => 
                _buildTag(entry.value, entry.key),
              ),
            ],
          ),
        ),
        // Status indicator
        if (status != null)
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(status!),
                      color: _getStatusColor(status!),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _getProgressValue(status!),
                    backgroundColor: Colors.grey[800]?.withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(status!)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTag(String tag, int index) {
    // Color-code tags based on content type
    Color tagColor;
    Color textColor;
    
    if (tag.startsWith('AGE:')) {
      // Age restriction tags: Yellow background with black text
      tagColor = const Color(0xFFFFA726); // Yellow/Orange
      textColor = Colors.black;
    } else if (_isCategoryTag(tag)) {
      // Category tags: Purple background with white text
      tagColor = const Color(0xFF6958CA); // Purple
      textColor = Colors.white;
    } else {
      // Other tags: Use index-based coloring as fallback
      if (index == 0) {
        tagColor = const Color(0xFF6958CA); // Purple
        textColor = Colors.white;
      } else {
        tagColor = const Color(0xFFFFA726); // Yellow/Orange
        textColor = Colors.black;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  bool _isCategoryTag(String tag) {
    // List of common category keywords
    const categories = [
      'MUSIC', 'FESTIVAL', 'COMEDY', 'DANCE', 'PARTY', 'CONCERT',
      'STANDUP', 'DJ', 'LIVE', 'CLUB', 'NIGHTLIFE', 'ENTERTAINMENT',
      'CULTURAL', 'FOOD', 'DRINKS', 'SOCIAL', 'NETWORKING',
      'TECHNO', 'ELECTRONIC', 'HOUSE', 'TRANCE', 'DUBSTEP', 'EDM',
      'ROCK', 'POP', 'JAZZ', 'CLASSICAL', 'INDIE', 'FOLK', 'RAP',
      'HIP-HOP', 'REGGAE', 'BLUES', 'COUNTRY', 'METAL', 'PUNK',
      'BOLLYWOOD', 'PUNJABI', 'SUFI', 'GHAZAL', 'QAWWALI',
      'WORKSHOP', 'SEMINAR', 'CONFERENCE', 'MEETUP', 'EXHIBITION',
      'THEATER', 'DRAMA', 'MUSICAL', 'OPERA', 'BALLET'
    ];
    
    return categories.any((category) => tag.toUpperCase().contains(category));
  }

  List<String> _getPriorityTags() {
    List<String> priorityTags = [];
    
    // First priority: All Categories (purple) - show up to 2 categories
    final categoryTags = tags.where((tag) => _isCategoryTag(tag) && !tag.startsWith('AGE:')).toList();
    if (categoryTags.isNotEmpty) {
      // Add up to 2 categories to show multiple genres like "Techno, Electronic"
      priorityTags.addAll(categoryTags.take(2));
    }
    
    // Second priority: Age restriction (yellow) - always show if present
    final ageTags = tags.where((tag) => tag.startsWith('AGE:')).toList();
    if (ageTags.isNotEmpty) {
      priorityTags.add(ageTags.first);
    }
    
    // If we still have space and no categories, show other important tags
    if (priorityTags.length < 3 && categoryTags.isEmpty) {
      final otherTags = tags.where((tag) => 
        !tag.startsWith('AGE:') && 
        !_isCategoryTag(tag)
      ).toList();
      
      final needed = 3 - priorityTags.length;
      priorityTags.addAll(otherTags.take(needed));
    }
    
    // Return up to 3 tags (2 categories + 1 age restriction, or 3 other tags)
    return priorityTags.take(3).toList();
  }

  Widget _buildEventDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Date
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              DateFormatter.formatToDateAndDay(date),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // Location
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              location,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardFooter() {
    return Row(
      children: [
        // Attendee avatars
        _buildAttendeeAvatars(),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            '+27',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        // View Details button
        GestureDetector(
          onTap: onTap,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View Details',
                style: TextStyle(
                  color: Color(0xFF6958CA),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 3),
              Icon(
                Icons.arrow_forward,
                color: Color(0xFF6958CA),
                size: 12,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendeeAvatars() {
    return SizedBox(
      width: 55,
      height: 24,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1C1C1E), width: 2),
              ),
            ),
          ),
          Positioned(
            left: 16,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1C1C1E), width: 2),
              ),
            ),
          ),
          Positioned(
            left: 32,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[500],
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1C1C1E), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for status indicators
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'high demand':
        return Icons.local_fire_department;
      case 'filling up fast':
        return Icons.trending_up;
      case 'just started':
        return Icons.play_circle_outline;
      case 'almost full':
        return Icons.warning_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'high demand':
        return Colors.red;
      case 'filling up fast':
        return Colors.orange;
      case 'just started':
        return Colors.green;
      case 'almost full':
        return Colors.amber;
      default:
        return Colors.white;
    }
  }

  double _getProgressValue(String status) {
    switch (status.toLowerCase()) {
      case 'high demand':
        return 0.9;
      case 'filling up fast':
        return 0.75;
      case 'just started':
        return 0.2;
      case 'almost full':
        return 0.85;
      default:
        return 0.5;
    }
  }
}
