import 'package:flutter/material.dart';
import 'lib/services/main_downloads_service.dart';

void main() {
  runApp(const MainDownloadsTestApp());
}

class MainDownloadsTestApp extends StatelessWidget {
  const MainDownloadsTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Downloads Test',
      theme: ThemeData.dark(),
      home: const MainDownloadsTestScreen(),
    );
  }
}

class MainDownloadsTestScreen extends StatefulWidget {
  const MainDownloadsTestScreen({super.key});

  @override
  State<MainDownloadsTestScreen> createState() => _MainDownloadsTestScreenState();
}

class _MainDownloadsTestScreenState extends State<MainDownloadsTestScreen> {
  bool _isDownloading = false;

  Future<void> _testMainDownload() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      // Test with real booking ID and event name
      await MainDownloadsService.downloadTicket(
        bookingId: '6943e795a580b286e57be85e', // Replace with real booking ID
        eventName: 'Bollywood Night',
        context: context,
      );
    } catch (e) {
      // Error is handled in the service
      print('Download test completed with error: $e');
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
        title: const Text('Main Downloads Test'),
        backgroundColor: const Color(0xFF6958CA),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF6958CA).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.download_for_offline,
                size: 60,
                color: Color(0xFF6958CA),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Download to Main Downloads Folder',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'This will download your ticket directly to the main Downloads folder where you can easily find it in the Downloads app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isDownloading ? null : _testMainDownload,
              icon: _isDownloading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download, size: 24),
              label: Text(
                _isDownloading ? 'Downloading...' : 'Download to Downloads Folder',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6958CA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6958CA).withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF6958CA), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'How it works:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. App requests storage permission\n'
                    '2. Downloads ticket from API\n'
                    '3. Saves directly to Downloads folder\n'
                    '4. File appears in Downloads app',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Note: Update the booking ID and token in the service with real values for testing',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}