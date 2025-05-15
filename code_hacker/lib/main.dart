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
        primarySwatch: Colors.blue,
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
