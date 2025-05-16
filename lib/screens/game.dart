import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentLevel = 1;
  int _score = 0;
  int _timeLeft = 10; // Timer for the mini-game
  double _progress = 0.0; // Progress for the tap game
  int _tapsNeeded = 10; // Number of taps needed for the first level
  int _tapsMade = 0;
  Timer? _timer;

  // Code Sequence Mini-game variables
  List<Color> _sequence = [];
  List<Color> _userInput = [];
  bool _isDisplayingSequence = false;
  Color? _highlightedColor;
  Color? _tappedColor; // New variable to store the tapped color
  final List<Color> _availableColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ];
  int _sequenceLength = 3; // Initial sequence length

  // Decrypt Code Mini-game variables
  String _question = '';
  int _answer = 0;
  final TextEditingController _answerController = TextEditingController();

  // Shared Preferences for score
  Future<void> _saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final highscore = prefs.getInt('highscore') ?? 0;
    if (score > highscore) {
      await prefs.setInt('highscore', score);
    }
  }

  // Function to play sound
  Future<void> _playSound(String soundAsset) async {
    final player = AudioPlayer();
    await player.play(AssetSource(soundAsset));
  }

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  void _startLevel() {
    _timer?.cancel(); // Cancel any existing timer
    _timeLeft = 10; // Reset timer for the level
    if (_currentLevel == 1) {
      _startFirewallBreak();
    } else if (_currentLevel == 2) {
      _startCodeSequence();
    } else if (_currentLevel == 3) {
      _startDecryptCode();
    }
    _startLevelTimer(); // Start the timer for the current level
  }

  // Firewall Break Logic
  void _startFirewallBreak() {
    _progress = 0.0;
    _tapsMade = 0;
    _tapsNeeded = 10 + (_currentLevel - 1) * 5; // Increase taps needed per level
  }

  void _handleTap() {
    _playSound('sounds/button_click.mp3');
    if (_timeLeft > 0) {
      setState(() {
        _tapsMade++;
        _progress = _tapsMade / _tapsNeeded;
      });
      if (_tapsMade >= _tapsNeeded) {
        _timer?.cancel();
        _endLevel(true); // Level completed
      }
    }
  }

  // Code Sequence Logic
  void _startCodeSequence() {
    _sequenceLength = 3 + (_currentLevel - 2); // Increase sequence length per level
    _sequence = _generateSequence(_sequenceLength);
    _userInput = [];
    _isDisplayingSequence = true;
    _displaySequence();
  }

  List<Color> _generateSequence(int length) {
    final random = Random();
    return List.generate(length, (_) => _availableColors[random.nextInt(_availableColors.length)]);
  }

  Future<void> _displaySequence() async {
    for (var color in _sequence) {
      _highlightedColor = color;
      setState(() {}); // Trigger rebuild to show the highlighted color
      await Future.delayed(const Duration(milliseconds: 500)); // Delay between color highlights
      _highlightedColor = null;
      setState(() {}); // Trigger rebuild to remove the highlight
      await Future.delayed(const Duration(milliseconds: 200)); // Short delay before the next color
    }
      await Future.delayed(const Duration(seconds: 1)); // Delay after sequence is displayed
      _timer?.cancel(); // Cancel the timer
      setState(() {
        _isDisplayingSequence = false;
      });
      await Future.delayed(const Duration(milliseconds: 500)); // Reduced delay
      _startLevelTimer(); // Start timer for user input
    }

  void _handleColorTap(Color color) {
    _playSound('sounds/button_click.mp3');
    if (!_isDisplayingSequence && _timeLeft > 0) {
      setState(() {
        _tappedColor = color; // Set the tapped color
        _userInput.add(color);
      });
      // Briefly highlight the tapped color
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _tappedColor = null; // Reset the tapped color
        });
      });
      if (_userInput.length == _sequence.length) {
        _timer?.cancel();
        _checkSequence();
      }
    }
  }

  void _checkSequence() {
    bool matches = true;
    for (int i = 0; i < _sequence.length; i++) {
      if (_userInput[i] != _sequence[i]) {
        matches = false;
        break;
      }
    }
    _endLevel(matches);
  }

  // Decrypt Code Logic
  void _startDecryptCode() {
    _generateMathQuestion();
  }

  void _generateMathQuestion() {
    final random = Random();
    int num1 = random.nextInt(10) + 1 + (_currentLevel - 3) * 5; // Increase difficulty
    int num2 = random.nextInt(10) + 1 + (_currentLevel - 3) * 5; // Increase difficulty
    int operator = random.nextInt(3); // 0: +, 1: -, 2: *

    switch (operator) {
      case 0:
        _question = '$num1 + $num2 = ?';
        _answer = num1 + num2;
        break;
      case 1:
        _question = '$num1 - $num2 = ?';
        _answer = num1 - num2;
        break;
      case 2:
        _question = '$num1 * $num2 = ?';
        _answer = num1 * num2;
        break;
    }
    _answerController.clear();
    setState(() {});
  }

  void _checkAnswer() {
    _playSound('sounds/button_click.mp3');
    int? userAnswer = int.tryParse(_answerController.text);
    if (userAnswer != null && userAnswer == _answer) {
      _timer?.cancel();
      _endLevel(true); // Level completed
    } else {
      _endLevel(false); // Level failed
    }
  }

  void _startLevelTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        _endLevel(false); // Level failed
      }
    });
  }

  void _endLevel(bool levelCompleted) {
    _playSound(levelCompleted ? 'sounds/level_complete.mp3' : 'sounds/level_failed.mp3');
    _timer?.cancel(); // Cancel any running timer
    if (levelCompleted) {
      _score += 100; // Add score for completing the level
      if (_currentLevel < 3) {
        setState(() {
          _currentLevel++;
          _startLevel(); // Start the next level
        });
      } else {
        // Game finished
        _saveScore(_score); // Save the score
        Navigator.pushReplacementNamed(context, '/points', arguments: _score);
      }
    } else {
      // Level failed
      Navigator.pushReplacementNamed(context, '/points', arguments: _score); // Navigate to points screen on failure for now
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget miniGameWidget;
    if (_currentLevel == 1) {
      miniGameWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text('Time Left: $_timeLeft s'), // Display timer
          const SizedBox(height: 20),
          LinearProgressIndicator(value: _progress), // Display progress
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleTap, // Call tap handler
            child: const Text('Tap to Break Firewall'),
          ),
        ],
      );
    } else if (_currentLevel == 2) {
      miniGameWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Code Sequence Mini-game'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isDisplayingSequence ? Colors.red[700] : Colors.green[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _isDisplayingSequence ? 'Watch the sequence!' : 'Repeat the sequence!',
              style: TextStyle(fontSize: 24, color: _isDisplayingSequence ? Colors.white : Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _availableColors.map((color) {
              return GestureDetector(
                onTap: () => _handleColorTap(color),
                child: Container(
                  width: 50,
                  height: 50,
                  color: color == _highlightedColor
                      ? color.withOpacity(0.7)
                      : (color == _tappedColor ? color.withOpacity(0.7) : color), // Change color if tapped
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('Time Left: $_timeLeft s'), // Display timer for user input
        ],
      );
    } else {
      miniGameWidget = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Decrypt Code Mini-game'),
            const SizedBox(height: 20),
            Text(_question, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            TextField(
              controller: _answerController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter your answer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: const Text('Submit Answer'),
            ),
            const SizedBox(height: 20),
            Text('Time Left: $_timeLeft s'), // Display timer for user input
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Level: $_currentLevel',
              style: const TextStyle(fontSize: 20, color: Colors.white70),
            ),
            Text(
              'Score: $_score',
              style: const TextStyle(fontSize: 20, color: Colors.white70),
            ),
            miniGameWidget, // Display the current mini-game widget
          ],
        ),
      ),
    );
  }
}
