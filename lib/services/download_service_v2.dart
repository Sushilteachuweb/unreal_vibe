import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'user_storage.dart';
import 'api_routes.dart';

class DownloadServiceV2 {
  static final Dio _dio = Dio();

  /// Download ticket PDF and save to device Downloads folder
  static Future<String> downloadTicket({
    required String bookingId,
    required String eventName,
    required BuildContext context,
  }) async {
    try {
      // Get auth token
      final token = await UserStorage.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      // Prepare download
      final endpoint = ApiConfig.downloadTicket(bookingId);
      final fileName = 'ticket_${eventName.replaceAll(' ', '_')}_$bookingId.pdf';

      print('📥 Starting download...');
      print('📍 Endpoint: $endpoint');
      print('📄 File name: $fileName');

      // Show download progress
      if (context.mounted) {
        _showDownloadDialog(context, eventName);
      }

      // Get authentication headers with cookies
      final authHeaders = await ApiConfig.getAuthHeadersWithCookies(token);
      
      // Download file data
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            ...authHeaders,
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

        // Save file to Downloads
        final savedPath = await _saveToDownloads(fileName, fileBytes);
        
        print('✅ Download completed successfully');
        print('📁 File saved to: $savedPath');
        
        // Show success message
        if (context.mounted) {
          _showSuccessSnackBar(context, fileName, savedPath);
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

  /// Save file to accessible location with proper permissions handling
  static Future<String> _saveToDownloads(String fileName, Uint8List fileBytes) async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      print('📱 Android SDK: $sdkInt');
      
      // Check storage permission
      bool hasStoragePermission = false;
      if (sdkInt >= 33) {
        // Android 13+ uses granular permissions
        hasStoragePermission = await Permission.photos.isGranted;
      } else {
        // Older versions use storage permission
        hasStoragePermission = await Permission.storage.isGranted;
      }
      
      print('🔐 Storage permission: $hasStoragePermission');
      
      // Try to save to public Downloads if we have permission and it's supported
      if (hasStoragePermission && sdkInt < 30) {
        try {
          print('📁 Attempting to save to public Downloads folder');
          
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
          print('❌ Public Downloads save failed: $e');
        }
      }
      
      // For Android 10+ or when public Downloads fails, use app-specific storage
      // This is the most reliable approach for modern Android
      return await _saveToAppStorage(fileName, fileBytes);
    } else {
      // For iOS and other platforms, use app documents
      return await _saveToAppStorage(fileName, fileBytes);
    }
  }

  /// Fallback: Save to app-specific storage
  static Future<String> _saveToAppStorage(String fileName, Uint8List fileBytes) async {
    try {
      print('📁 Saving to app storage as fallback');
      
      final externalDir = await getExternalStorageDirectory();
      Directory directory;
      
      if (externalDir != null) {
        // Create Downloads subfolder in app external storage
        directory = Directory('${externalDir.path}/Downloads');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      } else {
        // Final fallback to app documents
        directory = await getApplicationDocumentsDirectory();
      }
      
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(fileBytes);
      
      if (await file.exists() && await file.length() > 0) {
        print('✅ File saved to app storage: ${file.path}');
        return file.path;
      } else {
        throw Exception('Failed to save file to app storage');
      }
    } catch (e) {
      print('❌ App storage save failed: $e');
      rethrow;
    }
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

  /// Show success snack bar with clear file location info
  static void _showSuccessSnackBar(BuildContext context, String fileName, String filePath) {
    final isInPublicDownloads = filePath.contains('/storage/emulated/0/Download');
    final isInAppStorage = filePath.contains('/Android/data/');
    
    String locationMessage;
    String pathInfo;
    
    if (isInPublicDownloads) {
      locationMessage = '📁 Saved to Downloads folder';
      pathInfo = 'Check your Downloads app or file manager';
    } else if (isInAppStorage) {
      locationMessage = '📁 Saved to app storage (accessible via file manager)';
      pathInfo = 'Android → data → [your app] → files → Downloads';
    } else {
      locationMessage = '📁 Saved to device storage';
      pathInfo = 'File is accessible via file manager';
    }
    
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
            Text(
              locationMessage,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pathInfo,
              style: const TextStyle(
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