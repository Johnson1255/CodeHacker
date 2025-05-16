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
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
            ),
            SizedBox(height: 20),
            Text('Developed by: Senlin', style: const TextStyle(color: Colors.white70)),
            Text('Made by a solo dev, with 5 other finals. Still delivered', style: const TextStyle(color: Colors.white70)),
            SizedBox(height: 40),
            const Text('Special Thanks To:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Text('- Flutter Team', style: const TextStyle(color: Colors.white70)),
            Text('- Open Source Community', style: const TextStyle(color: Colors.white70)),
            Text('Sound Effects:'),
            Text('Sound Effect by Hanifi Şahin from Pixabay'),
            Text('Sound Effect by Universfield from Pixabay'),
            Text('Sound Effect by u_8g40a9z0la from Pixabay'),
          ],
        ),
      ),
    );
  }
}
