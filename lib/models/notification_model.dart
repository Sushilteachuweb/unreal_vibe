import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? json['body'] ?? '',
      type: json['type'] ?? 'general',
      isRead: json['isRead'] ?? json['read'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? json['timestamp'] ?? '') ?? DateTime.now(),
      data: json['meta'] as Map<String, dynamic>? ?? json['data'] as Map<String, dynamic>?,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'booking':
      case 'booking_confirmed':
        return Icons.confirmation_number;
      case 'tickets_generated':
      case 'ticket':
        return Icons.confirmation_number;
      case 'event':
        return Icons.event;
      case 'payment':
      case 'payment_successful':
        return Icons.payment;
      case 'reminder':
        return Icons.alarm;
      case 'promotion':
      case 'offer':
        return Icons.local_offer;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Color get iconColor {
    switch (type.toLowerCase()) {
      case 'booking':
      case 'booking_confirmed':
        return const Color(0xFF10B981); // Green
      case 'tickets_generated':
      case 'ticket':
        return const Color(0xFF6958CA); // Purple (brand color)
      case 'event':
        return const Color(0xFF6366F1); // Purple
      case 'payment':
      case 'payment_successful':
        return const Color(0xFFF59E0B); // Yellow
      case 'reminder':
        return const Color(0xFFEF4444); // Red
      case 'promotion':
      case 'offer':
        return const Color(0xFFEC4899); // Pink
      case 'system':
        return const Color(0xFF6B7280); // Gray
      default:
        return const Color(0xFF3B82F6); // Blue
    }
  }
}

class NotificationsResponse {
  final bool success;
  final String message;
  final List<NotificationModel> notifications;
  final int totalCount;
  final int unreadCount;

  NotificationsResponse({
    required this.success,
    required this.message,
    required this.notifications,
    required this.totalCount,
    required this.unreadCount,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final notificationsList = json['notifications'] as List<dynamic>? ?? 
                             json['data'] as List<dynamic>? ?? 
                             [];

    final notifications = notificationsList
        .map((notificationJson) => NotificationModel.fromJson(notificationJson as Map<String, dynamic>))
        .toList();

    return NotificationsResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      notifications: notifications,
      totalCount: json['totalCount'] ?? notifications.length,
      unreadCount: json['unreadCount'] ?? notifications.where((n) => !n.isRead).length,
    );
  }
}