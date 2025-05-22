import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:code_hacker/widgets/custom_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int _currentLevel = 1;
  int _score = 0;
  int _timeLeft = 10; // Timer for the mini-game
  double _progress = 0.0; // Progress for the tap game
  int _tapsNeeded = 10; // Number of taps needed for the first level
  int _tapsMade = 0;
  Timer? _timer;

  // Animación para el contador de tiempo
  late AnimationController _timeAnimationController;
  late Animation<double> _timeAnimation;

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

  @override
  void initState() {
    super.initState();
    _timeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _timeAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _timeAnimationController, curve: Curves.easeInOut),
    );
    _startLevel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    _timeAnimationController.dispose();
    super.dispose();
  }

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
          if (_timeLeft <= 3) {
            _timeAnimationController.forward().then((_) {
              _timeAnimationController.reverse();
            });
          }
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

  String _getLevelName() {
    switch (_currentLevel) {
      case 1:
        return 'ROMPER FIREWALL';
      case 2:
        return 'SECUENCIA DE CÓDIGO';
      case 3:
        return 'DESCIFRAR CÓDIGO';
      default:
        return 'NIVEL $_currentLevel';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget miniGameWidget;
    if (_currentLevel == 1) {
      miniGameWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            'Toca rápidamente para romper el firewall',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.cyanAccent, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
              ),
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _handleTap,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueGrey.shade800,
                border: Border.all(color: Colors.cyanAccent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.touch_app,
                  color: Colors.cyanAccent,
                  size: 60,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Taps: $_tapsMade / $_tapsNeeded',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      );
    } else if (_currentLevel == 2) {
      miniGameWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: _isDisplayingSequence ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isDisplayingSequence ? Colors.red : Colors.green,
                width: 2,
              ),
            ),
            child: Text(
              _isDisplayingSequence ? 'OBSERVA LA SECUENCIA' : 'REPITE LA SECUENCIA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isDisplayingSequence ? Colors.red : Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: 280,
            height: 70,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_sequence.length, (index) {
                return Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _userInput.length ? _userInput[index] : Colors.blueGrey.shade800,
                    border: Border.all(
                      color: Colors.white30,
                      width: 1,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            alignment: WrapAlignment.center,
            children: _availableColors.map((color) {
              bool isHighlighted = color == _highlightedColor || color == _tappedColor;
              return GestureDetector(
                onTap: () => _handleColorTap(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isHighlighted ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isHighlighted
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.7),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    } else {
      miniGameWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Resuelve la ecuación:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.cyanAccent),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                _question,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _answerController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tu respuesta',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.cyanAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            HackerButton(
              text: 'ENVIAR RESPUESTA',
              icon: Icons.send,
              onPressed: _checkAnswer,
              playSound: false,
            ),
          ],
        ),
      );
    }

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NIVEL $_currentLevel',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          _getLevelName(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyanAccent,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.cyanAccent, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            '$_score',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white70, size: 16),
                    const SizedBox(width: 5),
                    const Text(
                      'Tiempo:',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: _timeLeft / 10,
                          backgroundColor: Colors.blueGrey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _timeLeft <= 3 ? Colors.red : Colors.cyanAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ScaleTransition(
                      scale: _timeAnimation,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _timeLeft <= 3 ? Colors.red : Colors.cyanAccent,
                        ),
                        child: Center(
                          child: Text(
                            '$_timeLeft',
                            style: TextStyle(
                              color: _timeLeft <= 3 ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.blueGrey, height: 30),
              Expanded(
                child: Center(
                  child: miniGameWidget,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
