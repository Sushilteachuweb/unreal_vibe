import 'package:flutter/material.dart';
import 'lib/services/downloads_folder_service.dart';

void main() {
  runApp(const DownloadsFolderTestApp());
}

class DownloadsFolderTestApp extends StatelessWidget {
  const DownloadsFolderTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Downloads Folder Test',
      theme: ThemeData.dark(),
      home: const DownloadsFolderTestScreen(),
    );
  }
}

class DownloadsFolderTestScreen extends StatefulWidget {
  const DownloadsFolderTestScreen({super.key});

  @override
  State<DownloadsFolderTestScreen> createState() => _DownloadsFolderTestScreenState();
}

class _DownloadsFolderTestScreenState extends State<DownloadsFolderTestScreen> {
  bool _isDownloading = false;

  Future<void> _testDownload() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      // Test with real booking ID and event name
      await DownloadsFolderService.downloadTicket(
        bookingId: '6943e795a580b286e57be85e', // Replace with real booking ID
        eventName: 'Bollywood Night',
        context: context,
      );
    } catch (e) {
      // Error is handled in the service
      print('Download test completed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Downloads Folder Test'),
        backgroundColor: const Color(0xFF6958CA),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF6958CA).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.file_download,
                size: 50,
                color: Color(0xFF6958CA),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Test Downloads Folder',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'This will download your ticket to an accessible Downloads location',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isDownloading ? null : _testDownload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6958CA),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: _isDownloading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
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
                        Text('Downloading...'),
                      ],
                    )
                  : const Text(
                      'Test Download',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Download Strategy:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Try public Downloads folder (older Android)\n'
                    '2. Use app Downloads folder (accessible via file manager)\n'
                    '3. Fallback to app documents',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}