import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _backgroundMusic = AudioPlayer();
  final AudioPlayer _nightmareMusic = AudioPlayer();
  bool _isMusicPlaying = false;
  bool _isNightmareMusicPlaying = false;

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
  }

  void dispose() {
    _backgroundMusic.dispose();
    _nightmareMusic.dispose();
  }
} 