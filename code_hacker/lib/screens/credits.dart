import 'package:flutter/material.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credits'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Code Hacker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Developed by: [Your Name]'),
            Text('Inspired by: [Professor\'s Name - Optional Vengeance]'),
            SizedBox(height: 40),
            Text('Special Thanks To:'),
            Text('- Flutter Team'),
            Text('- Open Source Community'),
          ],
        ),
      ),
    );
  }
}
