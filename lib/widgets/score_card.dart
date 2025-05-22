import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final int score;
  final String label;
  final bool isHighScore;
  final IconData? icon;

  const ScoreCard({
    super.key,
    required this.score,
    required this.label,
    this.isHighScore = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isHighScore ? Colors.blueGrey.shade900 : Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighScore ? Colors.cyanAccent : Colors.blueGrey,
          width: 2,
        ),
        boxShadow: isHighScore
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
          if (icon != null) ...[
            Icon(
              icon,
              color: isHighScore ? Colors.cyanAccent : Colors.white70,
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: isHighScore ? Colors.cyanAccent : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score.toString(),
                  style: TextStyle(
                    color: isHighScore ? Colors.cyanAccent : Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isHighScore)
            const Icon(
              Icons.star,
              color: Colors.cyanAccent,
              size: 24,
            ),
        ],
      ),
    );
  }
} 