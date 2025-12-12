class ApiConfig {
  // Base URL
  static const String baseUrl = "http://api.unrealvibe.com/api";
  
  // Auth endpoints
  static const String requestOtp = "$baseUrl/auth/request-otp";
  static const String verifyOtp = "$baseUrl/auth/verify-otp";
  static const String register = "$baseUrl/auth/register";
  static const String logout = "$baseUrl/auth/logout";
  
  // User endpoints
  static const String createProfile = "$baseUrl/user/create-profile";
  static const String completeProfile = "$baseUrl/user/complete-profile";
  static const String getProfile = "$baseUrl/user/get-profile";
  static const String profile = "$baseUrl/user/profile";
  static const String updateProfile = "$baseUrl/user/update-profile";
  
  // Event endpoints
  static const String getEvents = "$baseUrl/event/eventsoutput";
  
  // Alternative event endpoints to try if main one fails
  static const String getEventsAlt1 = "$baseUrl/events";
  static const String getEventsAlt2 = "$baseUrl/event/events";
  static const String getEventsAlt3 = "$baseUrl/event/list";
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> getAuthHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
