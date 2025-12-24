import 'package:flutter/material.dart';
import 'lib/utils/error_handler.dart';

void main() {
  runApp(const EmptyTicketsTestApp());
}

class EmptyTicketsTestApp extends StatelessWidget {
  const EmptyTicketsTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Empty Tickets Test',
      theme: ThemeData.dark(),
      home: const EmptyTicketsTestScreen(),
      routes: {
        '/main': (context) => const MainScreenMock(),
      },
    );
  }
}

class EmptyTicketsTestScreen extends StatelessWidget {
  const EmptyTicketsTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: const Text(
          'Your Passes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ErrorHandler.buildEmptyState(
        context: 'tickets',
        navigatorContext: context,
        onRetry: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Refresh button tapped!'),
              backgroundColor: Color(0xFF6958CA),
            ),
          );
        },
      ),
    );
  }
}

class MainScreenMock extends StatelessWidget {
  const MainScreenMock({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6958CA),
        title: const Text('Home Screen'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 80,
              color: Color(0xFF6958CA),
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Home!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Browse Events navigation worked!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}