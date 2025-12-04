import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/splash_screen.dart';
import 'providers/user_provider.dart';
import 'navigation/main_navigation.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unreal Vibe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6958CA),
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/main': (context) {
          final int? initialIndex = ModalRoute.of(context)?.settings.arguments as int?;
          return MainNavigation(initialIndex: initialIndex ?? 0);
        },
      },
    );
  }
}
