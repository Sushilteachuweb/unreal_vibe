import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../services/sse_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _setupSSEListener();
  }

  @override
  void dispose() {
    // Don't disconnect SSE here as it should persist across screens
    super.dispose();
  }

  void _setupSSEListener() {
    // Listen for real-time notifications
    SSEService.instance.notificationStream.listen((notification) {
      if (mounted) {
        setState(() {
          _notifications.insert(0, notification);
          if (!notification.isRead) {
            _unreadCount++;
          }
        });
        
        // Show a subtle notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(notification.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notification.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: notification.iconColor,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    });

    // Listen for connection status
    SSEService.instance.connectionStream.listen((status) {
      if (mounted) {
        switch (status) {
          case 'connected':
            print('✅ SSE connected - real-time notifications active');
            break;
          case 'disconnected':
            print('🔌 SSE disconnected');
            break;
          case 'error':
            print('❌ SSE connection error');
            break;
          case 'failed':
            print('💥 SSE connection failed permanently');
            break;
        }
      }
    });
  }

  Future<void> _fetchNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Initialize SSE connection for real-time updates
      await NotificationService.initializeSSE();

      final response = await NotificationService.fetchNotifications();
      
      if (response.success) {
        setState(() {
          _notifications = response.notifications;
          _unreadCount = response.unreadCount;
          _isLoading = false;
        });
        
        // Show success message
        if (mounted && _notifications.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Loaded ${_notifications.length} notifications',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔍 Notifications fetch failed: $e');
      
      if (e.toString().contains('AUTHENTICATION_REQUIRED')) {
        setState(() {
          _error = 'Please login to view notifications';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load notifications. Please try again.';
          _isLoading = false;
        });
      }
    }
  }



  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isRead) {
      final success = await NotificationService.markSingleAsRead(notification.id);
      if (success) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = NotificationModel(
              id: notification.id,
              title: notification.title,
              message: notification.message,
              type: notification.type,
              isRead: true,
              createdAt: notification.createdAt,
              data: notification.data,
            );
            _unreadCount = _notifications.where((n) => !n.isRead).length;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification marked as read'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to mark notification as read'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final unreadIds = _notifications
        .where((n) => !n.isRead)
        .map((n) => n.id)
        .toList();
    
    if (unreadIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No unread notifications'),
          backgroundColor: Color(0xFF6958CA),
        ),
      );
      return;
    }

    final success = await NotificationService.markAllAsRead(unreadIds);
    if (success) {
      setState(() {
        _notifications = _notifications.map((notification) => 
          NotificationModel(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            type: notification.type,
            isRead: true,
            createdAt: notification.createdAt,
            data: notification.data,
          )
        ).toList();
        _unreadCount = 0;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${unreadIds.length} notifications marked as read'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to mark notifications as read'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    final success = await NotificationService.deleteNotification(notification.id);
    if (success) {
      setState(() {
        _notifications.removeWhere((n) => n.id == notification.id);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification deleted'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete notification'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            if (_unreadCount > 0)
              Text(
                '$_unreadCount unread',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Color(0xFF6958CA),
                  fontSize: 14,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchNotifications,
            tooltip: 'Refresh notifications',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        color: const Color(0xFF6958CA),
        backgroundColor: Colors.white,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6958CA),
                ),
              )
            : _error != null
                ? _buildErrorState()
                : _notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationsList(),
      ),
    );
  }

  Widget _buildErrorState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _fetchNotifications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6958CA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF6958CA).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Color(0xFF6958CA),
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'No Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'You\'re all caught up! We\'ll notify you when something new happens.',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text(
                'Delete Notification',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Are you sure you want to delete this notification?',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notification.isRead 
              ? const Color(0xFF1A1A1A) 
              : const Color(0xFF1A1A1A).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead 
                ? const Color(0xFF2A2A2A) 
                : const Color(0xFF6958CA).withOpacity(0.3),
            width: notification.isRead ? 1 : 2,
          ),
        ),
        child: InkWell(
          onTap: () => _markAsRead(notification),
          onLongPress: () => _showNotificationMenu(notification),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: notification.iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification.icon,
                    color: notification.iconColor,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: notification.isRead 
                                    ? FontWeight.w500 
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6958CA),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        notification.message,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: notification.iconColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              notification.type.toUpperCase(),
                              style: TextStyle(
                                color: notification.iconColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          
                          const Spacer(),
                          
                          Text(
                            notification.timeAgo,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationMenu(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                notification.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              if (!notification.isRead)
                ListTile(
                  leading: const Icon(Icons.mark_email_read, color: Color(0xFF10B981)),
                  title: const Text(
                    'Mark as Read',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _markAsRead(notification);
                  },
                ),
              
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteNotification(notification);
                },
              ),
              
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}