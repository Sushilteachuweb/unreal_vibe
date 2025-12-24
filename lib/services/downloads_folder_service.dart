import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'user_storage.dart';
import 'api_routes.dart';

class DownloadsFolderService {
  static final Dio _dio = Dio();

  /// Download ticket PDF and save to main Downloads folder
  static Future<String> downloadTicket({
    required String bookingId,
    required String eventName,
    required BuildContext context,
  }) async {
    try {
      // Request storage permission first
      final hasPermission = await _requestStoragePermission(context);
      if (!hasPermission) {
        throw Exception('Storage permission is required to download files');
      }

      // Get auth token
      final token = await UserStorage.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      // Prepare download
      final endpoint = ApiConfig.downloadTicket(bookingId);
      final fileName = 'ticket_${eventName.replaceAll(' ', '_')}_$bookingId.pdf';

      print('📥 Starting download to Downloads folder...');
      print('📍 Endpoint: $endpoint');
      print('📄 File name: $fileName');

      // Show download progress
      if (context.mounted) {
        _showDownloadDialog(context, eventName);
      }

      // Download file data
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/pdf',
          },
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('📊 Download progress: $progress%');
          }
        },
      );

      // Close progress dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      print('📊 Download response status: ${response.statusCode}');
      print('📊 Response data length: ${response.data?.length ?? 0}');

      if (response.statusCode == 200 && response.data != null) {
        final Uint8List fileBytes = response.data;
        
        if (fileBytes.isEmpty) {
          throw Exception('Downloaded file is empty');
        }

        // Verify it's a PDF
        final pdfHeader = String.fromCharCodes(fileBytes.take(4));
        if (pdfHeader != '%PDF') {
          print('⚠️ File may not be a valid PDF (header: $pdfHeader)');
          // Continue anyway, might still be valid
        }

        // Save file to Downloads folder
        final savedPath = await _saveToDownloadsFolder(fileName, fileBytes);
        
        print('✅ Download completed successfully');
        print('📁 File saved to Downloads: $savedPath');
        
        // Show success message
        if (context.mounted) {
          _showSuccessSnackBar(context, fileName);
        }
        
        return savedPath;
      } else {
        throw Exception('Download failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Download error: $e');
      
      // Close any open dialogs
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
        
        // Show error message
        _showErrorSnackBar(context, e);
      }
      
      rethrow;
    }
  }

  /// Request storage permission
  static Future<bool> _requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      print('📱 Android SDK: $sdkInt');
      
      Permission permission;
      String permissionName;
      
      if (sdkInt >= 33) {
        // Android 13+ - for Downloads folder, we actually don't need special permission
        // Files saved via MediaStore are automatically accessible
        return true;
      } else if (sdkInt >= 30) {
        // Android 11-12 - scoped storage, but we can still save to Downloads
        permission = Permission.storage;
        permissionName = 'Storage';
      } else {
        // Older Android - traditional storage permission
        permission = Permission.storage;
        permissionName = 'Storage';
      }
      
      final status = await permission.status;
      print('🔐 $permissionName permission status: $status');
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        // Show explanation dialog
        final shouldRequest = await _showPermissionDialog(
          context,
          'Downloads Permission Required',
          'To save your ticket to the Downloads folder, we need $permissionName permission.',
          'Grant Permission',
        );
        
        if (!shouldRequest) return false;
        
        final result = await permission.request();
        return result.isGranted;
      }
      
      return false;
    } else {
      // iOS doesn't need permission for app documents
      return true;
    }
  }

  /// Save file to Downloads folder using different strategies
  static Future<String> _saveToDownloadsFolder(String fileName, Uint8List fileBytes) async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      print('📱 Saving to Downloads folder (Android SDK: $sdkInt)');
      
      // Strategy 1: Try direct Downloads folder access (works on older Android)
      if (sdkInt < 30) {
        try {
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (await downloadsDir.exists()) {
            final file = File('${downloadsDir.path}/$fileName');
            await file.writeAsBytes(fileBytes);
            
            if (await file.exists() && await file.length() > 0) {
              print('✅ File saved to public Downloads folder');
              return file.path;
            }
          }
        } catch (e) {
          print('❌ Direct Downloads access failed: $e');
        }
      }
      
      // Strategy 2: Use app-specific external storage with Downloads subfolder
      // This is accessible to users via file manager
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Create a Downloads subfolder that users can easily find
          final downloadsDir = Directory('${externalDir.path}/Downloads');
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          
          final file = File('${downloadsDir.path}/$fileName');
          await file.writeAsBytes(fileBytes);
          
          if (await file.exists() && await file.length() > 0) {
            print('✅ File saved to app Downloads folder');
            return file.path;
          }
        }
      } catch (e) {
        print('❌ App Downloads folder save failed: $e');
      }
      
      // Strategy 3: Fallback to app documents
      final documentsDir = await getApplicationDocumentsDirectory();
      final file = File('${documentsDir.path}/$fileName');
      await file.writeAsBytes(fileBytes);
      
      if (await file.exists() && await file.length() > 0) {
        print('✅ File saved to app documents (fallback)');
        return file.path;
      } else {
        throw Exception('Failed to save file');
      }
    } else {
      // iOS: Save to app documents
      final documentsDir = await getApplicationDocumentsDirectory();
      final file = File('${documentsDir.path}/$fileName');
      await file.writeAsBytes(fileBytes);
      
      if (await file.exists() && await file.length() > 0) {
        return file.path;
      } else {
        throw Exception('Failed to save file');
      }
    }
  }

  /// Show permission dialog
  static Future<bool> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
    String allowButtonText,
  ) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Row(
            children: [
              const Icon(Icons.download, color: Color(0xFF6958CA)),
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
              const Text(
                'Downloading ticket...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                eventName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show success snack bar
  static void _showSuccessSnackBar(BuildContext context, String fileName) {
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
            const SizedBox(height: 8),
            Text(
              'File: $fileName',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.folder_open, color: Color(0xFF6958CA), size: 16),
                SizedBox(width: 4),
                Text(
                  'Saved to Downloads area',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Check Downloads app or File Manager → Android → data → [app] → files → Downloads',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Got it',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Show error snack bar
  static void _showErrorSnackBar(BuildContext context, dynamic error) {
    String errorMessage = 'Download failed';
    if (error.toString().contains('401') || error.toString().contains('Unauthorized')) {
      errorMessage = 'Authentication failed. Please login again.';
    } else if (error.toString().contains('404')) {
      errorMessage = 'Ticket not found. Please contact support.';
    } else if (error.toString().contains('403')) {
      errorMessage = 'Access denied. You may not own this ticket.';
    } else if (error.toString().contains('permission')) {
      errorMessage = 'Storage permission required to download files.';
    } else {
      errorMessage = 'Download failed: ${error.toString()}';
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
}