import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/storage.dart';

/// Base game engine for all Game-TokTok mini-games
/// Provides common functionality: pause/resume, scoring, timing, and lifecycle management
abstract class TokiBaseGame extends FlameGame {
  // Core managers
  final AudioManager _audio = AudioManager();
  final GameStorage _storage = GameStorage();
  
  // Game state
  bool _isPaused = false;
  bool _isGameOver = false;
  bool _isInitialized = false;
  
  // Scoring
  int _score = 0;
  int _highScore = 0;
  final String _gameId;
  
  // Timing
  double _gameTime = 0.0;
  double? _timeLimit;
  
  // Callbacks
  VoidCallback? onScoreChanged;
  VoidCallback? onGameOver;
  VoidCallback? onPauseChanged;

  // Getters
  bool get isPaused => _isPaused;
  bool get isGameOver => _isGameOver;
  bool get isPlaying => !_isPaused && !_isGameOver;
  int get score => _score;
  int get highScore => _highScore;
  double get gameTime => _gameTime;
  double? get timeLimit => _timeLimit;
  AudioManager get audio => _audio;
  GameStorage get storage => _storage;
  String get gameId => _gameId;

  TokiBaseGame({
    required String gameId,
    double? timeLimit,
  })  : _gameId = gameId,
        _timeLimit = timeLimit;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Initialize managers
    await _audio.initialize();
    await _storage.initialize();
    
    // Load high score
    _highScore = await _storage.getHighScore(_gameId);
    
    // Add pause overlay component
    await add(PauseOverlayComponent(
      onPause: pauseGame,
      onResume: resumeGame,
    ));
    
    _isInitialized = true;
  }

  @override
  void update(double dt) {
    if (!_isInitialized || _isPaused || _isGameOver) return;
    
    super.update(dt);
    
    // Update game time
    _gameTime += dt;
    
    // Check time limit
    if (_timeLimit != null && _gameTime >= _timeLimit!) {
      endGame();
    }
    
    // Update logic in subclass
    onUpdate(dt);
  }

  /// Override this for game-specific update logic
  void onUpdate(double dt);

  /// Add points to score
  void addScore(int points) {
    if (_isGameOver) return;
    
    _score += points;
    
    // Check for high score
    if (_score > _highScore) {
      _highScore = _score;
      _storage.saveHighScore(_gameId, _highScore);
    }
    
    onScoreChanged?.call();
  }

  /// Set score directly
  void setScore(int score) {
    _score = score;
    
    if (_score > _highScore) {
      _highScore = _score;
      _storage.saveHighScore(_gameId, _highScore);
    }
    
    onScoreChanged?.call();
  }

  /// Reset game state
  void resetGame() {
    _score = 0;
    _gameTime = 0.0;
    _isPaused = false;
    _isGameOver = false;
    onScoreChanged?.call();
  }

  /// Pause the game
  void pauseGame() {
    if (_isGameOver) return;
    
    _isPaused = true;
    _audio.pauseBgm();
    onPauseChanged?.call();
    
    // Pause all game components
    for (final component in children) {
      if (component is UpdateMixin) {
        component.removeFromParent();
      }
    }
  }

  /// Resume the game
  void resumeGame() {
    if (_isGameOver) return;
    
    _isPaused = false;
    _audio.resumeBgm();
    onPauseChanged?.call();
  }

  /// End the game
  void endGame() {
    if (_isGameOver) return;
    
    _isGameOver = true;
    _audio.stopBgm();
    
    // Save final stats
    _storage.saveGameStats(
      gameId: _gameId,
      score: _score,
      duration: _gameTime,
    );
    
    onGameOver?.call();
  }

  /// Start a new game session
  Future<void> startNewGame() async {
    resetGame();
    await onGameStart();
  }

  /// Override for game-specific start logic
  Future<void> onGameStart();

  @override
  void onRemove() {
    _audio.dispose();
    super.onRemove();
  }
}

/// Pause overlay component for all games
class PauseOverlayComponent extends Component with HasGameRef<TokiBaseGame>, TapCallbacks {
  final VoidCallback onPause;
  final VoidCallback onResume;
  
  PauseOverlayComponent({
    required this.onPause,
    required this.onResume,
  });

  @override
  void render(Canvas canvas) {
    if (!gameRef.isPaused) return;
    
    // Semi-transparent overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y),
      Paint()..color = const Color(0xCC000000),
    );
    
    // Draw pause text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'PAUSED',
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (gameRef.size.x - textPainter.width) / 2,
        (gameRef.size.y - textPainter.height) / 2,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameRef.isPaused) {
      onResume();
    } else {
      onPause();
    }
  }
}

/// Mixin for games that need grid-based logic
mixin GridGameMixin on TokiBaseGame {
  late int gridWidth;
  late int gridHeight;
  late double cellSize;
  
  void initializeGrid(int width, int height) {
    gridWidth = width;
    gridHeight = height;
    cellSize = size.x / gridWidth;
    
    // Adjust cell size based on aspect ratio
    if (cellSize * gridHeight > size.y) {
      cellSize = size.y / gridHeight;
    }
  }

  Vector2 gridToWorld(int x, int y) {
    return Vector2(
      x * cellSize + cellSize / 2,
      y * cellSize + cellSize / 2,
    );
  }

  Point<int> worldToGrid(Vector2 worldPos) {
    return Point<int>(
      (worldPos.x / cellSize).floor(),
      (worldPos.y / cellSize).floor(),
    );
  }
}

/// Mixin for games with levels
mixin LevelGameMixin on TokiBaseGame {
  int _currentLevel = 1;
  int _maxLevel = 100;
  
  int get currentLevel => _currentLevel;
  int get maxLevel => _maxLevel;
  
  void nextLevel() {
    _currentLevel++;
    if (_currentLevel > _maxLevel) _currentLevel = _maxLevel;
    onLevelChanged(_currentLevel);
  }
  
  void setLevel(int level) {
    _currentLevel = level.clamp(1, _maxLevel);
    onLevelChanged(_currentLevel);
  }
  
  void onLevelChanged(int level);
}

/// Mixin for games with combo/multiplier systems
mixin ComboGameMixin on TokiBaseGame {
  int _combo = 0;
  double _comboTimer = 0.0;
  double _comboWindow = 3.0; // seconds
  double _multiplier = 1.0;
  
  int get combo => _combo;
  double get multiplier => _multiplier;
  
  void incrementCombo() {
    _combo++;
    _comboTimer = _comboWindow;
    _updateMultiplier();
    audio.playSfx('combo_${_combo.clamp(1, 5)}');
  }
  
  void resetCombo() {
    _combo = 0;
    _comboTimer = 0.0;
    _multiplier = 1.0;
  }
  
  void _updateMultiplier() {
    // Exponential multiplier growth
    _multiplier = 1.0 + (_combo * 0.1);
    if (_multiplier > 5.0) _multiplier = 5.0;
  }
  
  @override
  void onUpdate(double dt) {
    super.onUpdate(dt);
    
    if (_combo > 0) {
      _comboTimer -= dt;
      if (_comboTimer <= 0) {
        resetCombo();
      }
    }
  }
  
  int calculateScore(int basePoints) {
    return (basePoints * _multiplier).round();
  }
}

/// Game state enum
enum GameState {
  idle,
  playing,
  paused,
  gameOver,
  victory,
}
