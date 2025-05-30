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

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int _currentLevel = 1;
  int _score = 0;
  int _timeLeft = 10; // Timer for the mini-game
  double _progress = 0.0; // Progress for the tap game
  int _tapsNeeded = 10; // Number of taps needed for the first level
  int _tapsMade = 0;
  Timer? _timer;
  int _currentCycle = 1; // Contador de ciclos completados
  bool _showLevelUpMessage = false; // Para mostrar mensaje de subida de nivel
  String _levelUpMessage = ''; // Mensaje de subida de nivel

  // Animación para el contador de tiempo
  late AnimationController _timeAnimationController;
  late Animation<double> _timeAnimation;
  
  // Animación para el mensaje de subida de nivel
  late AnimationController _levelUpAnimationController;
  late Animation<double> _levelUpAnimation;

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
  List<int> _answerOptions = []; // Lista de opciones para elegir

  // Password Hack Mini-game variables
  String _targetPassword = '';
  List<String> _selectedCharacters = [];
  List<bool> _correctCharacters = []; // Para indicar qué caracteres son correctos
  String _lastTappedChar = ''; // Para rastrear el último carácter seleccionado
  int _lastSelectedPosition = -1; // Para rastrear la última posición seleccionada
  bool _isVerifyingPassword = false; // Para indicar cuando se está verificando la contraseña
  int _passwordLength = 4; // Longitud inicial de la contraseña
  final List<String> _availableCharacters = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'A', 'B', 'C', 'D', 'E', 'F', '#', '@', '%', '&'
  ];

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
    
    _levelUpAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _levelUpAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _levelUpAnimationController, curve: Curves.elasticOut),
    );
    
    _startLevel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeAnimationController.dispose();
    _levelUpAnimationController.dispose();
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
    
    // Ajustar tiempo según el ciclo (más difícil con cada ciclo)
    if (_currentLevel == 4) {
      // Más tiempo para el nivel de contraseña: 90 segundos en ciclo 1, reduciendo gradualmente
      _timeLeft = max(60, 90 - ((_currentCycle - 1) * 5)); // Mínimo 60 segundos
    } else {
      _timeLeft = max(5, 10 - (_currentCycle - 1)); // Mínimo 5 segundos para otros niveles
    }
    
    if (_currentLevel == 1) {
      _startFirewallBreak();
      _startLevelTimer(); // Iniciar temporizador inmediatamente para nivel 1
    } else if (_currentLevel == 2) {
      _startCodeSequence();
      // Para el nivel 2, el temporizador se iniciará después de mostrar la secuencia
    } else if (_currentLevel == 3) {
      _startDecryptCode();
      _startLevelTimer(); // Iniciar temporizador inmediatamente para nivel 3
    } else if (_currentLevel == 4) {
      _startPasswordHack();
      _startLevelTimer(); // Iniciar temporizador inmediatamente para nivel 4
    }
  }

  // Firewall Break Logic
  void _startFirewallBreak() {
    _progress = 0.0;
    _tapsMade = 0;
    // Aumentar la dificultad con cada ciclo
    _tapsNeeded = 10 + (_currentLevel - 1) * 5 + (_currentCycle - 1) * 3;
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
    // Aumentar la longitud de la secuencia con cada ciclo
    _sequenceLength = 3 + (_currentLevel - 2) + (_currentCycle - 1);
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
    // Asegurar que no haya temporizador activo durante la visualización
    _timer?.cancel();
    
    for (var color in _sequence) {
      _highlightedColor = color;
      setState(() {}); // Trigger rebuild to show the highlighted color
      // Reducir el tiempo de visualización con cada ciclo para aumentar dificultad
      int displayTime = max(200, 500 - (_currentCycle - 1) * 50);
      await Future.delayed(Duration(milliseconds: displayTime));
      _highlightedColor = null;
      setState(() {}); // Trigger rebuild to remove the highlight
      await Future.delayed(const Duration(milliseconds: 200)); // Short delay before the next color
    }
    
    await Future.delayed(const Duration(seconds: 1)); // Delay after sequence is displayed
    
    setState(() {
      _isDisplayingSequence = false;
      // Reiniciar el tiempo al valor completo después de mostrar la secuencia
      if (_currentLevel == 4) {
        // Mantener el tiempo especial para el nivel 4
        _timeLeft = max(60, 90 - ((_currentCycle - 1) * 5));
      } else {
        // Para otros niveles, usar el tiempo original
        _timeLeft = max(5, 10 - (_currentCycle - 1));
      }
    });
    
    await Future.delayed(const Duration(milliseconds: 500)); // Reduced delay
    
    // Iniciar el temporizador solo después de que se haya mostrado la secuencia
    _startLevelTimer();
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
    _generateAnswerOptions(); // Generar opciones de respuesta
  }

  void _generateMathQuestion() {
    final random = Random();
    // Aumentar la dificultad con cada ciclo
    int difficulty = (_currentLevel - 3) * 5 + (_currentCycle - 1) * 3;
    int num1 = random.nextInt(10) + 1 + difficulty;
    int num2 = random.nextInt(10) + 1 + difficulty;
    
    // Con ciclos más altos, introducir operaciones más complejas
    int maxOperator = _currentCycle > 2 ? 3 : 2; // Incluir división en ciclos avanzados
    int operator = random.nextInt(maxOperator);

    switch (operator) {
      case 0:
        _question = '$num1 + $num2 = ?';
        _answer = num1 + num2;
        break;
      case 1:
        // Asegurar que la resta no sea negativa
        if (num1 < num2) {
          int temp = num1;
          num1 = num2;
          num2 = temp;
        }
        _question = '$num1 - $num2 = ?';
        _answer = num1 - num2;
        break;
      case 2:
        _question = '$num1 × $num2 = ?';
        _answer = num1 * num2;
        break;
      case 3:
        // Asegurar que la división sea exacta
        int result = num1 * num2;
        _question = '$result ÷ $num1 = ?';
        _answer = num2;
        break;
    }
    setState(() {});
  }

  void _generateAnswerOptions() {
    final random = Random();
    _answerOptions = [];
    
    // Agregar la respuesta correcta
    _answerOptions.add(_answer);
    
    // Generar opciones incorrectas pero cercanas a la respuesta correcta
    while (_answerOptions.length < 4) {
      // Calculamos opciones cercanas a la respuesta correcta
      int offset = random.nextInt(10) + 1;
      if (random.nextBool()) offset = -offset;
      
      int option = _answer + offset;
      
      // Asegurar que la opción sea positiva y única
      if (option > 0 && !_answerOptions.contains(option)) {
        _answerOptions.add(option);
      }
    }
    
    // Mezclar las opciones
    _answerOptions.shuffle();
    
    setState(() {});
  }

  void _checkAnswerOption(int selectedAnswer) {
    _playSound('sounds/button_click.mp3');
    if (selectedAnswer == _answer) {
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
          // Ajustar la animación de alerta según el nivel
          if (_currentLevel == 4) {
            // Para el nivel 4, mostrar la animación cuando queden 10 segundos o menos
            if (_timeLeft <= 10) {
              _timeAnimationController.forward().then((_) {
                _timeAnimationController.reverse();
              });
            }
          } else {
            // Para otros niveles, mantener el comportamiento original (3 segundos)
            if (_timeLeft <= 3) {
              _timeAnimationController.forward().then((_) {
                _timeAnimationController.reverse();
              });
            }
          }
        });
      } else {
        _timer?.cancel();
        _endLevel(false); // Level failed
      }
    });
  }

  void _showCycleCompletedMessage() {
    setState(() {
      _showLevelUpMessage = true;
      _levelUpMessage = '¡CICLO $_currentCycle COMPLETADO!';
    });
    
    _levelUpAnimationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showLevelUpMessage = false;
          });
          _levelUpAnimationController.reset();
          _startLevel(); // Iniciar el siguiente nivel
        }
      });
    });
  }

  // Password Hack Logic
  void _startPasswordHack() {
    // Aumentar la dificultad con cada ciclo
    _passwordLength = 4 + (_currentCycle - 1);
    _generateTargetPassword();
    _selectedCharacters = List.filled(_passwordLength, '');
    _correctCharacters = List.filled(_passwordLength, false); // Inicializar todos como incorrectos
  }
  
  void _generateTargetPassword() {
    final random = Random();
    _targetPassword = '';
    
    // Generar una contraseña aleatoria con la longitud determinada
    for (int i = 0; i < _passwordLength; i++) {
      _targetPassword += _availableCharacters[random.nextInt(_availableCharacters.length)];
    }
    
    setState(() {});
  }
  
  void _handleCharacterSelection(int position, String character) {
    // No permitir cambiar caracteres que ya están correctos
    if (_correctCharacters[position]) {
      return;
    }
    
    _playSound('sounds/button_click.mp3');
    
    setState(() {
      _selectedCharacters[position] = character;
      _lastTappedChar = character; // Guardar el último carácter seleccionado
      _lastSelectedPosition = position; // Guardar la última posición seleccionada
    });
    
    // Limpiar el último carácter seleccionado después de un tiempo
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _lastTappedChar = '';
        });
      }
    });

    // Limpiar la última posición seleccionada después de un tiempo
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _lastSelectedPosition = -1;
        });
      }
    });
    
    // Verificar si se ha completado la contraseña
    bool isComplete = !_selectedCharacters.contains('');
    if (isComplete) {
      // Añadir un pequeño retraso para que el usuario vea el último carácter
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _checkPassword();
        }
      });
    }
  }
  
  void _checkPassword() {
    String attemptedPassword = _selectedCharacters.join();
    
    // Primero, mostrar un efecto visual en toda la contraseña
    setState(() {
      _isVerifyingPassword = true; // Indicar que estamos verificando
    });
    
    // Verificar la contraseña después de un breve retraso
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      // Desactivar el estado de verificación
      setState(() {
        _isVerifyingPassword = false;
      });
      
      if (attemptedPassword == _targetPassword) {
        _timer?.cancel();
        _endLevel(true); // Level completed
      } else {
        // Actualizar qué caracteres son correctos
        List<String> tempSelectedCharacters = List.from(_selectedCharacters);
        
        for (int i = 0; i < _passwordLength; i++) {
          if (i < _targetPassword.length && 
              i < attemptedPassword.length && 
              _targetPassword[i] == attemptedPassword[i]) {
            _correctCharacters[i] = true;
          }
        }
        
        // Mantener los caracteres correctos, limpiar los incorrectos
        List<String> newSelectedChars = List.filled(_passwordLength, '');
        for (int i = 0; i < _passwordLength; i++) {
          if (_correctCharacters[i]) {
            newSelectedChars[i] = _targetPassword[i];
          }
        }
        
        // Contar cuántos caracteres son correctos
        int correctCount = _correctCharacters.where((isCorrect) => isCorrect).length;
        
        setState(() {
          _selectedCharacters = newSelectedChars;
        });
        
        // Mostrar pistas visuales brevemente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Contraseña incorrecta. $correctCount/${_passwordLength} caracteres correctos.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade900,
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _endLevel(bool levelCompleted) {
    _playSound(levelCompleted ? 'sounds/level_complete.mp3' : 'sounds/level_failed.mp3');
    _timer?.cancel(); // Cancel any running timer
    if (levelCompleted) {
      // Puntuación base por nivel + bonificación por ciclo
      int levelPoints = 100 * _currentCycle;
      _score += levelPoints;
      
      if (_currentLevel < 4) {
        setState(() {
          _currentLevel++;
          _startLevel(); // Start the next level
        });
      } else {
        // Ciclo completado
        setState(() {
          _currentLevel = 1; // Reiniciar al nivel 1
          _currentCycle++; // Incrementar el contador de ciclos
        });
        _showCycleCompletedMessage();
      }
    } else {
      // Game over - Level failed
      _saveScore(_score); // Save the score
      Navigator.pushReplacementNamed(
        context, 
        '/points', 
        arguments: {
          'score': _score,
          'cycle': _currentCycle,
          'level': _currentLevel,
        },
      );
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
      case 4:
        return 'HACKEAR CONTRASEÑA';
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
    } else if (_currentLevel == 3) {
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
            // Opciones de respuesta en lugar de TextField
            Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: _answerOptions.map((option) {
                return GestureDetector(
                  onTap: () => _checkAnswerOption(option),
                  child: Container(
                    width: 120,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.cyanAccent.withOpacity(0.7), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        option.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    } else {
      // Nivel 4: Hackear Contraseña
      miniGameWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Hackea la contraseña:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
              child: Column(
                children: [
                  Text(
                    'ACCESO RESTRINGIDO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_passwordLength, (index) {
                      // Determinar si esta celda es la última seleccionada o si estamos verificando
                      bool isLastSelected = index == _lastSelectedPosition;
                      bool hasChar = _selectedCharacters[index].isNotEmpty;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isLastSelected ? 45 : 40,
                        height: isLastSelected ? 55 : 50,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _isVerifyingPassword 
                              ? Colors.orange.shade900
                              : _correctCharacters[index]
                                  ? Colors.green.shade900 
                                  : isLastSelected && hasChar
                                      ? Colors.blueGrey.shade700
                                      : Colors.black87,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _isVerifyingPassword
                                ? Colors.orange
                                : _correctCharacters[index]
                                    ? Colors.green
                                    : isLastSelected && hasChar
                                        ? Colors.cyanAccent
                                        : Colors.cyanAccent.withOpacity(0.7),
                            width: (isLastSelected && hasChar) || _correctCharacters[index] || _isVerifyingPassword ? 2 : 1,
                          ),
                          boxShadow: (isLastSelected && hasChar) || _correctCharacters[index] || _isVerifyingPassword
                              ? [
                                  BoxShadow(
                                    color: _isVerifyingPassword
                                        ? Colors.orange.withOpacity(0.3)
                                        : _correctCharacters[index]
                                            ? Colors.green.withOpacity(0.3)
                                            : Colors.cyanAccent.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ] 
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _selectedCharacters[index],
                            style: TextStyle(
                              fontSize: isLastSelected ? 26 : 24,
                              fontWeight: FontWeight.bold,
                              color: _isVerifyingPassword
                                  ? Colors.orange.shade300
                                  : _correctCharacters[index] 
                                      ? Colors.green.shade300 
                                      : isLastSelected && hasChar
                                          ? Colors.white
                                          : Colors.cyanAccent,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity, // Ancho completo
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Wrap(
                spacing: 6, // Reducir el espaciado horizontal
                runSpacing: 6, // Reducir el espaciado vertical
                alignment: WrapAlignment.center,
                children: _availableCharacters.map((char) {
                  // Verificar si este es el último carácter seleccionado
                  bool isLastTapped = char == _lastTappedChar;
                  
                  return Container(
                    // Contenedor exterior con tamaño fijo para reservar el espacio
                    width: 50, // Un poco más grande que el tamaño máximo del botón
                    height: 50, // Un poco más grande que el tamaño máximo del botón
                    alignment: Alignment.center, // Centrar el contenido
                    child: GestureDetector(
                      onTap: () {
                        // No permitir selecciones durante la verificación
                        if (_isVerifyingPassword) return;
                        
                        // Encontrar la primera posición vacía
                        int emptyPosition = _selectedCharacters.indexOf('');
                        if (emptyPosition != -1) {
                          _handleCharacterSelection(emptyPosition, char);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        // Reducir ligeramente la diferencia de tamaño
                        width: isLastTapped ? 44 : 40,
                        height: isLastTapped ? 44 : 40,
                        decoration: BoxDecoration(
                          color: isLastTapped ? Colors.cyanAccent.withOpacity(0.3) : Colors.blueGrey.shade900,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isLastTapped ? Colors.cyanAccent : Colors.cyanAccent.withOpacity(0.5),
                            width: isLastTapped ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isLastTapped ? Colors.cyanAccent.withOpacity(0.5) : Colors.black26,
                              blurRadius: isLastTapped ? 10 : 3,
                              spreadRadius: isLastTapped ? 2 : 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            char,
                            style: TextStyle(
                              fontSize: isLastTapped ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: isLastTapped ? Colors.white : Colors.cyanAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // No permitir reiniciar mientras se está verificando
                if (_isVerifyingPassword) return;
                
                setState(() {
                  // Crear una nueva lista manteniendo los caracteres correctos
                  List<String> newSelectedChars = List.filled(_passwordLength, '');
                  for (int i = 0; i < _passwordLength; i++) {
                    if (_correctCharacters[i]) {
                      newSelectedChars[i] = _targetPassword[i];
                    }
                  }
                  _selectedCharacters = newSelectedChars;
                  _lastSelectedPosition = -1; // Resetear última posición seleccionada
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: _isVerifyingPassword 
                      ? Colors.grey.withOpacity(0.2) 
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isVerifyingPassword 
                        ? Colors.grey.withOpacity(0.5) 
                        : Colors.red.withOpacity(0.7),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh, 
                      color: _isVerifyingPassword ? Colors.grey : Colors.red, 
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'REINICIAR',
                      style: TextStyle(
                        color: _isVerifyingPassword ? Colors.grey : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                            Row(
                              children: [
                                Text(
                                  'NIVEL $_currentLevel',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.red.withOpacity(0.7)),
                                  ),
                                  child: Text(
                                    'CICLO $_currentCycle',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
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
                              value: _currentLevel == 4 
                                  ? _timeLeft / (max(60, 90 - ((_currentCycle - 1) * 5))) // Para nivel 4, usar el valor máximo correcto
                                  : _timeLeft / 10, // Para otros niveles, usar 10 como máximo
                              backgroundColor: Colors.blueGrey.shade800,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _currentLevel == 4
                                    ? (_timeLeft <= 10 ? Colors.red : Colors.cyanAccent)
                                    : (_timeLeft <= 3 ? Colors.red : Colors.cyanAccent),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ScaleTransition(
                          scale: _timeAnimation,
                          child: Container(
                            width: _currentLevel == 4 ? 60 : 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: _currentLevel == 4 ? BoxShape.rectangle : BoxShape.circle,
                              borderRadius: _currentLevel == 4 ? BorderRadius.circular(15) : null,
                              color: _currentLevel == 4 
                                  ? (_timeLeft <= 10 ? Colors.red : Colors.cyanAccent)
                                  : (_timeLeft <= 3 ? Colors.red : Colors.cyanAccent),
                            ),
                            child: Center(
                              child: Text(
                                _currentLevel == 4 && _timeLeft > 60
                                    ? '${_timeLeft ~/ 60}:${(_timeLeft % 60).toString().padLeft(2, '0')}'
                                    : '$_timeLeft',
                                style: TextStyle(
                                  color: _currentLevel == 4 
                                      ? (_timeLeft <= 10 ? Colors.white : Colors.black)
                                      : (_timeLeft <= 3 ? Colors.white : Colors.black),
                                  fontWeight: FontWeight.bold,
                                  fontSize: _currentLevel == 4 ? 12 : 14,
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
          if (_showLevelUpMessage)
            Positioned.fill(
              child: ScaleTransition(
                scale: _levelUpAnimation,
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.cyanAccent, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_circle_up,
                            color: Colors.cyanAccent,
                            size: 50,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _levelUpMessage,
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Dificultad aumentada',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Puntuación: $_score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
