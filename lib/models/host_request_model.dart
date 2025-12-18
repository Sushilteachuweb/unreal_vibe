class HostRequest {
  final String preferredPartyDate;
  final String locality;
  final String city;
  final String pincode;

  HostRequest({
    required this.preferredPartyDate,
    required this.locality,
    required this.city,
    required this.pincode,
  });

  Map<String, dynamic> toJson() {
    return {
      'preferredPartyDate': preferredPartyDate,
      'locality': locality,
      'city': city,
      'pincode': pincode,
    };
  }

  factory HostRequest.fromJson(Map<String, dynamic> json) {
    return HostRequest(
      preferredPartyDate: json['preferredPartyDate'] ?? '',
      locality: json['locality'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }
}

class HostRequestResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final String? error;
  final int? statusCode;

  HostRequestResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
    this.statusCode,
  });

  factory HostRequestResponse.fromJson(Map<String, dynamic> json) {
    return HostRequestResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      error: json['error'],
      statusCode: json['statusCode'],
    );
  }
}