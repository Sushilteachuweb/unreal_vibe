import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

// Mock classes for testing
class UserStorage {
  static Future<String?> getToken() async {
    // Replace with your actual token - get this from your app's login
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NzQzZTc5NWE1ODBiMjg2ZTU3YmU4NWUiLCJpYXQiOjE3MzQ2MjI4NzIsImV4cCI6MTczNzIxNDg3Mn0.example"; // Update this with real token
  }
  
  static Future<bool> getLoginStatus() async {
    return true;
  }
}

class ApiConfig {
  static const String baseUrl = "https://api.unrealvibe.com/api";
  static String downloadTicket(String bookingId) => "$baseUrl/passes/my-passes/download/$bookingId";
  
  static Map<String, String> getAuthHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/pdf',
      'Content-Type': 'application/json',
    };
  }
}

void main() {
  runApp(const DebugDownloadApp());
}

class DebugDownloadApp extends StatelessWidget {
  const DebugDownloadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debug Download',
      theme: ThemeData.dark(),
      home: const DebugDownloadScreen(),
    );
  }
}

class DebugDownloadScreen extends StatefulWidget {
  const DebugDownloadScreen({super.key});

  @override
  State<DebugDownloadScreen> createState() => _DebugDownloadScreenState();
}

class _DebugDownloadScreenState extends State<DebugDownloadScreen> {
  String _log = '';
  bool _isDownloading = false;

  void _addLog(String message) {
    setState(() {
      _log += '${DateTime.now().toString().substring(11, 19)}: $message\n';
    });
    print(message);
  }

  Future<void> _debugDownload() async {
    setState(() {
      _isDownloading = true;
      _log = '';
    });

    try {
      // Use a real booking ID - replace this with an actual one from your API
      const String bookingId = "6943e795a580b286e57be85e";
      const String eventName = "Test Event";
      
      _addLog('🔍 Starting debug download...');
      _addLog('📋 Booking ID: $bookingId');
      _addLog('🎫 Event Name: $eventName');

      // Step 1: Check permissions
      _addLog('\n📱 Checking device info and permissions...');
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        _addLog('📱 Android SDK: $sdkInt');
        
        final storageStatus = await Permission.storage.status;
        _addLog('🔐 Storage permission: $storageStatus');
      }

      // Step 2: Get file path
      _addLog('\n📁 Determining save path...');
      final fileName = 'ticket_${eventName.replaceAll(' ', '_')}_$bookingId.pdf';
      final savePath = await _getSavePath(fileName);
      _addLog('💾 Save path: $savePath');

      // Step 3: Check authentication
      _addLog('\n🔐 Checking authentication...');
      final token = await UserStorage.getToken();
      if (token == null) {
        _addLog('❌ No auth token found');
        return;
      }
      _addLog('✅ Auth token found: ${token.substring(0, 20)}...');

      // Step 4: Make API request
      _addLog('\n🌐 Making API request...');
      final endpoint = ApiConfig.downloadTicket(bookingId);
      _addLog('📍 Endpoint: $endpoint');

      final response = await http.get(
        Uri.parse(endpoint),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(const Duration(seconds: 30));

      _addLog('📊 Response status: ${response.statusCode}');
      _addLog('📊 Response headers: ${response.headers}');
      _addLog('📊 Content-Type: ${response.headers['content-type']}');
      _addLog('📊 Content-Length: ${response.headers['content-length']}');
      _addLog('📊 Body size: ${response.bodyBytes.length} bytes');

      if (response.statusCode == 200) {
        _addLog('✅ API request successful');
        
        // Check if it's actually a PDF
        if (response.bodyBytes.length > 4) {
          final pdfHeader = String.fromCharCodes(response.bodyBytes.take(4));
          _addLog('📄 File header: $pdfHeader');
          
          if (pdfHeader == '%PDF') {
            _addLog('✅ Valid PDF file detected');
          } else {
            _addLog('⚠️ File may not be a valid PDF');
            // Show first 200 characters of response
            final responseText = String.fromCharCodes(response.bodyBytes.take(200));
            _addLog('📄 Response preview: $responseText');
          }
        }

        // Step 5: Save file
        _addLog('\n💾 Saving file...');
        try {
          final file = File(savePath);
          
          // Ensure directory exists
          final directory = file.parent;
          if (!await directory.exists()) {
            _addLog('📁 Creating directory: ${directory.path}');
            await directory.create(recursive: true);
          }
          
          // Write file
          await file.writeAsBytes(response.bodyBytes);
          _addLog('✅ File written to disk');
          
          // Verify file exists and has content
          if (await file.exists()) {
            final fileSize = await file.length();
            _addLog('✅ File exists on disk, size: $fileSize bytes');
            
            if (fileSize > 0) {
              _addLog('🎉 SUCCESS: File downloaded and saved successfully!');
              _addLog('📁 Location: $savePath');
            } else {
              _addLog('❌ File exists but is empty');
            }
          } else {
            _addLog('❌ File was not created on disk');
          }
          
        } catch (e) {
          _addLog('❌ Error saving file: $e');
          _addLog('❌ Error type: ${e.runtimeType}');
        }
        
      } else {
        _addLog('❌ API request failed');
        _addLog('📄 Response body: ${response.body}');
      }

    } catch (e) {
      _addLog('❌ Download error: $e');
      _addLog('❌ Error type: ${e.runtimeType}');
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<String> _getSavePath(String fileName) async {
    Directory directory;
    
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      _addLog('📱 Android SDK: $sdkInt');
      
      // Try external storage first
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final downloadsDir = Directory('${externalDir.path}/Downloads');
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          directory = downloadsDir;
          _addLog('📁 Using external storage: ${directory.path}');
        } else {
          directory = await getApplicationDocumentsDirectory();
          _addLog('📁 Using app documents: ${directory.path}');
        }
      } catch (e) {
        _addLog('❌ External storage error: $e');
        directory = await getApplicationDocumentsDirectory();
        _addLog('📁 Fallback to documents: ${directory.path}');
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
      _addLog('📁 Using documents directory: ${directory.path}');
    }

    return '${directory.path}/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Debug Download'),
        backgroundColor: const Color(0xFF6958CA),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isDownloading ? null : _debugDownload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6958CA),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isDownloading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Debugging...'),
                      ],
                    )
                  : const Text(
                      'Debug Download Process',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _log.isEmpty ? 'Tap the button to start debugging...' : _log,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}