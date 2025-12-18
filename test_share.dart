import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ShareTestScreen(),
    );
  }
}

class ShareTestScreen extends StatelessWidget {
  Future<void> _testShare() async {
    try {
      print('Testing share functionality...');
      
      String shareText = '''
🎉 Test Event
📅 Date: December 17, 2025
📍 Location: Test Location
🎫 Tickets: ₹100

Download Unreal Vibe app to book your tickets!
🔗 https://unrealvibe.com
      '''.trim();
      
      print('Share text: $shareText');
      
      await Share.share(
        shareText,
        subject: 'Test Event Share',
      );
      
      print('Share completed successfully');
      
    } catch (e) {
      print('Error sharing: $e');
      print('Error type: ${e.runtimeType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _testShare,
          child: Text('Test Share'),
        ),
      ),
    );
  }
}