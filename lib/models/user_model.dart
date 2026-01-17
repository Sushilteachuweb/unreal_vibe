class UserPhoto {
  final String url;
  final bool isProfilePhoto;
  final String? id;

  UserPhoto({
    required this.url,
    this.isProfilePhoto = false,
    this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'isProfilePhoto': isProfilePhoto,
      if (id != null) '_id': id,
    };
  }

  factory UserPhoto.fromJson(Map<String, dynamic> json) {
    return UserPhoto(
      url: json['url'] ?? '',
      isProfilePhoto: json['isProfilePhoto'] ?? false,
      id: json['_id'],
    );
  }
}

class UserDocuments {
  final String? aadhaar;
  final String? pan;
  final String? drivingLicense;

  UserDocuments({
    this.aadhaar,
    this.pan,
    this.drivingLicense,
  });

  Map<String, dynamic> toJson() {
    return {
      if (aadhaar != null) 'aadhaar': aadhaar,
      if (pan != null) 'pan': pan,
      if (drivingLicense != null) 'drivingLicense': drivingLicense,
    };
  }

  factory UserDocuments.fromJson(Map<String, dynamic> json) {
    // Helper function to extract URL from either string or object format
    String? extractUrl(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        return value['url'] as String?;
      }
      return null;
    }

    return UserDocuments(
      aadhaar: extractUrl(json['aadhaar']),
      pan: extractUrl(json['pan']),
      drivingLicense: extractUrl(json['drivingLicense']),
    );
  }
}

class User {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? city;
  final String? gender;
  final int profileCompletion;
  final bool isProfileComplete;
  final String role;
  final String? bio;
  final String? funFact;
  final List<String>? interests;
  final bool isVerified;
  final bool isHostRequestPending;
  final bool isActive;
  final bool isHost;
  final bool isHostVerified;
  final int eventsHosted;
  final List<UserPhoto> photos;
  final UserDocuments? documents;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.city,
    this.gender,
    this.profileCompletion = 0,
    this.isProfileComplete = false,
    this.role = 'guest',
    this.bio,
    this.funFact,
    this.interests,
    this.isVerified = false,
    this.isHostRequestPending = false,
    this.isActive = true,
    this.isHost = false,
    this.isHostVerified = false,
    this.eventsHosted = 0,
    this.photos = const [],
    this.documents,
    this.createdAt,
    this.updatedAt,
  });

  // Backward compatibility - phoneNumber getter
  String get phoneNumber => phone;

  // Get profile photo URL
  String? get profilePhotoUrl {
    try {
      return photos.firstWhere((photo) => photo.isProfilePhoto).url;
    } catch (e) {
      return photos.isNotEmpty ? photos.first.url : null;
    }
  }

  // Get all photo URLs as list of strings (for backward compatibility)
  List<String> get photoUrls => photos.map((photo) => photo.url).toList();

  // Convert User to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'city': city,
      'gender': gender,
      'profileCompletion': profileCompletion,
      'isProfileComplete': isProfileComplete,
      'role': role,
      'bio': bio,
      'funFact': funFact,
      'interests': interests,
      'isVerified': isVerified,
      'isHostRequestPending': isHostRequestPending,
      'isActive': isActive,
      'isHost': isHost,
      'isHostVerified': isHostVerified,
      'eventsHosted': eventsHosted,
      'photos': photos.map((photo) => photo.toJson()).toList(),
      if (documents != null) 'documents': documents!.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create User from JSON (API response format)
  factory User.fromJson(Map<String, dynamic> json) {
    List<UserPhoto> photosList = [];
    if (json['photos'] != null) {
      if (json['photos'] is List) {
        for (var photo in json['photos']) {
          if (photo is Map<String, dynamic>) {
            photosList.add(UserPhoto.fromJson(photo));
          } else if (photo is String) {
            // Backward compatibility for string URLs
            photosList.add(UserPhoto(url: photo));
          }
        }
      }
    }

    // Parse interests list
    List<String>? interestsList;
    if (json['interests'] != null && json['interests'] is List) {
      interestsList = List<String>.from(json['interests']);
    }

    return User(
      id: json['_id'] ?? json['id'] ?? '',
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      name: json['name'],
      email: json['email'],
      city: json['city'],
      gender: json['gender'],
      profileCompletion: json['profileCompletion'] ?? 0,
      isProfileComplete: json['isProfileComplete'] ?? false,
      role: json['role'] ?? 'guest',
      bio: json['bio'],
      funFact: json['funFact'],
      interests: interestsList,
      isVerified: json['isVerified'] ?? false,
      isHostRequestPending: json['isHostRequestPending'] ?? false,
      isActive: json['isActive'] ?? true,
      isHost: json['isHost'] ?? false,
      isHostVerified: json['isHostVerified'] ?? false,
      eventsHosted: json['eventsHosted'] ?? 0,
      photos: photosList,
      documents: json['documents'] != null 
          ? UserDocuments.fromJson(json['documents']) 
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  // Create a copy with updated fields
  User copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    String? city,
    String? gender,
    int? profileCompletion,
    bool? isProfileComplete,
    String? role,
    String? bio,
    String? funFact,
    List<String>? interests,
    bool? isVerified,
    bool? isHostRequestPending,
    bool? isActive,
    bool? isHost,
    bool? isHostVerified,
    int? eventsHosted,
    List<UserPhoto>? photos,
    UserDocuments? documents,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      city: city ?? this.city,
      gender: gender ?? this.gender,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      funFact: funFact ?? this.funFact,
      interests: interests ?? this.interests,
      isVerified: isVerified ?? this.isVerified,
      isHostRequestPending: isHostRequestPending ?? this.isHostRequestPending,
      isActive: isActive ?? this.isActive,
      isHost: isHost ?? this.isHost,
      isHostVerified: isHostVerified ?? this.isHostVerified,
      eventsHosted: eventsHosted ?? this.eventsHosted,
      photos: photos ?? this.photos,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
