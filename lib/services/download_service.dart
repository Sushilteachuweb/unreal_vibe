import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'user_storage.dart';
import 'api_routes.dart';

class DownloadService {
  static final Dio _dio = Dio();

  /// Download ticket PDF and save to device
  static Future<String> downloadTicket({
    required String bookingId,
    required String eventName,
    required BuildContext context,
  }) async {
    try {
      // Request storage permission with user dialog
      final permission = await _requestStoragePermission(context);
      if (!permission) {
        throw Exception('Storage permission denied');
      }

      // Get auth token
      final token = await UserStorage.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      // Prepare download
      final endpoint = ApiConfig.downloadTicket(bookingId);
      final fileName = 'ticket_${eventName.replaceAll(' ', '_')}_$bookingId.pdf';
      final savePath = await _getSavePath(fileName);

      print('📥 Starting download...');
      print('📍 Endpoint: $endpoint');
      print('💾 Save path: $savePath');
      print('🔐 Token: ${token.substring(0, 20)}...');

      // Show download progress
      if (context.mounted) {
        _showDownloadDialog(context, eventName);
      }

      // Download file using dio with proper authentication (Bearer + Cookie)
      final authHeaders = await ApiConfig.getAuthHeadersWithCookies(token);
      final headers = {
        ...authHeaders,
        'Accept': 'application/pdf',
      };
      
      print('🔐 Download headers: ${headers.keys.join(', ')}');
      
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('📊 Download progress: $progress%');
          }
        },
      );

      print('📊 Download response status: ${response.statusCode}');
      print('📊 Download response headers: ${response.headers}');
      print('📊 Response data type: ${response.data.runtimeType}');
      print('📊 Response data length: ${response.data?.length ?? 0}');

      if (response.statusCode == 200 && response.data != null) {
        // Ensure directory exists
        final file = File(savePath);
        final directory = file.parent;
        if (!await directory.exists()) {
          print('📁 Creating directory: ${directory.path}');
          await directory.create(recursive: true);
        }

        // Write file to disk
        print('💾 Writing file to: $savePath');
        await file.writeAsBytes(response.data);
        
        // Verify file was written
        if (await file.exists()) {
          final fileSize = await file.length();
          print('✅ File written successfully, size: $fileSize bytes');
          
          if (fileSize == 0) {
            throw Exception('Downloaded file is empty');
          }
        } else {
          throw Exception('File was not created on disk');
        }
      } else {
        print('❌ Download failed with status: ${response.statusCode}');
        print('❌ Response data: ${response.data}');
        throw Exception('Download failed with status: ${response.statusCode}');
      }

      // Close progress dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      print('✅ Download completed successfully');
      print('📁 File saved to: $savePath');
      
      // Show success message
      if (context.mounted) {
        _showSuccessSnackBar(context, fileName, savePath);
      }
      
      return savePath;
    } catch (e) {
      print('❌ Download error: $e');
      print('❌ Error type: ${e.runtimeType}');
      
      // Close any open dialogs
      if (context.mounted) {
        // Try to close dialog, but don't fail if it's not open
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
        
        // Show detailed error message
        String errorMessage = 'Download failed';
        if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.toString().contains('404')) {
          errorMessage = 'Ticket not found. Please contact support.';
        } else if (e.toString().contains('403')) {
          errorMessage = 'Access denied. You may not own this ticket.';
        } else if (e.toString().contains('Storage permission')) {
          errorMessage = 'Storage permission denied. Please enable it in settings.';
        } else {
          errorMessage = 'Download failed: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
      
      rethrow;
    }
  }

  /// Request storage permission with user-friendly dialog
  static Future<bool> _requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      print('📱 Android SDK version: $sdkInt');
      
      // For Android 13+ (API 33+), we need different permissions
      if (sdkInt >= 33) {
        // Android 13+ uses granular media permissions
        final status = await Permission.photos.status;
        if (status.isDenied) {
          // Show explanation dialog first
          final shouldRequest = await _showPermissionDialog(
            context,
            'Storage Access Required',
            'To download your ticket, we need permission to save files to your device. This allows you to access your tickets offline.',
            'Allow Access',
          );
          
          if (!shouldRequest) return false;
          
          final result = await Permission.photos.request();
          if (result.isPermanentlyDenied) {
            await _showSettingsDialog(context);
            return false;
          }
          return result.isGranted;
        }
        return status.isGranted;
      } else if (sdkInt >= 30) {
        // Android 11-12 (API 30-32) - still use storage permission but with scoped storage
        final status = await Permission.storage.status;
        if (status.isDenied) {
          final shouldRequest = await _showPermissionDialog(
            context,
            'Storage Permission Required',
            'To save your ticket to Downloads folder, we need storage permission. You can also choose to save to app folder without permission.',
            'Grant Permission',
            showSkipOption: true,
          );
          
          if (!shouldRequest) return true; // User chose to skip, use app folder
          
          final result = await Permission.storage.request();
          if (result.isPermanentlyDenied) {
            await _showSettingsDialog(context);
            return true; // Still allow download to app folder
          }
          return result.isGranted;
        }
        return status.isGranted;
      } else {
        // Android 10 and below - traditional storage permission
        final status = await Permission.storage.status;
        if (status.isDenied) {
          final shouldRequest = await _showPermissionDialog(
            context,
            'Storage Permission Required',
            'To download your ticket to the Downloads folder, we need access to your device storage.',
            'Grant Permission',
          );
          
          if (!shouldRequest) return false;
          
          final result = await Permission.storage.request();
          if (result.isPermanentlyDenied) {
            await _showSettingsDialog(context);
            return false;
          }
          return result.isGranted;
        }
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit permission for app documents directory
      return true;
    }
    
    return true;
  }

  /// Show permission explanation dialog
  static Future<bool> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
    String allowButtonText, {
    bool showSkipOption = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Row(
            children: [
              const Icon(Icons.folder_open, color: Color(0xFF6958CA)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            if (showSkipOption)
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Use App Folder',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6958CA),
              ),
              child: Text(
                allowButtonText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Show settings dialog when permission is permanently denied
  static Future<void> _showSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Row(
            children: [
              Icon(Icons.settings, color: Color(0xFF6958CA)),
              SizedBox(width: 8),
              Text(
                'Permission Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Storage permission has been permanently denied. Please enable it in app settings to download tickets to your Downloads folder.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6958CA),
              ),
              child: const Text(
                'Open Settings',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Get appropriate save path based on permissions and platform
  static Future<String> _getSavePath(String fileName) async {
    Directory directory;
    
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      print('📱 Android SDK: $sdkInt');
      
      // Check if we have storage permission
      bool hasStoragePermission = false;
      if (sdkInt >= 33) {
        hasStoragePermission = await Permission.photos.isGranted;
      } else {
        hasStoragePermission = await Permission.storage.isGranted;
      }
      
      print('🔐 Storage permission: $hasStoragePermission');
      
      // Try to use the public Downloads folder if we have permission (older Android)
      if (hasStoragePermission && sdkInt < 30) {
        try {
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (await downloadsDir.exists()) {
            directory = downloadsDir;
            print('📁 Using public Downloads directory: ${directory.path}');
            final fullPath = '${directory.path}/$fileName';
            print('💾 Full save path: $fullPath');
            return fullPath;
          }
        } catch (e) {
          print('❌ Error accessing Downloads directory: $e');
        }
      }
      
      // Fallback to app-specific external storage
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // This creates a path like: /storage/emulated/0/Android/data/com.yourapp/files/Downloads
          final downloadsDir = Directory('${externalDir.path}/Downloads');
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
            print('📁 Created app Downloads directory: ${downloadsDir.path}');
          }
          directory = downloadsDir;
          print('📁 Using app external Downloads: ${directory.path}');
        } else {
          throw Exception('External storage not available');
        }
      } catch (e) {
        print('❌ Error accessing external storage: $e');
        
        // Final fallback to app documents directory
        directory = await getApplicationDocumentsDirectory();
        print('📁 Fallback to app documents: ${directory.path}');
      }
    } else if (Platform.isIOS) {
      // iOS: Use app documents directory
      directory = await getApplicationDocumentsDirectory();
      print('📁 Using iOS documents directory: ${directory.path}');
    } else {
      // Other platforms: Use app documents directory
      directory = await getApplicationDocumentsDirectory();
      print('📁 Using documents directory: ${directory.path}');
    }

    final fullPath = '${directory.path}/$fileName';
    print('💾 Full save path: $fullPath');
    return fullPath;
  }

  /// Show download progress dialog
  static void _showDownloadDialog(BuildContext context, String eventName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF6958CA),
              ),
              const SizedBox(height: 20),
              Text(
                'Downloading ticket for\n$eventName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show success snack bar with file location
  static void _showSuccessSnackBar(BuildContext context, String fileName, String filePath) async {
    // Verify file actually exists and get size
    String sizeInfo = '';
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final size = await file.length();
        sizeInfo = ' (${(size / 1024).toStringAsFixed(1)} KB)';
      } else {
        sizeInfo = ' (File not found!)';
      }
    } catch (e) {
      sizeInfo = ' (Error checking file)';
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ticket downloaded successfully!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Saved as: $fileName$sizeInfo',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              if (Platform.isAndroid)
                Text(
                  _getLocationMessage(filePath),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              if (Platform.isAndroid && filePath.contains('/Android/data/'))
                const Text(
                  'Open file manager → Android → data → [app name] → files → Downloads',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text(
                  'Path: $filePath',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              _openFile(filePath);
            },
          ),
        ),
      );
    }
  }

  /// Get user-friendly location message
  static String _getLocationMessage(String filePath) {
    if (filePath.contains('/storage/emulated/0/Download')) {
      return 'Saved to Downloads folder';
    } else if (filePath.contains('/Android/data/')) {
      return 'Saved to app files (accessible via file manager)';
    } else {
      return 'Saved to app storage';
    }
  }

  /// Open downloaded file (placeholder for future implementation)
  static void _openFile(String filePath) {
    print('📂 Opening file: $filePath');
    // TODO: Implement file opening with default app
    // This would require additional packages like open_file or url_launcher
  }
}