import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  
  // Para música de fondo
  final AudioPlayer _backgroundMusic = AudioPlayer();
  final AudioPlayer _nightmareMusic = AudioPlayer();
  bool _isMusicPlaying = false;
  bool _isNightmareMusicPlaying = false;

  // Para efectos de sonido
  final AudioPlayer _soundEffectPlayer = AudioPlayer();

  factory AudioService() {
    return _instance;
  }

  AudioService._internal() {
    // Configuración inicial de los reproductores
    _initializeAudioPlayers();
  }
  
  // Método para inicializar todos los reproductores de audio
  Future<void> _initializeAudioPlayers() async {
    try {
      // Configurar reproducción en bucle para música
      await _backgroundMusic.setReleaseMode(ReleaseMode.loop);
      await _nightmareMusic.setReleaseMode(ReleaseMode.loop);
      
      // Configurar reproducción única para efectos
      await _soundEffectPlayer.setReleaseMode(ReleaseMode.release);
      
      // Establecer volumen
      await _backgroundMusic.setVolume(1.0);
      await _nightmareMusic.setVolume(1.0);
      await _soundEffectPlayer.setVolume(0.8); // Volumen ligeramente más bajo para efectos
    } catch (e) {
      // Ignorar errores de inicialización
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_isMusicPlaying) {
      try {
        // Detener cualquier música de pesadilla que esté sonando
        if (_isNightmareMusicPlaying) {
          _nightmareMusic.stop();
          _isNightmareMusicPlaying = false;
        }
        
        // Configurar el reproductor en modo de bucle
        await _backgroundMusic.setReleaseMode(ReleaseMode.loop);
        await _backgroundMusic.setVolume(1.0);
        
        // Reproducir la música
        await _backgroundMusic.play(
          AssetSource('sounds/denial-of-service-sci-fi-hacker-instrumental-267766.mp3'),
          mode: PlayerMode.mediaPlayer,
        );
        
        _isMusicPlaying = true;
      } catch (e) {
        _isMusicPlaying = false;
      }
    }
  }

  Future<void> playNightmareMusic() async {
    // Pausar la música normal si está reproduciéndose
    if (_isMusicPlaying) {
      await _backgroundMusic.stop();
      _isMusicPlaying = false;
    }
    
    if (!_isNightmareMusicPlaying) {
      try {
        // Configurar el reproductor en modo de bucle
        await _nightmareMusic.setReleaseMode(ReleaseMode.loop);
        await _nightmareMusic.setVolume(1.0);
        
        // Reproducir la música
        await _nightmareMusic.play(
          AssetSource('sounds/cyberpunk-231946.mp3'),
          mode: PlayerMode.mediaPlayer,
        );
        
        _isNightmareMusicPlaying = true;
      } catch (e) {
        _isNightmareMusicPlaying = false;
      }
    }
  }

  // Método simple para reproducir efectos de sonido
  Future<void> playSoundEffect(String soundAsset) async {
    try {
      // Reproducir sin esperar a que termine
      _soundEffectPlayer.play(AssetSource(soundAsset));
      
      // Asegurar que la música siga reproduciéndose
      if (_isMusicPlaying) {
        Future.delayed(Duration(milliseconds: 50), () {
          _backgroundMusic.resume();
        });
      } else if (_isNightmareMusicPlaying) {
        Future.delayed(Duration(milliseconds: 50), () {
          _nightmareMusic.resume();
        });
      }
    } catch (e) {
      // Ignorar errores silenciosamente
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
    await _soundEffectPlayer.setVolume(volume);
  }

  void dispose() {
    _backgroundMusic.dispose();
    _nightmareMusic.dispose();
    _soundEffectPlayer.dispose();
  }
} 