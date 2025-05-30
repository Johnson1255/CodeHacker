import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _backgroundMusic = AudioPlayer();
  final AudioPlayer _nightmareMusic = AudioPlayer();
  bool _isMusicPlaying = false;
  bool _isNightmareMusicPlaying = false;
  
  // Añadir un AudioPlayer para efectos de sonido
  final AudioPlayer _soundEffects = AudioPlayer();

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  Future<void> playBackgroundMusic() async {
    if (!_isMusicPlaying) {
      try {
        await _backgroundMusic.play(
          AssetSource('sounds/denial-of-service-sci-fi-hacker-instrumental-267766.mp3'),
          mode: PlayerMode.mediaPlayer,
        );
        await _backgroundMusic.setReleaseMode(ReleaseMode.loop);
        _isMusicPlaying = true;
      } catch (e) {
        // Manejo silencioso de errores para evitar crasheos
        _isMusicPlaying = false;
      }
    }
  }

  Future<void> playNightmareMusic() async {
    // Pausar la música normal si está reproduciéndose
    if (_isMusicPlaying) {
      await pauseBackgroundMusic();
    }
    
    if (!_isNightmareMusicPlaying) {
      try {
        await _nightmareMusic.play(
          AssetSource('sounds/cyberpunk-231946.mp3'),
          mode: PlayerMode.mediaPlayer,
        );
        await _nightmareMusic.setReleaseMode(ReleaseMode.loop);
        _isNightmareMusicPlaying = true;
      } catch (e) {
        // Manejo silencioso de errores para evitar crasheos
        _isNightmareMusicPlaying = false;
      }
    }
  }

  // Nuevo método para reproducir efectos de sonido
  Future<void> playSoundEffect(String soundAsset) async {
    try {
      // Usar volumen fijo para efectos de sonido
      double effectVolume = 0.7;
      
      // Usar playerMode.lowLatency para efectos cortos
      await _soundEffects.play(
        AssetSource(soundAsset),
        mode: PlayerMode.lowLatency,
        volume: effectVolume,
      );
      
      // Asegurar que el modo de liberación sea adecuado para efectos de sonido
      await _soundEffects.setReleaseMode(ReleaseMode.release);
      
      // Si hay interrupción de la música, reanudarla
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_isMusicPlaying) {
          _backgroundMusic.resume();
        } else if (_isNightmareMusicPlaying) {
          _nightmareMusic.resume();
        }
      });
    } catch (e) {
      // Manejo silencioso de errores
    }
  }

  Future<void> stopNightmareMusic() async {
    if (_isNightmareMusicPlaying) {
      await _nightmareMusic.stop();
      _isNightmareMusicPlaying = false;
      
      // Reanudar música normal si estaba reproduciéndose antes
      if (_isMusicPlaying) {
        await resumeBackgroundMusic();
      }
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (_isMusicPlaying) {
      await _backgroundMusic.stop();
      _isMusicPlaying = false;
    }
  }

  Future<void> pauseBackgroundMusic() async {
    if (_isMusicPlaying) {
      await _backgroundMusic.pause();
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (_isMusicPlaying) {
      await _backgroundMusic.resume();
    } else {
      await playBackgroundMusic();
    }
  }

  Future<void> setVolume(double volume) async {
    await _backgroundMusic.setVolume(volume);
    await _nightmareMusic.setVolume(volume);
    await _soundEffects.setVolume(volume);
  }

  void dispose() {
    _backgroundMusic.dispose();
    _nightmareMusic.dispose();
    _soundEffects.dispose();
  }
} 