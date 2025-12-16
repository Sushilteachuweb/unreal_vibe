class Attendee {
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String passType;

  Attendee({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.passType,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'passType': passType,
    };
  }

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      passType: json['passType'] ?? '',
    );
  }

  Attendee copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? gender,
    String? passType,
  }) {
    return Attendee(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      passType: passType ?? this.passType,
    );
  }

  bool get isValid {
    return fullName.isNotEmpty &&
           email.isNotEmpty &&
           phone.isNotEmpty &&
           gender.isNotEmpty &&
           passType.isNotEmpty &&
           _isValidEmail(email) &&
           _isValidPhone(phone);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }
}