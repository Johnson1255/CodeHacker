class Score {
  final int points;
  final int level;
  final int cycle;
  final DateTime timestamp;
  final bool isNightmare;

  Score({
    required this.points,
    required this.level,
    required this.cycle,
    required this.timestamp,
    this.isNightmare = false,
  });

  Score.fromJson(Map<String, dynamic> json)
      : points = json['points'] as int,
        level = json['level'] as int,
        cycle = json['cycle'] as int,
        timestamp = DateTime.parse(json['timestamp'] as String),
        isNightmare = json['isNightmare'] as bool? ?? false;

  Map<String, dynamic> toJson() => {
        'points': points,
        'level': level,
        'cycle': cycle,
        'timestamp': timestamp.toIso8601String(),
        'isNightmare': isNightmare,
      };

  @override
  String toString() {
    return 'Score(points: $points, level: $level, cycle: $cycle, timestamp: $timestamp, isNightmare: $isNightmare)';
  }
} 