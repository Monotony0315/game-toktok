import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Game Storage Manager
/// Handles high scores, game settings, and player preferences
class GameStorage {
  static final GameStorage _instance = GameStorage._internal();
  factory GameStorage() => _instance;
  GameStorage._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // Cache for performance
  final Map<String, dynamic> _cache = {};

  /// Initialize storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    
    // Preload high scores into cache
    await _preloadHighScores();
  }

  /// Preload all high scores for faster access
  Future<void> _preloadHighScores() async {
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key.startsWith('highscore_')) {
        _cache[key] = _prefs?.getInt(key) ?? 0;
      }
    }
  }

  // ==================== HIGH SCORES ====================

  /// Get high score for a specific game
  int getHighScore(String gameId) {
    final key = 'highscore_$gameId';
    if (_cache.containsKey(key)) {
      return _cache[key] as int;
    }
    final score = _prefs?.getInt(key) ?? 0;
    _cache[key] = score;
    return score;
  }

  /// Save high score for a specific game
  Future<bool> saveHighScore(String gameId, int score) async {
    final key = 'highscore_$gameId';
    final currentHigh = getHighScore(gameId);
    
    if (score > currentHigh) {
      _cache[key] = score;
      return await _prefs?.setInt(key, score) ?? false;
    }
    return false;
  }

  /// Get all high scores
  Map<String, int> getAllHighScores() {
    final scores = <String, int>{};
    const gameIds = [
      'snake',
      'fruit_merge',
      'balloon_merge',
      'water_sort',
      'sudoku',
      'color_connect',
    ];
    
    for (final gameId in gameIds) {
      scores[gameId] = getHighScore(gameId);
    }
    return scores;
  }

  /// Get total score across all games
  int getTotalScore() {
    return getAllHighScores().values.fold(0, (sum, score) => sum + score);
  }

  /// Reset high score for a game
  Future<bool> resetHighScore(String gameId) async {
    final key = 'highscore_$gameId';
    _cache.remove(key);
    return await _prefs?.remove(key) ?? false;
  }

  /// Reset all high scores
  Future<bool> resetAllHighScores() async {
    final keys = _prefs?.getKeys().where((k) => k.startsWith('highscore_')) ?? [];
    for (final key in keys) {
      _cache.remove(key);
      await _prefs?.remove(key);
    }
    return true;
  }

  // ==================== GAME SETTINGS ====================

  /// Sound enabled
  bool get soundEnabled {
    return _prefs?.getBool('setting_sound_enabled') ?? true;
  }

  Future<bool> setSoundEnabled(bool enabled) async {
    return await _prefs?.setBool('setting_sound_enabled', enabled) ?? false;
  }

  /// Music enabled
  bool get musicEnabled {
    return _prefs?.getBool('setting_music_enabled') ?? true;
  }

  Future<bool> setMusicEnabled(bool enabled) async {
    return await _prefs?.setBool('setting_music_enabled', enabled) ?? false;
  }

  /// Volume levels (0.0 to 1.0)
  double get bgmVolume {
    return _prefs?.getDouble('setting_bgm_volume') ?? 0.5;
  }

  Future<bool> setBgmVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    return await _prefs?.setDouble('setting_bgm_volume', clamped) ?? false;
  }

  double get sfxVolume {
    return _prefs?.getDouble('setting_sfx_volume') ?? 0.7;
  }

  Future<bool> setSfxVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    return await _prefs?.setDouble('setting_sfx_volume', clamped) ?? false;
  }

  double get voiceVolume {
    return _prefs?.getDouble('setting_voice_volume') ?? 0.8;
  }

  Future<bool> setVoiceVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    return await _prefs?.setDouble('setting_voice_volume', clamped) ?? false;
  }

  /// Haptic feedback enabled
  bool get hapticEnabled {
    return _prefs?.getBool('setting_haptic_enabled') ?? true;
  }

  Future<bool> setHapticEnabled(bool enabled) async {
    return await _prefs?.setBool('setting_haptic_enabled', enabled) ?? false;
  }

  /// Notifications enabled
  bool get notificationsEnabled {
    return _prefs?.getBool('setting_notifications_enabled') ?? true;
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await _prefs?.setBool('setting_notifications_enabled', enabled) ?? false;
  }

  /// Difficulty level
  GameDifficulty get difficulty {
    final value = _prefs?.getString('setting_difficulty') ?? 'normal';
    return GameDifficulty.fromString(value);
  }

  Future<bool> setDifficulty(GameDifficulty difficulty) async {
    return await _prefs?.setString('setting_difficulty', difficulty.value) ?? false;
  }

  // ==================== PLAYER STATS ====================

  /// Save game session stats
  Future<bool> saveGameStats({
    required String gameId,
    required int score,
    required double duration,
  }) async {
    final stats = GameStats(
      gameId: gameId,
      score: score,
      duration: duration,
      playedAt: DateTime.now(),
    );
    
    // Add to history
    final history = getGameHistory(gameId);
    history.add(stats);
    
    // Keep only last 100 games
    if (history.length > 100) {
      history.removeAt(0);
    }
    
    // Save history
    final key = 'history_$gameId';
    final jsonList = history.map((s) => s.toJson()).toList();
    return await _prefs?.setString(key, jsonEncode(jsonList)) ?? false;
  }

  /// Get game history
  List<GameStats> getGameHistory(String gameId) {
    final key = 'history_$gameId';
    final jsonString = _prefs?.getString(key);
    
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((j) => GameStats.fromJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get total play time for a game
  double getTotalPlayTime(String gameId) {
    final history = getGameHistory(gameId);
    return history.fold(0.0, (sum, stat) => sum + stat.duration);
  }

  /// Get total games played
  int getTotalGamesPlayed(String gameId) {
    return getGameHistory(gameId).length;
  }

  /// Get average score
  double getAverageScore(String gameId) {
    final history = getGameHistory(gameId);
    if (history.isEmpty) return 0.0;
    return history.fold(0, (sum, stat) => sum + stat.score) / history.length;
  }

  // ==================== ACHIEVEMENTS ====================

  /// Check if achievement is unlocked
  bool isAchievementUnlocked(String achievementId) {
    final key = 'achievement_$achievementId';
    return _prefs?.getBool(key) ?? false;
  }

  /// Unlock achievement
  Future<bool> unlockAchievement(String achievementId) async {
    final key = 'achievement_$achievementId';
    if (isAchievementUnlocked(achievementId)) return true;
    
    return await _prefs?.setBool(key, true) ?? false;
  }

  /// Get all unlocked achievements
  List<String> getUnlockedAchievements() {
    final achievements = <String>[];
    final keys = _prefs?.getKeys() ?? {};
    
    for (final key in keys) {
      if (key.startsWith('achievement_')) {
        final isUnlocked = _prefs?.getBool(key) ?? false;
        if (isUnlocked) {
          achievements.add(key.replaceFirst('achievement_', ''));
        }
      }
    }
    return achievements;
  }

  // ==================== GAME STATE (for resume) ====================

  /// Save game state for resume
  Future<bool> saveGameState(String gameId, Map<String, dynamic> state) async {
    final key = 'state_$gameId';
    return await _prefs?.setString(key, jsonEncode(state)) ?? false;
  }

  /// Load game state
  Map<String, dynamic>? loadGameState(String gameId) {
    final key = 'state_$gameId';
    final jsonString = _prefs?.getString(key);
    
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Clear game state
  Future<bool> clearGameState(String gameId) async {
    final key = 'state_$gameId';
    return await _prefs?.remove(key) ?? false;
  }

  /// Check if there's a saved game
  bool hasSavedGame(String gameId) {
    final key = 'state_$gameId';
    return _prefs?.containsKey(key) ?? false;
  }

  // ==================== ADS ====================

  /// Ad-free purchase status
  bool get isAdFree {
    return _prefs?.getBool('purchase_ad_free') ?? false;
  }

  Future<bool> setAdFree(bool value) async {
    return await _prefs?.setBool('purchase_ad_free', value) ?? false;
  }

  /// Last ad shown timestamp
  DateTime? get lastAdShown {
    final timestamp = _prefs?.getInt('last_ad_shown');
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<bool> updateLastAdShown() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return await _prefs?.setInt('last_ad_shown', now) ?? false;
  }

  /// Games played since last ad
  int get gamesSinceLastAd {
    return _prefs?.getInt('games_since_ad') ?? 0;
  }

  Future<bool> incrementGamesSinceAd() async {
    final count = gamesSinceLastAd + 1;
    return await _prefs?.setInt('games_since_ad', count) ?? false;
  }

  Future<bool> resetGamesSinceAd() async {
    return await _prefs?.setInt('games_since_ad', 0) ?? false;
  }

  // ==================== FIRST RUN ====================

  /// Check if first run
  bool get isFirstRun {
    return _prefs?.getBool('first_run') ?? true;
  }

  Future<bool> setFirstRunComplete() async {
    return await _prefs?.setBool('first_run', false) ?? false;
  }

  /// Tutorial completed
  bool isTutorialCompleted(String tutorialId) {
    return _prefs?.getBool('tutorial_$tutorialId') ?? false;
  }

  Future<bool> setTutorialCompleted(String tutorialId) async {
    return await _prefs?.setBool('tutorial_$tutorialId', true) ?? false;
  }

  // ==================== CLEAR ALL ====================

  /// Clear all data (factory reset)
  Future<bool> clearAllData() async {
    final keys = _prefs?.getKeys().toList() ?? [];
    for (final key in keys) {
      await _prefs?.remove(key);
    }
    _cache.clear();
    return true;
  }
}

/// Game difficulty levels
enum GameDifficulty {
  easy('easy'),
  normal('normal'),
  hard('hard');

  final String value;
  const GameDifficulty(this.value);

  static GameDifficulty fromString(String value) {
    return GameDifficulty.values.firstWhere(
      (d) => d.value == value,
      orElse: () => GameDifficulty.normal,
    );
  }
}

/// Game stats model
class GameStats {
  final String gameId;
  final int score;
  final double duration;
  final DateTime playedAt;

  GameStats({
    required this.gameId,
    required this.score,
    required this.duration,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'score': score,
      'duration': duration,
      'playedAt': playedAt.toIso8601String(),
    };
  }

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      gameId: json['gameId'] as String,
      score: json['score'] as int,
      duration: json['duration'] as double,
      playedAt: DateTime.parse(json['playedAt'] as String),
    );
  }
}

/// Achievement definitions
class Achievements {
  Achievements._();

  // General achievements
  static const String firstWin = 'first_win';
  static const String score1000 = 'score_1000';
  static const String score5000 = 'score_5000';
  static const String score10000 = 'score_10000';
  static const String play10Games = 'play_10_games';
  static const String play50Games = 'play_50_games';
  static const String play100Games = 'play_100_games';
  static const String masterAllGames = 'master_all_games';

  // Game-specific achievements
  static const String snakeMaster = 'snake_master';
  static const String fruitMergeMaster = 'fruit_merge_master';
  static const String balloonMergeMaster = 'balloon_merge_master';
  static const String waterSortMaster = 'water_sort_master';
  static const String sudokuMaster = 'sudoku_master';
  static const String colorConnectMaster = 'color_connect_master';
}
