import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _backgroundMusic = AudioPlayer();
  bool _isMusicPlaying = false;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  Future<void> playBackgroundMusic() async {
    if (!_isMusicPlaying) {
      await _backgroundMusic.play(
        AssetSource('sounds/denial-of-service-sci-fi-hacker-instrumental-267766.mp3'),
        mode: PlayerMode.mediaPlayer,
      );
      await _backgroundMusic.setReleaseMode(ReleaseMode.loop);
      _isMusicPlaying = true;
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
  }

  void dispose() {
    _backgroundMusic.dispose();
  }
} 