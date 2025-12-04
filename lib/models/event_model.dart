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

  static List<Event> getMockEvents() {
    return [
      Event(
        id: '1',
        title: 'Tales From The Shadows - A Halloween Story Night',
        subtitle: 'Spooky tales and mysterious stories',
        date: 'Oct 31, 2024',
        location: 'Gurgaon, Mumbai',
        coverCharge: '₹ 599',
        imageUrl: 'assets/images/house_party.jpg',
        tags: ['HOUSE PARTY', 'AGE: 22+'],
        isTrending: true,
      ),
      Event(
        id: '2',
        title: 'Gala Music Festival',
        subtitle: 'An evening of smooth jazz',
        date: 'Nov 15, 2024',
        location: 'Unity Square, ID',
        coverCharge: '₹ 1299',
        imageUrl: 'assets/images/house_party2.jpg',
        tags: ['MUSIC', 'NEW'],
        isTrending: true,
      ),
      Event(
        id: '3',
        title: 'Woman\'s Day Festival',
        subtitle: 'Celebrating womanhood',
        date: 'Mar 8, 2024',
        location: 'City Road, ID',
        coverCharge: '₹ 799',
        imageUrl: 'assets/images/house_party3.jpg',
        tags: ['FESTIVAL', 'WOMEN ONLY'],
      ),
      Event(
        id: '4',
        title: 'Bastau Music Festival',
        subtitle: 'Electronic music extravaganza',
        date: 'Dec 20, 2024',
        location: 'Crowd Avenue, ID',
        coverCharge: '₹ 999',
        imageUrl: 'assets/images/house_party4.jpg',
        tags: ['MUSIC', 'AGE 18+'],
        isTrending: true,
      ),
      Event(
        id: '5',
        title: 'Summer Beats Festival',
        subtitle: 'Dance to the rhythm',
        date: 'Jun 21, 2024',
        location: 'Beach Side, ID',
        coverCharge: '₹ 1499',
        imageUrl: 'assets/images/house_party5.jpg',
        tags: ['FESTIVAL', 'DANCE'],
      ),
      Event(
        id: '6',
        title: 'Acoustic Night',
        subtitle: 'Intimate musical performances',
        date: 'Jan 10, 2024',
        location: 'Downtown Cafe, ID',
        coverCharge: '₹ 399',
        imageUrl: 'assets/images/house_party.jpg',
        tags: ['MUSIC', 'ACOUSTIC'],
      ),
      Event(
        id: '7',
        title: 'Art Gallery Opening',
        subtitle: 'Contemporary art exhibition',
        date: 'Feb 14, 2024',
        location: 'Art District, ID',
        coverCharge: '₹ 299',
        imageUrl: 'assets/images/house_party2.jpg',
        tags: ['ART', 'EXHIBITION'],
      ),
      Event(
        id: '8',
        title: 'Modern Art Showcase',
        subtitle: 'Featuring local artists',
        date: 'Mar 20, 2024',
        location: 'Gallery Street, ID',
        coverCharge: '₹ 399',
        imageUrl: 'assets/images/house_party3.jpg',
        tags: ['ART', 'NEW'],
      ),
      Event(
        id: '9',
        title: 'Cricket Championship Finals',
        subtitle: 'Watch the finals live',
        date: 'Apr 15, 2024',
        location: 'Sports Arena, ID',
        coverCharge: '₹ 1999',
        imageUrl: 'assets/images/house_party4.jpg',
        tags: ['SPORT', 'CRICKET'],
      ),
      Event(
        id: '10',
        title: 'Football League Match',
        subtitle: 'Premier league showdown',
        date: 'May 10, 2024',
        location: 'Stadium, ID',
        coverCharge: '₹ 1499',
        imageUrl: 'assets/images/house_party5.jpg',
        tags: ['SPORT', 'FOOTBALL'],
      ),
      Event(
        id: '11',
        title: 'Stand-Up Comedy Night',
        subtitle: 'Laugh out loud with top comedians',
        date: 'Jun 5, 2024',
        location: 'Comedy Club, ID',
        coverCharge: '₹ 599',
        imageUrl: 'assets/images/house_party.jpg',
        tags: ['COMEDY', 'AGE 18+'],
      ),
      Event(
        id: '12',
        title: 'Comedy Open Mic',
        subtitle: 'Fresh talent showcase',
        date: 'Jul 12, 2024',
        location: 'Laugh Lounge, ID',
        coverCharge: '₹ 299',
        imageUrl: 'assets/images/house_party2.jpg',
        tags: ['COMEDY', 'NEW'],
      ),
    ];
  }
}
