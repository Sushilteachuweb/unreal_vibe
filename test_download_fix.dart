import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await testDownloadPath();
}

Future<void> testDownloadPath() async {
  print('🔍 Testing Download Path Resolution...');
  
  if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    
    print('📱 Android SDK version: $sdkInt');
    print('📱 Android version: ${androidInfo.version.release}');
    print('📱 Device model: ${androidInfo.model}');
    
    // Test path resolution logic
    Directory directory;
    
    if (sdkInt >= 29) {
      print('📁 Using Android 10+ scoped storage approach...');
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final downloadsDir = Directory('${externalDir.path}/Downloads');
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
            print('✅ Created Downloads directory: ${downloadsDir.path}');
          }
          directory = downloadsDir;
          print('📁 Using app external storage: ${directory.path}');
        } else {
          directory = await getApplicationDocumentsDirectory();
          print('📁 Fallback to app documents: ${directory.path}');
        }
      } catch (e) {
        print('❌ Error accessing external storage: $e');
        directory = await getApplicationDocumentsDirectory();
        print('📁 Using app documents directory: ${directory.path}');
      }
    } else {
      print('📁 Using legacy Android approach...');
      try {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getApplicationDocumentsDirectory();
        }
        print('📁 Using Downloads directory: ${directory.path}');
      } catch (e) {
        print('❌ Error accessing Downloads directory: $e');
        directory = await getApplicationDocumentsDirectory();
        print('📁 Fallback to app documents: ${directory.path}');
      }
    }
    
    // Test file creation
    final testFileName = 'test_ticket_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final testFilePath = '${directory.path}/$testFileName';
    
    try {
      final testFile = File(testFilePath);
      await testFile.writeAsString('Test PDF content');
      print('✅ Successfully created test file: $testFilePath');
      
      // Check if file exists
      if (await testFile.exists()) {
        print('✅ Test file exists and is accessible');
        
        // Clean up test file
        await testFile.delete();
        print('🧹 Cleaned up test file');
      } else {
        print('❌ Test file was created but is not accessible');
      }
    } catch (e) {
      print('❌ Failed to create test file: $e');
      print('❌ Error type: ${e.runtimeType}');
    }
    
  } else {
    print('📱 Non-Android platform detected');
    final directory = await getApplicationDocumentsDirectory();
    print('📁 Using documents directory: ${directory.path}');
  }
  
  print('\n🎯 Test completed!');
}