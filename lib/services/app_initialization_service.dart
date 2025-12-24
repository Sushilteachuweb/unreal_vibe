import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import 'sse_service.dart';
import 'user_storage.dart';

class AppInitializationService {
  static bool _isInitialized = false;
  
  /// Initialize app services including notifications
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('🔄 App already initialized');
      return;
    }
    
    try {
      print('🚀 Initializing app services...');
      
      // Check if user is logged in
      final isLoggedIn = await UserStorage.getLoginStatus();
      final token = await UserStorage.getToken();
      
      if (isLoggedIn && token != null) {
        print('👤 User is logged in, initializing notification services...');
        
        // Initialize SSE for real-time notifications
        await NotificationService.initializeSSE();
        
        // Optionally fetch initial notification count
        final count = await NotificationService.getNotificationCount();
        print('🔔 Initial notification count: $count');
        
      } else {
        print('👤 User not logged in, skipping notification initialization');
      }
      
      _isInitialized = true;
      print('✅ App initialization completed');
      
    } catch (e) {
      print('❌ App initialization failed: $e');
      // Don't throw - app should still work without notifications
    }
  }
  
  /// Reinitialize after login
  static Future<void> reinitializeAfterLogin() async {
    print('🔄 Reinitializing after login...');
    _isInitialized = false;
    await initialize();
  }
  
  /// Cleanup on logout
  static Future<void> cleanup() async {
    print('🧹 Cleaning up app services...');
    
    try {
      // Disconnect SSE
      NotificationService.disconnectSSE();
      
      _isInitialized = false;
      print('✅ App cleanup completed');
      
    } catch (e) {
      print('❌ App cleanup failed: $e');
    }
  }
  
  /// Check if services are initialized
  static bool get isInitialized => _isInitialized;
  
  /// Get SSE connection status
  static bool get isSSEConnected => SSEService.instance.isConnected;
}