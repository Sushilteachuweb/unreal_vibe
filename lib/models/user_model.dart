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
    return UserDocuments(
      aadhaar: json['aadhaar'],
      pan: json['pan'],
      drivingLicense: json['drivingLicense'],
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
  final bool isVerified;
  final bool isHostRequestPending;
  final bool isActive;
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
    this.isVerified = false,
    this.isHostRequestPending = false,
    this.isActive = true,
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
      'isVerified': isVerified,
      'isHostRequestPending': isHostRequestPending,
      'isActive': isActive,
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
      isVerified: json['isVerified'] ?? false,
      isHostRequestPending: json['isHostRequestPending'] ?? false,
      isActive: json['isActive'] ?? true,
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
    bool? isVerified,
    bool? isHostRequestPending,
    bool? isActive,
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
      isVerified: isVerified ?? this.isVerified,
      isHostRequestPending: isHostRequestPending ?? this.isHostRequestPending,
      isActive: isActive ?? this.isActive,
      photos: photos ?? this.photos,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
