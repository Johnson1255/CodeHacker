import 'package:flutter/material.dart';
import 'package:code_hacker/screens/splash.dart';
import 'package:code_hacker/screens/home.dart';
import 'package:code_hacker/screens/game.dart';
import 'package:code_hacker/screens/points.dart';
import 'package:code_hacker/screens/credits.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Hacker',
      theme: ThemeData(
        brightness: Brightness.dark, // Enable dark mode
        primarySwatch: Colors.blueGrey, // A more neutral/techy color
        hintColor: Colors.cyanAccent, // Accent color
        scaffoldBackgroundColor: Colors.black, // Dark background
        cardColor: Colors.blueGrey[800], // Darker card color
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70), // Default text color
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // AppBar title color
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.cyanAccent, // Button color
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Colors.cyanAccent, // Button text and background color
          ),
        ),
        // You can add more theme customizations here
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/game': (context) => const GameScreen(),
        '/points': (context) => const PointsScreen(),
        '/credits': (context) => const CreditsScreen(),
      },
    );
  }
}
