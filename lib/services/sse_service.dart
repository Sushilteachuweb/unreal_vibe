import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import 'api_routes.dart';
import 'user_storage.dart';

class SSEService {
  static SSEService? _instance;
  static SSEService get instance => _instance ??= SSEService._();
  
  SSEService._();

  HttpClient? _httpClient;
  HttpClientRequest? _request;
  StreamSubscription? _streamSubscription;
  StreamController<NotificationModel>? _notificationController;
  StreamController<String>? _connectionController;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;

  // Streams
  Stream<NotificationModel> get notificationStream => 
      _notificationController?.stream ?? const Stream.empty();
  
  Stream<String> get connectionStream => 
      _connectionController?.stream ?? const Stream.empty();

  bool get isConnected => _isConnected;

  /// Initialize SSE connection
  Future<void> connect() async {
    if (_isConnected) {
      print('🔄 SSE already connected');
      return;
    }

    try {
      final token = await UserStorage.getToken();
      final isLoggedIn = await UserStorage.getLoginStatus();
      
      if (token == null || !isLoggedIn) {
        print('❌ SSE: No auth token available');
        return;
      }

      print('🔌 Connecting to SSE: ${ApiConfig.getNotificationsSSE}');
      
      // Initialize controllers if not already done
      _notificationController ??= StreamController<NotificationModel>.broadcast();
      _connectionController ??= StreamController<String>.broadcast();

      await _establishConnection(token);
      
    } catch (e) {
      print('❌ SSE connection failed: $e');
      _handleConnectionError();
    }
  }

  Future<void> _establishConnection(String token) async {
    try {
      _httpClient = HttpClient();
      
      final uri = Uri.parse(ApiConfig.getNotificationsSSE);
      _request = await _httpClient!.openUrl('GET', uri);
      
      // Set headers for SSE
      _request!.headers.set('Accept', 'text/event-stream');
      _request!.headers.set('Cache-Control', 'no-cache');
      _request!.headers.set('Authorization', 'Bearer $token');
      
      // Add cookie if available
      final accessTokenCookie = await UserStorage.getAccessTokenCookie();
      if (accessTokenCookie != null) {
        _request!.headers.set('Cookie', 'accessToken=$accessTokenCookie');
      }
      
      final response = await _request!.close();
      
      if (response.statusCode == 200) {
        _isConnected = true;
        _reconnectAttempts = 0;
        
        print('✅ SSE Connected successfully');
        _connectionController?.add('connected');
        
        // Listen to the stream
        _streamSubscription = response
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
              _handleSSEMessage,
              onError: _handleStreamError,
              onDone: _handleStreamDone,
            );
      } else {
        throw Exception('SSE connection failed with status: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ SSE connection establishment failed: $e');
      _isConnected = false;
      _handleConnectionError();
    }
  }

  void _handleSSEMessage(String message) {
    if (message.isEmpty) return;
    
    try {
      // Handle different SSE message types
      if (message.startsWith('data: ')) {
        final data = message.substring(6); // Remove 'data: ' prefix
        
        if (data.trim().isEmpty) return;
        
        final Map<String, dynamic> json = jsonDecode(data);
        
        // Handle connection confirmation
        if (json['type'] == 'connected') {
          print('📡 SSE connection confirmed: ${json['message']}');
          return;
        }
        
        // Handle notification data
        if (json['type'] == 'notification') {
          final notification = NotificationModel.fromJson(json['data']);
          _notificationController?.add(notification);
          print('📬 Received real-time notification: ${notification.title}');
        }
        
      } else if (message.startsWith('event: ')) {
        // Handle event types if needed
        final eventType = message.substring(7);
        print('📡 SSE event: $eventType');
      }
      
    } catch (e) {
      print('❌ Error parsing SSE message: $e');
      print('Raw message: $message');
    }
  }

  void _handleStreamError(error) {
    print('❌ SSE stream error: $error');
    _isConnected = false;
    _handleConnectionError();
  }

  void _handleStreamDone() {
    print('🔌 SSE stream closed');
    _isConnected = false;
    _handleConnectionError();
  }

  /// Disconnect from SSE
  void disconnect() {
    print('🔌 Disconnecting SSE...');
    
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _request = null;
    _httpClient?.close();
    _httpClient = null;
    _isConnected = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    
    _connectionController?.add('disconnected');
  }

  /// Handle connection errors and implement reconnection logic
  void _handleConnectionError() {
    _isConnected = false;
    _connectionController?.add('error');
    
    if (_reconnectAttempts < maxReconnectAttempts) {
      _reconnectAttempts++;
      final delay = Duration(seconds: _reconnectAttempts * 2);
      
      print('🔄 SSE reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts/$maxReconnectAttempts)');
      
      _reconnectTimer = Timer(delay, () {
        connect();
      });
    } else {
      print('❌ SSE max reconnection attempts reached');
      _connectionController?.add('failed');
    }
  }

  /// Simulate receiving a notification (for testing)
  void simulateNotification(NotificationModel notification) {
    if (_notificationController != null) {
      _notificationController!.add(notification);
      print('🧪 Simulated notification: ${notification.title}');
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _notificationController?.close();
    _connectionController?.close();
    _notificationController = null;
    _connectionController = null;
    _instance = null;
  }
}