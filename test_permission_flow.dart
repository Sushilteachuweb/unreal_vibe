import 'package:flutter/material.dart';
import 'lib/services/download_service.dart';

void main() {
  runApp(const PermissionTestApp());
}

class PermissionTestApp extends StatelessWidget {
  const PermissionTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Download Permission Test',
      theme: ThemeData.dark(),
      home: const PermissionTestScreen(),
    );
  }
}

class PermissionTestScreen extends StatefulWidget {
  const PermissionTestScreen({super.key});

  @override
  State<PermissionTestScreen> createState() => _PermissionTestScreenState();
}

class _PermissionTestScreenState extends State<PermissionTestScreen> {
  bool _isDownloading = false;

  Future<void> _testDownload() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      // Test the download service with a mock booking
      await DownloadService.downloadTicket(
        bookingId: 'test_booking_123',
        eventName: 'Test Event',
        context: context,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download test failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        title: const Text('Download Permission Test'),
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
              'Test Download Permission Flow',
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
                'This will test the permission request flow for downloading tickets',
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
                        Text('Testing...'),
                      ],
                    )
                  : const Text(
                      'Test Download Permission',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}