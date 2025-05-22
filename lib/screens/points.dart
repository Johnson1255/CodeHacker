import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code_hacker/widgets/custom_button.dart';
import 'package:code_hacker/widgets/score_card.dart';
import 'package:code_hacker/models/score_model.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> with SingleTickerProviderStateMixin {
  int _highScore = 0;
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  bool _isNewHighScore = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _loadHighScore();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final score = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
    final oldHighScore = prefs.getInt('highscore') ?? 0;
    
    setState(() {
      _highScore = prefs.getInt('highscore') ?? 0;
      _isNewHighScore = score > oldHighScore;
    });

    // Guardar la puntuación actual con fecha y nivel
    if (score > 0) {
      final newScore = Score(
        points: score,
        level: 3, // Asumimos que completó todos los niveles
        timestamp: DateTime.now(),
      );
      
      final scores = prefs.getStringList('scores') ?? [];
      scores.add(newScore.toString());
      await prefs.setStringList('scores', scores);
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = ModalRoute.of(context)?.settings.arguments as int? ?? 0;

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
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'MISIÓN COMPLETADA',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    _isNewHighScore ? '¡NUEVO RÉCORD!' : 'PUNTUACIÓN FINAL',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isNewHighScore ? Colors.cyanAccent : Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const Spacer(),
                ScaleTransition(
                  scale: _scoreAnimation,
                  child: ScoreCard(
                    score: score,
                    label: 'Tu Puntuación',
                    icon: Icons.security,
                  ),
                ),
                const SizedBox(height: 20),
                ScoreCard(
                  score: _highScore,
                  label: 'Récord',
                  isHighScore: true,
                  icon: Icons.emoji_events,
                ),
                const Spacer(),
                HackerButton(
                  text: 'VOLVER A JUGAR',
                  icon: Icons.replay,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/game');
                  },
                ),
                const SizedBox(height: 15),
                HackerButton(
                  text: 'MENÚ PRINCIPAL',
                  icon: Icons.home,
                  isOutlined: true,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
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
