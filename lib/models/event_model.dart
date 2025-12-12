class Event {
  final String id;
  final String title;
  final String? subtitle;
  final String date;
  final String location;
  final String coverCharge;
  final String imageUrl;
  final List<String> tags;
  final bool isTrending;
  final String? status;
  final String? djName;
  final String? djImage;
  final double? rating;
  final int? ratingCount;
  final String? time;
  final String? ageRestriction;
  final String? dressCode;
  final String? entryFee;
  final List<String>? galleryImages;
  final String? aboutParty;
  final String? partyFlow;
  final String? thingsToKnow;
  final String? partyEtiquette;
  final String? whatsIncluded;
  final String? houseRules;
  final String? howItWorks;
  final String? cancellationPolicy;
  final int? partiesHosted;
  final String? hostName;

  Event({
    required this.id,
    required this.title,
    this.subtitle,
    required this.date,
    required this.location,
    required this.coverCharge,
    required this.imageUrl,
    required this.tags,
    this.isTrending = false,
    this.status,
    this.djName,
    this.djImage,
    this.rating,
    this.ratingCount,
    this.time,
    this.ageRestriction,
    this.dressCode,
    this.entryFee,
    this.galleryImages,
    this.aboutParty,
    this.partyFlow,
    this.thingsToKnow,
    this.partyEtiquette,
    this.whatsIncluded,
    this.houseRules,
    this.howItWorks,
    this.cancellationPolicy,
    this.partiesHosted,
    this.hostName,
  });

  // Factory constructor to create Event from API JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    // Convert categories array to tags with proper formatting
    List<String> tags = [];
    if (json['categories'] != null) {
      tags = (json['categories'] as List<dynamic>)
          .map((category) => category.toString().toUpperCase())
          .toList();
    }
    
    // Add age restriction as a tag if available
    if (json['ageRestriction'] != null) {
      tags.add('AGE: ${json['ageRestriction']}');
    }

    // Format date from ISO string to readable format
    String formattedDate = json['date'] ?? '';
    if (formattedDate.isNotEmpty) {
      try {
        DateTime dateTime = DateTime.parse(formattedDate);
        List<String> months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        formattedDate = '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
      } catch (e) {
        formattedDate = json['date'] ?? '';
      }
    }

    // Generate status based on trending and other factors
    String? status;
    if (json['trending'] == true) {
      status = 'High Demand';
    }

    // Build image URL - assuming the API returns relative paths
    String imageUrl = json['eventImage'] ?? 'assets/images/house_party.jpg';
    if (imageUrl.startsWith('/uploads/')) {
      imageUrl = 'http://api.unrealvibe.com${imageUrl}';
    }

    return Event(
      id: json['_id'] ?? '',
      title: json['eventName'] ?? 'Untitled Event',
      subtitle: null, // Not available in API
      date: formattedDate,
      location: json['city'] ?? json['fullAddress'] ?? 'Unknown Location',
      coverCharge: '₹ ${json['entryFees'] ?? 0}',
      imageUrl: imageUrl,
      tags: tags,
      isTrending: json['trending'] ?? false,
      status: status,
      djName: null, // Not available in API
      djImage: null, // Not available in API
      rating: null, // Not available in API
      ratingCount: null, // Not available in API
      time: json['time'],
      ageRestriction: json['ageRestriction'],
      dressCode: null, // Not available in API
      entryFee: '₹ ${json['entryFees'] ?? 0}',
      galleryImages: null, // Not available in API
      aboutParty: json['about'],
      partyFlow: json['partyFlow'],
      thingsToKnow: null, // Not available in API
      partyEtiquette: json['partyEtiquette'],
      whatsIncluded: json['whatsIncluded'],
      houseRules: json['houseRules'],
      howItWorks: json['howItWorks'],
      cancellationPolicy: json['cancellationPolicy'],
      partiesHosted: json['totalEventsHosted'],
      hostName: json['hostedBy'],
    );
  }


}
