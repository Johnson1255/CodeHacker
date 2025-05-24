class Score {
  final int points;
  final int level;
  final int cycle;
  final DateTime timestamp;

  Score({
    required this.points,
    required this.level,
    required this.cycle,
    required this.timestamp,
  });

  Score.fromJson(Map<String, dynamic> json)
      : points = json['points'] as int,
        level = json['level'] as int,
        cycle = json['cycle'] as int,
        timestamp = DateTime.parse(json['timestamp'] as String);

  Map<String, dynamic> toJson() => {
        'points': points,
        'level': level,
        'cycle': cycle,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() {
    return 'Score(points: $points, level: $level, cycle: $cycle, timestamp: $timestamp)';
  }
} 