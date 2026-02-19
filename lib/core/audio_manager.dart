import 'package:flame_audio/flame_audio.dart';
import 'dart:async';
import 'storage.dart';

/// Audio Manager for Game-TokTok
/// Handles background music, sound effects, and Toki voice using Flame Audio
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // State
  bool _isInitialized = false;
  bool _isMuted = false;
  double _bgmVolume = 0.5;
  double _sfxVolume = 0.7;
  double _voiceVolume = 0.8;
  
  // Current BGM track
  String? _currentBgm;

  // Sound effect cache - maps sound keys to file paths
  final Map<String, String> _soundPaths = {
    // UI Sounds
    'pop': 'pop.mp3',
    'click': 'click.mp3',
    'success': 'success.mp3',
    'fail': 'fail.mp3',
    'win': 'win.mp3',
    'level_up': 'level_up.mp3',
    
    // Game Sounds
    'merge': 'merge.mp3',
    'drop': 'drop.mp3',
    'splash': 'splash.mp3',
    'eat': 'eat.mp3',
    'move': 'move.mp3',
    
    // Combo sounds
    'combo_1': 'combo1.mp3',
    'combo_2': 'combo2.mp3',
    'combo_3': 'combo3.mp3',
    'combo_4': 'combo4.mp3',
    'combo_5': 'combo5.mp3',
    
    // Toki Voice
    'toki_greeting': 'toki_greeting.mp3',
    'toki_happy': 'toki_happy.mp3',
    'toki_sad': 'toki_sad.mp3',
    'toki_encourage': 'toki_encourage.mp3',
    'toki_congrats': 'toki_congrats.mp3',
    'toki_click': 'toki_click.mp3',
  };

  // Getters
  bool get isMuted => _isMuted;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  double get voiceVolume => _voiceVolume;
  String? get currentBgm => _currentBgm;

  /// Initialize the audio manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Flame Audio
    FlameAudio.bgm.initialize();
    
    // Set initial volumes
    await _updateVolumes();

    _isInitialized = true;
  }

  /// Update volumes based on current settings
  Future<void> _updateVolumes() async {
    if (!_isInitialized) return;
    
    final effectiveMute = _isMuted ? 0.0 : 1.0;
    FlameAudio.bgm.audioPlayer.setVolume(_bgmVolume * effectiveMute);
  }

  /// Preload commonly used sounds for better performance
  Future<void> preloadSounds() async {
    if (!_isInitialized) return;
    
    // Preload essential sounds
    final essentialSounds = ['click', 'pop', 'success', 'fail'];
    for (final sound in essentialSounds) {
      final path = _soundPaths[sound];
      if (path != null) {
        try {
          await FlameAudio.audioCache.load('sounds/$path');
        } catch (e) {
          print('Failed to preload sound: $sound');
        }
      }
    }
  }

  /// Play background music
  Future<void> playBgm(String track, {bool fadeIn = true}) async {
    if (!_isInitialized) await initialize();
    
    if (_currentBgm == track) return;
    _currentBgm = track;

    try {
      if (_isMuted) return;
      
      await FlameAudio.bgm.play('sounds/bgm/$track.mp3', volume: _bgmVolume);
    } catch (e) {
      print('Error playing BGM: $e');
    }
  }

  /// Stop background music
  Future<void> stopBgm({bool fadeOut = true}) async {
    if (!_isInitialized) return;
    
    try {
      await FlameAudio.bgm.stop();
      _currentBgm = null;
    } catch (e) {
      print('Error stopping BGM: $e');
    }
  }

  /// Pause background music
  Future<void> pauseBgm() async {
    if (!_isInitialized) return;
    await FlameAudio.bgm.pause();
  }

  /// Resume background music
  Future<void> resumeBgm() async {
    if (!_isInitialized) return;
    if (!_isMuted && _currentBgm != null) {
      await FlameAudio.bgm.resume();
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
      await FlameAudio.play('sounds/$path', volume: _sfxVolume);
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
      await FlameAudio.play('sounds/$path', volume: _voiceVolume);
    } catch (e) {
      print('Error playing voice: $e');
    }
  }

  /// Play random Toki greeting
  Future<void> playRandomGreeting() async {
    final greetings = ['toki_greeting', 'toki_happy', 'toki_click'];
    final index = DateTime.now().millisecond % greetings.length;
    await playVoice(greetings[index]);
  }

  /// Play random encouragement
  Future<void> playEncouragement() async {
    await playVoice('toki_encourage');
  }

  /// Play success sound with Toki congrats
  Future<void> playSuccess() async {
    await playSfx('success');
    await playVoice('toki_congrats');
  }

  /// Toggle mute
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _updateVolumes();
    
    if (_isMuted) {
      await pauseBgm();
    } else {
      await resumeBgm();
    }
    
    // Save to storage
    final storage = GameStorage();
    await storage.setSoundEnabled(!_isMuted);
  }

  /// Set mute state
  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    await _updateVolumes();
    
    if (_isMuted) {
      await pauseBgm();
    } else {
      await resumeBgm();
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
  }

  /// Set voice volume (0.0 to 1.0)
  Future<void> setVoiceVolume(double volume) async {
    _voiceVolume = volume.clamp(0.0, 1.0);
  }

  /// Dispose audio resources
  Future<void> dispose() async {
    if (!_isInitialized) return;
    
    await FlameAudio.bgm.stop();
    await FlameAudio.bgm.dispose();
    _isInitialized = false;
  }
}

/// Extension for easy access to common sounds
extension AudioManagerExtension on AudioManager {
  /// Quick play methods for common sounds
  Future<void> pop() => playSfx('pop');
  Future<void> click() => playSfx('click');
  Future<void> success() => playSfx('success');
  Future<void> fail() => playSfx('fail');
  Future<void> win() => playSfx('win');
  Future<void> merge() => playSfx('merge');
  Future<void> drop() => playSfx('drop');
  Future<void> move() => playSfx('move');
  Future<void> splash() => playSfx('splash');
  Future<void> eat() => playSfx('eat');
  Future<void> levelUp() => playSfx('level_up');
}
