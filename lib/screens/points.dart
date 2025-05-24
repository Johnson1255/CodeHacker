import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code_hacker/widgets/custom_button.dart';
import 'package:code_hacker/widgets/score_card.dart';
import 'package:code_hacker/models/score_model.dart';
import 'dart:convert';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> with SingleTickerProviderStateMixin {
  int _highScore = 0;
  int _maxCycle = 0;
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  bool _isNewHighScore = false;
  bool _isNewMaxCycle = false;

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
    final score = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {'score': 0, 'cycle': 1};
    
    final oldHighScore = prefs.getInt('highscore') ?? 0;
    final oldMaxCycle = prefs.getInt('maxcycle') ?? 0;
    
    final int currentScore = score['score'] as int;
    final int currentCycle = score['cycle'] as int;
    
    setState(() {
      _highScore = prefs.getInt('highscore') ?? 0;
      _maxCycle = prefs.getInt('maxcycle') ?? 0;
      _isNewHighScore = currentScore > oldHighScore;
      _isNewMaxCycle = currentCycle > oldMaxCycle;
    });

    // Actualizar récords si es necesario
    if (currentScore > oldHighScore) {
      await prefs.setInt('highscore', currentScore);
    }
    
    if (currentCycle > oldMaxCycle) {
      await prefs.setInt('maxcycle', currentCycle);
    }

    // Guardar la puntuación actual con fecha, nivel y ciclo
    if (currentScore > 0) {
      final newScore = Score(
        points: currentScore,
        level: score['level'] as int,
        cycle: currentCycle,
        timestamp: DateTime.now(),
      );
      
      // Guardar historial de puntuaciones (últimas 10)
      List<Score> scores = [];
      final scoresJson = prefs.getStringList('scores_history') ?? [];
      
      // Convertir las puntuaciones guardadas a objetos Score
      if (scoresJson.isNotEmpty) {
        scores = scoresJson.map((scoreStr) => 
          Score.fromJson(jsonDecode(scoreStr) as Map<String, dynamic>)
        ).toList();
      }
      
      // Añadir la nueva puntuación
      scores.add(newScore);
      
      // Ordenar por puntuación (mayor primero)
      scores.sort((a, b) => b.points.compareTo(a.points));
      
      // Mantener solo las 10 mejores
      if (scores.length > 10) {
        scores = scores.sublist(0, 10);
      }
      
      // Guardar como JSON
      final updatedScoresJson = scores.map((score) => 
        jsonEncode(score.toJson())
      ).toList();
      
      await prefs.setStringList('scores_history', updatedScoresJson);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scoreData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? 
      {'score': 0, 'cycle': 1, 'level': 1};
    
    final score = scoreData['score'] as int;
    final cycle = scoreData['cycle'] as int;

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
                    _isNewHighScore || _isNewMaxCycle ? '¡NUEVO RÉCORD!' : 'PUNTUACIÓN FINAL',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isNewHighScore || _isNewMaxCycle ? Colors.cyanAccent : Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const Spacer(flex: 1),
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
                  label: 'Récord de Puntos',
                  isHighScore: _isNewHighScore,
                  icon: Icons.emoji_events,
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isNewMaxCycle ? Colors.blueGrey.shade900 : Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isNewMaxCycle ? Colors.cyanAccent : Colors.blueGrey,
                      width: 2,
                    ),
                    boxShadow: _isNewMaxCycle
                        ? [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.loop,
                        color: _isNewMaxCycle ? Colors.cyanAccent : Colors.white70,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CICLO ALCANZADO',
                              style: TextStyle(
                                color: _isNewMaxCycle ? Colors.cyanAccent : Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  cycle.toString(),
                                  style: TextStyle(
                                    color: _isNewMaxCycle ? Colors.cyanAccent : Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (cycle > 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'DIFICULTAD x$cycle',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                          border: Border.all(
                            color: _isNewMaxCycle ? Colors.cyanAccent : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'MAX\n$_maxCycle',
                          style: TextStyle(
                            color: _isNewMaxCycle ? Colors.cyanAccent : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
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
