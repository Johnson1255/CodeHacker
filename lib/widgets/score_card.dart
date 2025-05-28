import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final int score;
  final String label;
  final bool isHighScore;
  final IconData? icon;
  final Color color;

  const ScoreCard({
    super.key,
    required this.score,
    required this.label,
    this.isHighScore = false,
    this.icon,
    this.color = Colors.cyanAccent,
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
          color: isHighScore ? color : Colors.blueGrey,
          width: 2,
        ),
        boxShadow: isHighScore
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
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
              color: isHighScore ? color : Colors.white70,
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
                    color: isHighScore ? color : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score.toString(),
                  style: TextStyle(
                    color: isHighScore ? color : Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isHighScore)
            Icon(
              Icons.star,
              color: color,
              size: 24,
            ),
        ],
      ),
    );
  }
} 