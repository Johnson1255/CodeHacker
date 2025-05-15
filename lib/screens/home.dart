import 'package:flutter/material.dart';
import 'package:code_hacker/screens/game.dart'; // Import the game screen
import 'package:code_hacker/screens/credits.dart'; // Import the credits screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Hacker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Navigate to the game screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              child: const Text('Start Game'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the credits screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreditsScreen()),
                );
              },
              child: const Text('Credits'),
            ),
          ],
        ),
      ),
    );
  }
}
