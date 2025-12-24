import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'user_storage.dart';
import 'api_routes.dart';

class MainDownloadsService {
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

      print('📥 Starting download to main Downloads folder...');
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

        // Save file to main Downloads folder
        final savedPath = await _saveToMainDownloads(fileName, fileBytes);
        
        print('✅ Download completed successfully');
        print('📁 File saved to main Downloads: $savedPath');
        
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

  /// Request storage permission with user-friendly dialog
  static Future<bool> _requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      print('📱 Android SDK: $sdkInt');
      
      Permission permission;
      String permissionName;
      
      if (sdkInt >= 33) {
        // Android 13+ uses granular media permissions
        permission = Permission.photos;
        permissionName = 'Media';
      } else {
        // Older versions use storage permission
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
          'To save your ticket to the Downloads folder, we need $permissionName permission. This allows you to easily find your tickets in the Downloads app.',
          'Grant Permission',
        );
        
        if (!shouldRequest) return false;
        
        final result = await permission.request();
        if (result.isGranted) {
          return true;
        } else if (result.isPermanentlyDenied) {
          await _showSettingsDialog(context);
          return false;
        }
      } else if (status.isPermanentlyDenied) {
        await _showSettingsDialog(context);
        return false;
      }
      
      return false;
    } else {
      // iOS doesn't need permission for app documents
      return true;
    }
  }

  /// Save file to main Downloads folder using flutter_file_dialog
  static Future<String> _saveToMainDownloads(String fileName, Uint8List fileBytes) async {
    try {
      if (Platform.isAndroid) {
        print('📁 Saving to main Downloads folder via MediaStore...');
        
        // Create a temporary file first
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(fileBytes);
        
        // Use flutter_file_dialog to save to Downloads
        final params = SaveFileDialogParams(
          sourceFilePath: tempFile.path,
          fileName: fileName,
          mimeTypesFilter: ['application/pdf'],
        );
        
        final filePath = await FlutterFileDialog.saveFile(params: params);
        
        // Clean up temp file
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        
        if (filePath != null) {
          print('✅ File saved to Downloads via MediaStore');
          return 'Downloads/$fileName';
        } else {
          throw Exception('Failed to save to Downloads folder');
        }
      } else {
        // For iOS, save to app documents
        final documentsDir = await getApplicationDocumentsDirectory();
        final file = File('${documentsDir.path}/$fileName');
        await file.writeAsBytes(fileBytes);
        
        if (await file.exists() && await file.length() > 0) {
          return file.path;
        } else {
          throw Exception('Failed to save file');
        }
      }
    } catch (e) {
      print('❌ Main Downloads save failed: $e');
      rethrow;
    }
  }

  /// Show permission explanation dialog
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
            'To download tickets to your Downloads folder, please enable storage permission in app settings.',
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
                'Downloading ticket to Downloads folder...',
                style: const TextStyle(
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
                Icon(Icons.folder, color: Color(0xFF6958CA), size: 16),
                SizedBox(width: 4),
                Text(
                  'Saved to Downloads folder',
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
              'Check your Downloads app or file manager',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'Great!',
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
      errorMessage = 'Storage permission required to download to Downloads folder.';
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