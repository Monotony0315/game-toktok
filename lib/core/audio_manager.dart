import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

/// Audio Manager for Game-TokTok
/// Handles background music, sound effects, and Toki voice
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Audio players
  late AudioPlayer _bgmPlayer;
  late AudioPlayer _sfxPlayer;
  late AudioPlayer _voicePlayer;
  
  // State
  bool _isInitialized = false;
  bool _isMuted = false;
  double _bgmVolume = 0.5;
  double _sfxVolume = 0.7;
  double _voiceVolume = 0.8;
  
  // Current BGM track
  String? _currentBgm;

  // Sound effect cache
  final Map<String, String> _soundPaths = {
    // UI Sounds
    'pop': 'sounds/pop.mp3',
    'click': 'sounds/click.mp3',
    'success': 'sounds/success.mp3',
    'fail': 'sounds/fail.mp3',
    'win': 'sounds/win.mp3',
    'level_up': 'sounds/level_up.mp3',
    
    // Game Sounds
    'merge': 'sounds/merge.mp3',
    'drop': 'sounds/drop.mp3',
    'splash': 'sounds/splash.mp3',
    'eat': 'sounds/eat.mp3',
    'move': 'sounds/move.mp3',
    
    // Toki Voice
    'toki_greeting': 'sounds/toki_greeting.mp3',
    'toki_happy': 'sounds/toki_happy.mp3',
    'toki_sad': 'sounds/toki_sad.mp3',
    'toki_encourage': 'sounds/toki_encourage.mp3',
    'toki_congrats': 'sounds/toki_congrats.mp3',
    'toki_click': 'sounds/toki_click.mp3',
  };

  // Getters
  bool get isMuted => _isMuted;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  double get voiceVolume => _voiceVolume;

  /// Initialize the audio manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    _voicePlayer = AudioPlayer();

    // Configure players
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
    await _voicePlayer.setReleaseMode(ReleaseMode.release);

    // Set initial volumes
    await _updateVolumes();

    _isInitialized = true;
  }

  /// Update volumes based on current settings
  Future<void> _updateVolumes() async {
    if (!_isInitialized) return;
    
    final effectiveMute = _isMuted ? 0.0 : 1.0;
    await _bgmPlayer.setVolume(_bgmVolume * effectiveMute);
    await _sfxPlayer.setVolume(_sfxVolume * effectiveMute);
    await _voicePlayer.setVolume(_voiceVolume * effectiveMute);
  }

  /// Play background music
  Future<void> playBgm(String track, {bool fadeIn = true}) async {
    if (!_isInitialized) await initialize();
    
    if (_currentBgm == track) return;
    _currentBgm = track;

    try {
      if (fadeIn) {
        await _bgmPlayer.setVolume(0);
        await _bgmPlayer.play(AssetSource('sounds/bgm/$track.mp3'));
        
        // Fade in
        for (var i = 0; i <= 10; i++) {
          await Future.delayed(const Duration(milliseconds: 50));
          await _bgmPlayer.setVolume((_bgmVolume * i / 10) * (_isMuted ? 0 : 1));
        }
      } else {
        await _bgmPlayer.play(AssetSource('sounds/bgm/$track.mp3'));
      }
    } catch (e) {
      print('Error playing BGM: $e');
    }
  }

  /// Stop background music
  Future<void> stopBgm({bool fadeOut = true}) async {
    if (!_isInitialized) return;
    
    try {
      if (fadeOut) {
        final currentVol = await _bgmPlayer.volume;
        for (var i = 10; i >= 0; i--) {
          await _bgmPlayer.setVolume(currentVol * i / 10);
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
      await _bgmPlayer.stop();
      _currentBgm = null;
    } catch (e) {
      print('Error stopping BGM: $e');
    }
  }

  /// Pause background music
  Future<void> pauseBgm() async {
    if (!_isInitialized) return;
    await _bgmPlayer.pause();
  }

  /// Resume background music
  Future<void> resumeBgm() async {
    if (!_isInitialized) return;
    if (!_isMuted) {
      await _bgmPlayer.resume();
    }
  }

  /// Play a sound effect
  Future<void> playSfx(String soundKey) async {
    if (!_isInitialized) await initialize();
    if (_isMuted) return;

    final path = _soundPaths[soundKey];
    if (path == null) {
      print('Sound not found: $soundKey');
      return;
    }

    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(path));
    } catch (e) {
      print('Error playing SFX: $e');
    }
  }

  /// Play Toki voice
  Future<void> playVoice(String voiceKey) async {
    if (!_isInitialized) await initialize();
    if (_isMuted) return;

    final path = _soundPaths[voiceKey];
    if (path == null) return;

    try {
      await _voicePlayer.stop();
      await _voicePlayer.play(AssetSource(path));
    } catch (e) {
      print('Error playing voice: $e');
    }
  }

  /// Play random Toki greeting
  Future<void> playRandomGreeting() async {
    final greetings = ['toki_greeting', 'toki_happy', 'toki_click'];
    final random = DateTime.now().millisecond % greetings.length;
    await playVoice(greetings[random]);
  }

  /// Play random encouragement
  Future<void> playEncouragement() async {
    await playVoice('toki_encourage');
  }

  /// Play success sound with Toki congrats
  Future<void> playSuccess() async {
    await Future.wait([
      playSfx('success'),
      playVoice('toki_congrats'),
    ]);
  }

  /// Toggle mute
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _updateVolumes();
    
    if (_isMuted) {
      await _bgmPlayer.pause();
    } else {
      await _bgmPlayer.resume();
    }
  }

  /// Set mute state
  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    await _updateVolumes();
    
    if (_isMuted) {
      await _bgmPlayer.pause();
    } else {
      await _bgmPlayer.resume();
    }
  }

  /// Set BGM volume (0.0 to 1.0)
  Future<void> setBgmVolume(double volume) async {
    _bgmVolume = volume.clamp(0.0, 1.0);
    await _updateVolumes();
  }

  /// Set SFX volume (0.0 to 1.0)
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _updateVolumes();
  }

  /// Set voice volume (0.0 to 1.0)
  Future<void> setVoiceVolume(double volume) async {
    _voiceVolume = volume.clamp(0.0, 1.0);
    await _updateVolumes();
  }

  /// Dispose all players
  Future<void> dispose() async {
    if (!_isInitialized) return;
    
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
    await _voicePlayer.dispose();
    _isInitialized = false;
  }
}

/// Extension for easy access
extension AudioManagerExtension on AudioManager {
  /// Quick play methods for common sounds
  Future<void> pop() => playSfx('pop');
  Future<void> click() => playSfx('click');
  Future<void> success() => playSfx('success');
  Future<void> fail() => playSfx('fail');
  Future<void> win() => playSfx('win');
  Future<void> merge() => playSfx('merge');
  Future<void> drop() => playSfx('drop');
}
