import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

import 'dart:async';

import 'dart:async';
import 'dart:math';

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
  final List<Color> _availableColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ];
  int _sequenceLength = 3; // Initial sequence length

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLevel() {
    if (_currentLevel == 1) {
      _startFirewallBreak();
    } else if (_currentLevel == 2) {
      _startCodeSequence();
    } else if (_currentLevel == 3) {
      _startDecryptCode();
    }
  }

  // Firewall Break Logic
  void _startFirewallBreak() {
    _timeLeft = 10;
    _progress = 0.0;
    _tapsMade = 0;
    _tapsNeeded = 10 + (_currentLevel - 1) * 5; // Increase taps needed per level
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

  void _handleTap() {
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
    await Future.delayed(const Duration(seconds: 1)); // Initial delay
    for (Color color in _sequence) {
      // TODO: Highlight the color in the UI
      await Future.delayed(const Duration(milliseconds: 500)); // Display duration
      // TODO: Unhighlight the color
      await Future.delayed(const Duration(milliseconds: 250)); // Delay between colors
    }
    setState(() {
      _isDisplayingSequence = false;
    });
    _startLevelTimer(); // Start timer for user input
  }

  void _handleColorTap(Color color) {
    if (!_isDisplayingSequence && _timeLeft > 0) {
      setState(() {
        _userInput.add(color);
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

  // Decrypt Code Mini-game variables
  String _question = '';
  int _answer = 0;
  final TextEditingController _answerController = TextEditingController();

  // Decrypt Code Logic
  void _startDecryptCode() {
    _generateMathQuestion();
    _startLevelTimer(); // Start timer for the level
  }

  void _generateMathQuestion() {
    final random = Random();
    int num1 = random.nextInt(10) + 1;
    int num2 = random.nextInt(10) + 1;
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
    int? userAnswer = int.tryParse(_answerController.text);
    if (userAnswer != null && userAnswer == _answer) {
      _timer?.cancel();
      _endLevel(true); // Level completed
    } else {
      _endLevel(false); // Level failed
    }
  }

  void _endLevel(bool levelCompleted) {
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
        Navigator.pushReplacementNamed(context, '/points', arguments: _score);
      }
    } else {
      // Level failed
      // TODO: Implement logic for losing a life or restarting the level
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
          Text(_isDisplayingSequence ? 'Watch the sequence!' : 'Repeat the sequence!'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _availableColors.map((color) {
              return GestureDetector(
                onTap: () => _handleColorTap(color),
                child: Container(
                  width: 50,
                  height: 50,
                  color: color,
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
            Text('Level: $_currentLevel'),
            Text('Score: $_score'),
            miniGameWidget, // Display the current mini-game widget
          ],
        ),
      ),
    );
  }
}
