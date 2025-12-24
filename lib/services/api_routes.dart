class ApiConfig {
  // Base URL
  static const String baseUrl = "https://api.unrealvibe.com/api";
  
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
  
  // Event endpoints
  static const String getEvents = "$baseUrl/event/events";
  static const String getTrendingEvents = "$baseUrl/event/events?trendingOnly=true";
  static const String searchEvents = "$baseUrl/event/search";
  static const String filterEvents = "$baseUrl/event/filter";
  static String shareEvent(String eventId) => "$baseUrl/event/$eventId/share";
  static String saveEvent(String eventId) => "$baseUrl/event/$eventId/save";
  static const String getSavedEvents = "$baseUrl/event/saved-events";
  static String submitReview(String eventId) => "$baseUrl/event/$eventId/reviews";
  
  // Ticket/Passes endpoints
  static String getEventPasses(String eventId) => "$baseUrl/passes/$eventId";
  static const String getMyPasses = "$baseUrl/passes/my-passes";
  static String downloadTicket(String bookingId) => "$baseUrl/passes/my-passes/download/$bookingId";
  
  // Payment endpoints
  static const String createOrder = "$baseUrl/payment/create-order";
  static const String verifyPayment = "$baseUrl/payment/verify-payment";
  
  // Notification endpoints - Updated API structure
  static const String getNotificationsSSE = "$baseUrl/sse/notifications"; // SSE endpoint (confirmed working)
  static const String getNotifications = "$baseUrl/notifications"; // REST endpoint (now available)
  static const String getNotificationsCount = "$baseUrl/notifications/count"; // Count endpoint
  static const String markNotificationsRead = "$baseUrl/notifications/mark-read"; // Mark as read endpoint
  static String deleteNotification(String id) => "$baseUrl/notifications/$id"; // Delete endpoint
  
  // Host endpoints
  static const String hostRequest = "$baseUrl/host/requestinput";
  
  // Alternative host endpoints to try if the main one fails
  static const String hostRequestAlt1 = "$baseUrl/host/request";
  static const String hostRequestAlt2 = "$baseUrl/host/create";
  static const String hostRequestAlt3 = "$baseUrl/host/submit";
  
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
