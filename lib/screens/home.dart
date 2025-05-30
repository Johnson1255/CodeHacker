import 'package:flutter/material.dart';
import 'package:code_hacker/widgets/custom_button.dart';
import 'package:code_hacker/services/audio_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isMuted = false;

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        AudioService().pauseBackgroundMusic();
      } else {
        AudioService().resumeBackgroundMusic();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.blueGrey.shade900],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.cyanAccent,
                    ),
                    onPressed: _toggleMute,
                  ),
                ),
                const Spacer(),
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.security,
                        color: Colors.cyanAccent,
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'CODE HACKER',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'BREAK THE FIREWALL',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.cyanAccent.withOpacity(0.7),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                HackerButton(
                  text: 'INICIAR MISIÓN',
                  icon: Icons.play_arrow,
                  onPressed: () {
                    Navigator.pushNamed(context, '/game');
                  },
                ),
                const SizedBox(height: 15),
                HackerButton(
                  text: 'CRÉDITOS',
                  icon: Icons.info_outline,
                  isOutlined: true,
                  onPressed: () {
                    Navigator.pushNamed(context, '/credits');
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
