import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import 'api_routes.dart';
import 'user_storage.dart';
import 'sse_service.dart';

class NotificationService {
  /// Fetch user's notifications from the new API
  static Future<NotificationsResponse> fetchNotifications({int page = 1, int limit = 20}) async {
    try {
      // Get auth token first
      final token = await UserStorage.getToken();
      final isLoggedIn = await UserStorage.getLoginStatus();
      
      if (token == null || !isLoggedIn) {
        throw Exception('AUTHENTICATION_REQUIRED');
      }

      print('🔍 Fetching notifications from: ${ApiConfig.getNotifications}');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.getNotifications}?page=$page&limit=$limit'),
        headers: await ApiConfig.getAuthHeadersWithCookies(token),
      ).timeout(const Duration(seconds: 15));

      print('📊 Notifications API Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> notificationsJson = data['notifications'] ?? [];
          final List<NotificationModel> notifications = notificationsJson
              .map((json) => NotificationModel.fromJson(json))
              .toList();
          
          return NotificationsResponse(
            success: true,
            message: 'Notifications fetched successfully',
            notifications: notifications,
            totalCount: data['total'] ?? notifications.length,
            unreadCount: notifications.where((n) => !n.isRead).length,
          );
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch notifications');
        }
      } else if (response.statusCode == 401) {
        await UserStorage.clearAll();
        throw Exception('AUTHENTICATION_REQUIRED');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Notifications API failed: $e');
      
      if (e.toString().contains('AUTHENTICATION_REQUIRED')) {
        rethrow;
      }
      
      // Return empty response instead of dummy data
      return NotificationsResponse(
        success: false,
        message: 'Failed to fetch notifications: ${e.toString()}',
        notifications: [],
        totalCount: 0,
        unreadCount: 0,
      );
    }
  }

  /// Get notification count
  static Future<int> getNotificationCount() async {
    try {
      final token = await UserStorage.getToken();
      final isLoggedIn = await UserStorage.getLoginStatus();
      
      if (token == null || !isLoggedIn) {
        return 0;
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getNotificationsCount),
        headers: await ApiConfig.getAuthHeadersWithCookies(token),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['count'] ?? 0;
      }
      
      return 0;
    } catch (e) {
      print('❌ Failed to get notification count: $e');
      return 0;
    }
  }

  /// Mark notifications as read using the new API
  static Future<bool> markAsRead(List<String> notificationIds) async {
    try {
      final token = await UserStorage.getToken();
      if (token == null) {
        throw Exception('AUTHENTICATION_REQUIRED');
      }

      print('🔄 Marking notifications as read: ${notificationIds.length} items');
      
      final response = await http.post(
        Uri.parse(ApiConfig.markNotificationsRead),
        headers: await ApiConfig.getAuthHeadersWithCookies(token),
        body: json.encode({
          'notification_ids': notificationIds,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📊 Mark as read response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ Marked ${data['marked_read'] ?? 0} notifications as read');
        return data['success'] == true;
      } else if (response.statusCode == 401) {
        await UserStorage.clearAll();
        throw Exception('AUTHENTICATION_REQUIRED');
      } else {
        return false;
      }
    } catch (e) {
      print('❌ Error marking notifications as read: $e');
      return false;
    }
  }

  /// Mark single notification as read
  static Future<bool> markSingleAsRead(String notificationId) async {
    return markAsRead([notificationId]);
  }

  /// Mark all notifications as read
  static Future<bool> markAllAsRead(List<String> allNotificationIds) async {
    return markAsRead(allNotificationIds);
  }

  /// Delete notification
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      final token = await UserStorage.getToken();
      if (token == null) {
        throw Exception('AUTHENTICATION_REQUIRED');
      }

      print('🗑️ Deleting notification: $notificationId');
      
      final response = await http.delete(
        Uri.parse(ApiConfig.deleteNotification(notificationId)),
        headers: await ApiConfig.getAuthHeadersWithCookies(token),
      ).timeout(const Duration(seconds: 10));

      print('📊 Delete response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Notification deleted successfully');
        return true;
      } else if (response.statusCode == 404) {
        print('⚠️ Notification not found (already deleted?)');
        return true; // Consider it successful if already gone
      } else if (response.statusCode == 401) {
        await UserStorage.clearAll();
        throw Exception('AUTHENTICATION_REQUIRED');
      } else {
        return false;
      }
    } catch (e) {
      print('❌ Error deleting notification: $e');
      return false;
    }
  }

  /// Initialize SSE connection for real-time notifications
  static Future<void> initializeSSE() async {
    try {
      await SSEService.instance.connect();
      print('✅ SSE initialized for real-time notifications');
    } catch (e) {
      print('❌ Failed to initialize SSE: $e');
    }
  }

  /// Disconnect SSE
  static void disconnectSSE() {
    SSEService.instance.disconnect();
    print('🔌 SSE disconnected');
  }


}