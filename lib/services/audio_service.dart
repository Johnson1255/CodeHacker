import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  
  // Un único reproductor para toda la aplicación
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Estado de la música
  bool _isMusicPlaying = false;
  bool _isNightmareMusicPlaying = false;
  
  // Ruta del archivo de música actual
  String? _currentMusicPath;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal() {
    // Configurar el reproductor en modo de bucle para la música
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  // Método simplificado para reproducir música de fondo
  Future<void> playBackgroundMusic() async {
    if (!_isMusicPlaying) {
      try {
        _currentMusicPath = 'sounds/denial-of-service-sci-fi-hacker-instrumental-267766.mp3';
        await _audioPlayer.play(AssetSource(_currentMusicPath!));
        _isMusicPlaying = true;
        _isNightmareMusicPlaying = false;
      } catch (e) {
        _isMusicPlaying = false;
      }
    }
  }

  // Método simplificado para reproducir música de pesadilla
  Future<void> playNightmareMusic() async {
    try {
      if (_currentMusicPath != 'sounds/cyberpunk-231946.mp3') {
        await _audioPlayer.stop();
        _currentMusicPath = 'sounds/cyberpunk-231946.mp3';
        await _audioPlayer.play(AssetSource(_currentMusicPath!));
      } else if (!_isNightmareMusicPlaying) {
        await _audioPlayer.resume();
      }
      
      _isNightmareMusicPlaying = true;
      _isMusicPlaying = false;
    } catch (e) {
      _isNightmareMusicPlaying = false;
    }
  }

  // Método simplificado para efectos de sonido - ahora no interrumpe la música
  Future<void> playSoundEffect(String soundAsset) async {
    try {
      // Para efectos de sonido, simplemente reproducimos el sonido sin interrumpir la música
      // Esto es una simulación simple, ya que estamos usando un solo reproductor
      // En un juego profesional, usaríamos una biblioteca de mezcla de audio más avanzada
      
      // Guardamos el volumen actual
      double currentVolume = await _audioPlayer.volume;
      
      // Reducimos brevemente el volumen para "mezclar" los sonidos
      await _audioPlayer.setVolume(currentVolume * 0.7);
      
      // Después de un breve momento, restauramos el volumen original
      Future.delayed(Duration(milliseconds: 300), () async {
        await _audioPlayer.setVolume(currentVolume);
      });
    } catch (e) {
      // Manejo silencioso de errores
    }
  }

  Future<void> stopNightmareMusic() async {
    if (_isNightmareMusicPlaying) {
      await _audioPlayer.stop();
      _isNightmareMusicPlaying = false;
      
      // Reanudar música normal si estaba reproduciéndose antes
      if (_isMusicPlaying) {
        await playBackgroundMusic();
      }
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (_isMusicPlaying) {
      await _audioPlayer.stop();
      _isMusicPlaying = false;
    }
  }

  Future<void> pauseBackgroundMusic() async {
    if (_isMusicPlaying) {
      await _audioPlayer.pause();
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (_isMusicPlaying) {
      await _audioPlayer.resume();
    } else {
      await playBackgroundMusic();
    }
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
} 