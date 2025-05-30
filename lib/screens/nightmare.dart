import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:code_hacker/services/audio_service.dart';

class NightmareScreen extends StatefulWidget {
  const NightmareScreen({super.key});

  @override
  State<NightmareScreen> createState() => _NightmareScreenState();
}

class _NightmareScreenState extends State<NightmareScreen> with TickerProviderStateMixin {
  int _score = 0;
  int _timeLeft = 15; // Temporizador inicial
  int _currentLevel = 1;
  Timer? _timer;
  final Random _random = Random();
  
  // Animación para el contador de tiempo
  late AnimationController _timeAnimationController;
  late Animation<double> _timeAnimation;
  
  // Variables para el nivel 1: Botón Esquivo
  double _buttonX = 0.5;
  double _buttonY = 0.5;
  int _tapCount = 0;
  int _tapsNeeded = 20; // Taps necesarios para completar el nivel
  
  // Variables para el nivel 2: Secuencia Cambiante
  List<Color> _sequence = [];
  List<Color> _userInput = [];
  bool _isDisplayingSequence = false;
  Color? _highlightedColor;
  Color? _tappedColor;
  bool _shufflePositions = false; // Determina si las posiciones cambian
  List<int> _colorPositions = [0, 1, 2, 3]; // Posiciones de los colores
  final List<Color> _availableColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ];
  int _sequenceLength = 6; // Longitud inicial de secuencia (más larga que el juego normal)
  
  // Variables para el nivel 3: Operaciones Complejas
  String _question = '';
  int _answer = 0;
  List<int> _answerOptions = [];
  
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
    
    // Iniciar la música de Nightmare
    AudioService().playNightmareMusic();
    
    _startLevel();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _timeAnimationController.dispose();
    
    // Detener la música de Nightmare al salir
    AudioService().stopNightmareMusic();
    
    super.dispose();
  }
  
  // Función para reproducir sonido
  Future<void> _playSound(String soundAsset) async {
    await AudioService().playSoundEffect(soundAsset);
  }
  
  void _startLevel() {
    _timer?.cancel();
    
    // Tiempo reducido para mayor dificultad
    _timeLeft = 15;
    
    // Asegurar que la música de pesadilla siga reproduciéndose
    Future.delayed(const Duration(milliseconds: 100), () {
      AudioService().playNightmareMusic();
    });
    
    if (_currentLevel == 1) {
      _startElusiveButton();
    } else if (_currentLevel == 2) {
      _startChangingSequence();
    } else if (_currentLevel == 3) {
      _startComplexOperations();
    }
    
    _startLevelTimer();
  }
  
  // NIVEL 1: BOTÓN ESQUIVO
  void _startElusiveButton() {
    _tapCount = 0;
    _tapsNeeded = 20;
    _moveButton(); // Colocar el botón en posición inicial aleatoria
  }
  
  void _moveButton() {
    setState(() {
      _buttonX = 0.1 + _random.nextDouble() * 0.8; // Entre 0.1 y 0.9
      _buttonY = 0.1 + _random.nextDouble() * 0.8; // Entre 0.1 y 0.9
    });
  }
  
  void _handleButtonTap() {
    _playSound('sounds/button_click.mp3');
    
    setState(() {
      _tapCount++;
    });
    
    if (_tapCount >= _tapsNeeded) {
      _timer?.cancel();
      _endLevel(true);
    } else {
      // Mover el botón después de cada toque
      _moveButton();
      
      // Hacer que el botón se mueva más rápido a medida que se avanza
      if (_tapCount > _tapsNeeded / 2) {
        // Mover dos veces más rápido en la segunda mitad
        Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)), () {
          if (mounted) _moveButton();
        });
      }
    }
  }
  
  // NIVEL 2: SECUENCIA CAMBIANTE
  void _startChangingSequence() {
    _sequenceLength = 6; // Secuencia más larga que el juego normal
    _sequence = _generateSequence(_sequenceLength);
    _userInput = [];
    _colorPositions = [0, 1, 2, 3]; // Reiniciar posiciones
    _isDisplayingSequence = true;
    _displaySequence();
  }
  
  List<Color> _generateSequence(int length) {
    return List.generate(length, (_) => _availableColors[_random.nextInt(_availableColors.length)]);
  }
  
  Future<void> _displaySequence() async {
    _timer?.cancel();
    
    for (var color in _sequence) {
      _highlightedColor = color;
      setState(() {});
      await Future.delayed(Duration(milliseconds: 400));
      _highlightedColor = null;
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    setState(() {
      _isDisplayingSequence = false;
      // Activar cambio de posiciones después de mostrar la secuencia
      _shufflePositions = true;
      // Barajar las posiciones de los colores
      _colorPositions.shuffle();
      // Reiniciar el tiempo completo
      _timeLeft = 15;
    });
    
    await Future.delayed(const Duration(milliseconds: 500));
    _startLevelTimer();
  }
  
  void _handleColorTap(Color color) {
    _playSound('sounds/button_click.mp3');
    
    if (!_isDisplayingSequence && _timeLeft > 0) {
      setState(() {
        _tappedColor = color;
        _userInput.add(color);
      });
      
      // Brevemente resaltar el color tocado
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _tappedColor = null;
          });
        }
      });
      
      // Mezclar las posiciones periódicamente para aumentar la dificultad
      if (_shufflePositions && _random.nextInt(3) == 0) {
        setState(() {
          _colorPositions.shuffle();
        });
      }
      
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
  
  // NIVEL 3: OPERACIONES COMPLEJAS
  void _startComplexOperations() {
    _generateComplexQuestion();
    _generateAnswerOptions();
  }
  
  void _generateComplexQuestion() {
    final random = Random();
    
    // Generar operaciones más complejas con múltiples operadores
    // Nota: la dificultad está integrada directamente en los rangos de números
    
    // Generar 3 números para operaciones más complejas
    int num1 = random.nextInt(20) + 10; // 10-29
    int num2 = random.nextInt(10) + 5;  // 5-14
    int num3 = random.nextInt(15) + 5;  // 5-19
    
    // Elegir operación aleatoria más compleja
    int operationType = random.nextInt(5);
    
    switch (operationType) {
      case 0:
        // Operación con paréntesis: (a + b) * c
        _question = '($num1 + $num2) × $num3 = ?';
        _answer = (num1 + num2) * num3;
        break;
      case 1:
        // Operación con paréntesis: (a * b) + c
        _question = '($num1 × $num2) + $num3 = ?';
        _answer = (num1 * num2) + num3;
        break;
      case 2:
        // Operación con paréntesis: a * (b + c)
        _question = '$num1 × ($num2 + $num3) = ?';
        _answer = num1 * (num2 + num3);
        break;
      case 3:
        // Operación con exponente: a² + b
        int squared = num1 * num1;
        _question = '$num1² + $num2 = ?';
        _answer = squared + num2;
        break;
      case 4:
        // División con resto: a % b
        // Asegurar que num1 > num2 para evitar resultados negativos
        if (num1 < num2) {
          int temp = num1;
          num1 = num2;
          num2 = temp;
        }
        _question = '$num1 % $num2 = ?';
        _answer = num1 % num2;
        break;
    }
    
    setState(() {});
  }
  
  void _generateAnswerOptions() {
    _answerOptions = [];
    
    // Agregar la respuesta correcta
    _answerOptions.add(_answer);
    
    // Generar opciones incorrectas más cercanas a la respuesta correcta
    while (_answerOptions.length < 4) {
      // Crear opciones más engañosas
      int offset;
      if (_answer < 20) {
        offset = _random.nextInt(5) + 1; // Pequeños offsets para números pequeños
      } else if (_answer < 100) {
        offset = _random.nextInt(10) + 1; // Offsets medianos para números medianos
      } else {
        offset = _random.nextInt(20) + 5; // Grandes offsets para números grandes
      }
      
      if (_random.nextBool()) offset = -offset;
      
      int option = _answer + offset;
      
      // Asegurar que la opción sea positiva y única
      if (option >= 0 && !_answerOptions.contains(option)) {
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
      _endLevel(true);
    } else {
      _endLevel(false);
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
        _endLevel(false);
      }
    });
  }
  
  void _endLevel(bool levelCompleted) {
    _playSound(levelCompleted ? 'sounds/level_complete.mp3' : 'sounds/level_failed.mp3');
    _timer?.cancel();
    
    // Asegurar que la música de pesadilla siga reproduciéndose
    Future.delayed(const Duration(milliseconds: 500), () {
      AudioService().playNightmareMusic();
    });
    
    if (levelCompleted) {
      // Puntuación más alta para el modo pesadilla
      int levelPoints = 200;
      _score += levelPoints;
      
      if (_currentLevel < 3) {
        setState(() {
          _currentLevel++;
          _startLevel();
        });
      } else {
        // Todos los niveles de pesadilla completados
        _saveScore(_score);
        _showCompletionDialog();
      }
    } else {
      // Game over - Nivel fallido
      _saveScore(_score);
      
      // Asegurar que la música siga reproduciéndose durante la transición
      Future.delayed(const Duration(milliseconds: 300), () {
        AudioService().playNightmareMusic();
      });
      
      Navigator.pushReplacementNamed(
        context, 
        '/points', 
        arguments: {
          'score': _score,
          'nightmare': true,
        },
      );
    }
  }
  
  Future<void> _saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final highscore = prefs.getInt('nightmare_highscore') ?? 0;
    if (score > highscore) {
      await prefs.setInt('nightmare_highscore', score);
    }
  }
  
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          '¡MODO BLACK HAT COMPLETADO!',
          style: TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            Text(
              '¡Increíble! Has dominado el modo Black Hat.\nPuntuación: $_score',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(
                context, 
                '/points', 
                arguments: {
                  'score': _score,
                  'nightmare': true,
                  'completed': true,
                },
              );
            },
            child: const Text('CONTINUAR', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }
  
  String _getLevelName() {
    switch (_currentLevel) {
      case 1:
        return 'BOTÓN ESQUIVO';
      case 2:
        return 'SECUENCIA CAMBIANTE';
      case 3:
        return 'OPERACIONES COMPLEJAS';
      default:
        return 'NIVEL $_currentLevel';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    Widget miniGameWidget;
    
    // NIVEL 1: BOTÓN ESQUIVO
    if (_currentLevel == 1) {
      miniGameWidget = Stack(
        children: [
          Container(
            width: double.infinity,
            height: 400,
            color: Colors.transparent,
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * _buttonX - 40,
            top: 400 * _buttonY - 40,
            child: GestureDetector(
              onTap: _handleButtonTap,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueGrey.shade900,
                  border: Border.all(color: Colors.red, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.touch_app,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Taps: $_tapCount / $_tapsNeeded',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      );
    }
    // NIVEL 2: SECUENCIA CAMBIANTE
    else if (_currentLevel == 2) {
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
            width: 300,
            height: 70,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.5)),
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
            children: _availableColors.asMap().entries.map((entry) {
              int colorIndex = entry.key;
              Color color = entry.value;
              // Usar posición barajada para mayor dificultad
              _colorPositions[colorIndex]; // Referencia para mantener la variable
              bool isHighlighted = color == _highlightedColor || color == _tappedColor;
              
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: GestureDetector(
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
                ),
              );
            }).toList(),
          ),
        ],
      );
    }
    // NIVEL 3: OPERACIONES COMPLEJAS
    else {
      miniGameWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Resuelve la operación:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                _question,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Opciones de respuesta
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
                      border: Border.all(color: Colors.red.withOpacity(0.7), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.2),
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
                          color: Colors.red,
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
    }
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.red.shade900.withOpacity(0.7)],
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
                            const Text(
                              'MODO BLACK HAT',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _getLevelName(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.red, size: 16),
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
                          value: _timeLeft / 15,
                          backgroundColor: Colors.blueGrey.shade900,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _timeLeft <= 3 ? Colors.red : Colors.red.shade300,
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
                          color: _timeLeft <= 3 ? Colors.red : Colors.red.shade300,
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
              const Divider(color: Colors.red, height: 30),
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