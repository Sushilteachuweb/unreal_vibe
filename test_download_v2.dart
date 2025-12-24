import 'package:flutter/material.dart';
import 'lib/services/download_service_v2.dart';

void main() {
  runApp(const DownloadV2TestApp());
}

class DownloadV2TestApp extends StatelessWidget {
  const DownloadV2TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Download V2 Test',
      theme: ThemeData.dark(),
      home: const DownloadV2TestScreen(),
    );
  }
}

class DownloadV2TestScreen extends StatefulWidget {
  const DownloadV2TestScreen({super.key});

  @override
  State<DownloadV2TestScreen> createState() => _DownloadV2TestScreenState();
}

class _DownloadV2TestScreenState extends State<DownloadV2TestScreen> {
  bool _isDownloading = false;

  Future<void> _testDownload() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      // Test with real booking ID and event name
      await DownloadServiceV2.downloadTicket(
        bookingId: '6943e795a580b286e57be85e', // Replace with real booking ID
        eventName: 'Test Event',
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
        title: const Text('Download V2 Test'),
        backgroundColor: const Color(0xFF6958CA),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.download,
              size: 80,
              color: Color(0xFF6958CA),
            ),
            const SizedBox(height: 20),
            const Text(
              'Test New Download Service',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'This will test the improved download service that saves files to the Downloads folder using MediaStore API',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isDownloading ? null : _testDownload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6958CA),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
                      'Test Download to Downloads Folder',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Note: Update the booking ID and token in the service files with real values for testing',
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