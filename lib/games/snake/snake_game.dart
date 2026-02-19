import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class SnakeGame extends FlameGame with PanDetector, HasCollisionDetection {
  static const int gridSize = 20;
  static const double cellSize = 25.0;
  static const double gameSpeed = 0.15;
  
  late Snake _snake;
  late Fruit _fruit;
  late Timer _moveTimer;
  
  int score = 0;
  bool isGameOver = false;
  
  Vector2? _dragStart;
  Vector2? _dragEnd;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Pastel background
    camera.viewfinder.anchor = Anchor.topLeft;
    
    restart();
  }

  void restart() {
    removeAll(children);
    score = 0;
    isGameOver = false;
    overlays.remove('gameOver');
    overlays.add('score');
    
    // Create game area background
    add(GameArea());
    
    // Initialize snake in center
    final centerX = (size.x / 2 / cellSize).floor() * cellSize;
    final centerY = (size.y / 2 / cellSize).floor() * cellSize;
    
    _snake = Snake(
      position: Vector2(centerX, centerY),
    );
    add(_snake);
    
    // Spawn first fruit
    _spawnFruit();
    
    // Start movement timer
    _moveTimer = Timer(gameSpeed, repeat: true, onTick: _updateGame);
    _moveTimer.start();
  }

  void _spawnFruit() {
    final random = Random();
    Vector2 position;
    
    do {
      final x = random.nextInt((size.x / cellSize).floor()) * cellSize + cellSize / 2;
      final y = random.nextInt((size.y / cellSize).floor()) * cellSize + cellSize / 2;
      position = Vector2(x, y);
    } while (_snake.occupies(position));
    
    _fruit = Fruit(position: position);
    add(_fruit);
  }

  void _updateGame() {
    if (isGameOver) return;
    
    _snake.move();
    
    // Check collision with fruit
    if (_snake.headPosition.distanceTo(_fruit.position) < cellSize) {
      score += 10;
      _snake.grow();
      remove(_fruit);
      _spawnFruit();
      overlays.remove('score');
      overlays.add('score');
    }
    
    // Check collision with walls or self
    if (_snake.checkCollision(size)) {
      gameOver();
    }
  }

  void gameOver() {
    isGameOver = true;
    _moveTimer.stop();
    overlays.remove('score');
    overlays.add('gameOver');
  }

  @override
  void onPanStart(DragStartInfo info) {
    _dragStart = info.eventPosition.global;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (_dragStart == null || isGameOver) return;
    
    _dragEnd = info.eventPosition.global;
    final delta = _dragEnd! - _dragStart!;
    
    // Minimum swipe distance
    if (delta.length < 30) return;
    
    // Determine direction based on dominant axis
    if (delta.x.abs() > delta.y.abs()) {
      // Horizontal swipe
      if (delta.x > 0) {
        _snake.setDirection(Direction.right);
      } else {
        _snake.setDirection(Direction.left);
      }
    } else {
      // Vertical swipe
      if (delta.y > 0) {
        _snake.setDirection(Direction.down);
      } else {
        _snake.setDirection(Direction.up);
      }
    }
    
    _dragStart = null;
    _dragEnd = null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _moveTimer.update(dt);
  }
}

enum Direction { up, down, left, right }

class GameArea extends Component with HasGameReference<SnakeGame> {
  @override
  void render(Canvas canvas) {
    // Draw pastel grid background
    final paint = Paint()
      ..color = const Color(0xFFFFF0F5)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, game.size.x, game.size.y),
      paint,
    );
    
    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFFFE4E1)
      ..strokeWidth = 1;
    
    for (double x = 0; x < game.size.x; x += SnakeGame.cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, game.size.y), gridPaint);
    }
    
    for (double y = 0; y < game.size.y; y += SnakeGame.cellSize) {
      canvas.drawLine(Offset(0, y), Offset(game.size.x, y), gridPaint);
    }
  }
}

class Snake extends Component with HasGameReference<SnakeGame> {
  List<Vector2> segments = [];
  Direction direction = Direction.right;
  Direction? nextDirection;
  bool shouldGrow = false;
  
  Snake({required Vector2 position}) {
    // Initial snake with 3 segments
    segments.add(position);
    segments.add(Vector2(position.x - SnakeGame.cellSize, position.y));
    segments.add(Vector2(position.x - 2 * SnakeGame.cellSize, position.y));
  }
  
  Vector2 get headPosition => segments.first;
  
  void setDirection(Direction newDirection) {
    // Prevent reversing direction
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    nextDirection = newDirection;
  }
  
  void move() {
    if (nextDirection != null) {
      direction = nextDirection!;
      nextDirection = null;
    }
    
    Vector2 newHead = segments.first.clone();
    
    switch (direction) {
      case Direction.up:
        newHead.y -= SnakeGame.cellSize;
        break;
      case Direction.down:
        newHead.y += SnakeGame.cellSize;
        break;
      case Direction.left:
        newHead.x -= SnakeGame.cellSize;
        break;
      case Direction.right:
        newHead.x += SnakeGame.cellSize;
        break;
    }
    
    segments.insert(0, newHead);
    
    if (!shouldGrow) {
      segments.removeLast();
    } else {
      shouldGrow = false;
    }
  }
  
  void grow() {
    shouldGrow = true;
  }
  
  bool occupies(Vector2 position) {
    for (final segment in segments) {
      if (segment.distanceTo(position) < SnakeGame.cellSize / 2) {
        return true;
      }
    }
    return false;
  }
  
  bool checkCollision(Vector2 gameSize) {
    final head = segments.first;
    
    // Wall collision
    if (head.x < 0 || head.x >= gameSize.x ||
        head.y < 0 || head.y >= gameSize.y) {
      return true;
    }
    
    // Self collision
    for (int i = 1; i < segments.length; i++) {
      if (head.distanceTo(segments[i]) < SnakeGame.cellSize / 2) {
        return true;
      }
    }
    
    return false;
  }
  
  @override
  void render(Canvas canvas) {
    // Draw snake segments
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final isHead = i == 0;
      
      // Shadow
      canvas.drawCircle(
        Offset(segment.x + 3, segment.y + 3),
        SnakeGame.cellSize / 2 - 2,
        Paint()..color = Colors.black.withOpacity(0.15),
      );
      
      if (isHead) {
        // Draw cute bunny head
        _drawBunnyHead(canvas, segment);
      } else {
        // Draw body segment
        final bodyPaint = Paint()
          ..color = const Color(0xFF98FB98)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(
          Offset(segment.x, segment.y),
          SnakeGame.cellSize / 2 - 3,
          bodyPaint,
        );
        
        // Body highlight
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(
          Offset(segment.x - 3, segment.y - 3),
          SnakeGame.cellSize / 4,
          highlightPaint,
        );
      }
    }
  }
  
  void _drawBunnyHead(Canvas canvas, Vector2 position) {
    final center = Offset(position.x, position.y);
    final size = SnakeGame.cellSize / 2 - 2;
    
    // Draw bunny ears
    final earPaint = Paint()
      ..color = const Color(0xFFFFB7C5)
      ..style = PaintingStyle.fill;
    
    // Left ear
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - size * 0.4, center.dy - size * 0.8),
        width: size * 0.5,
        height: size * 1.2,
      ),
      earPaint,
    );
    
    // Right ear
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + size * 0.4, center.dy - size * 0.8),
        width: size * 0.5,
        height: size * 1.2,
      ),
      earPaint,
    );
    
    // Inner ears
    final innerEarPaint = Paint()
      ..color = const Color(0xFFFFE4E1)
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - size * 0.4, center.dy - size * 0.8),
        width: size * 0.25,
        height: size * 0.7,
      ),
      innerEarPaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + size * 0.4, center.dy - size * 0.8),
        width: size * 0.25,
        height: size * 0.7,
      ),
      innerEarPaint,
    );
    
    // Head
    final headPaint = Paint()
      ..color = const Color(0xFFFFB7C5)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, size, headPaint);
    
    // Cute eyes
    final eyePaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx - size * 0.3, center.dy - size * 0.1),
      size * 0.15,
      eyePaint,
    );
    
    canvas.drawCircle(
      Offset(center.dx + size * 0.3, center.dy - size * 0.1),
      size * 0.15,
      eyePaint,
    );
    
    // Eye highlights
    final eyeHighlightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx - size * 0.25, center.dy - size * 0.15),
      size * 0.05,
      eyeHighlightPaint,
    );
    
    canvas.drawCircle(
      Offset(center.dx + size * 0.35, center.dy - size * 0.15),
      size * 0.05,
      eyeHighlightPaint,
    );
    
    // Nose
    final nosePaint = Paint()
      ..color = const Color(0xFFFF69B4)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx, center.dy + size * 0.15),
      size * 0.12,
      nosePaint,
    );
    
    // Blush
    final blushPaint = Paint()
      ..color = const Color(0xFFFF69B4).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx - size * 0.6, center.dy + size * 0.1),
      size * 0.2,
      blushPaint,
    );
    
    canvas.drawCircle(
      Offset(center.dx + size * 0.6, center.dy + size * 0.1),
      size * 0.2,
      blushPaint,
    );
  }
}

class Fruit extends Component with HasGameReference<SnakeGame> {
  final Vector2 position;
  late String emoji;
  late final List<String> fruitEmojis = ['🍎', '🍊', '🍇', '🍓', '🍒', '🍑', '🍐'];
  
  Fruit({required this.position}) {
    emoji = fruitEmojis[Random().nextInt(fruitEmojis.length)];
  }
  
  @override
  void render(Canvas canvas) {
    // Shadow
    canvas.drawCircle(
      Offset(position.x + 2, position.y + 2),
      SnakeGame.cellSize / 2 - 5,
      Paint()..color = Colors.black.withOpacity(0.1),
    );
    
    // Background circle for fruit
    canvas.drawCircle(
      Offset(position.x, position.y),
      SnakeGame.cellSize / 2 - 5,
      Paint()..color = Colors.white.withOpacity(0.8),
    );
    
    // Note: In a real app, use flame text or sprite components
    // Here we're drawing a simple fruit representation
    final fruitPaint = Paint()
      ..color = _getFruitColor()
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(position.x, position.y),
      SnakeGame.cellSize / 2 - 8,
      fruitPaint,
    );
    
    // Highlight
    canvas.drawCircle(
      Offset(position.x - 3, position.y - 3),
      SnakeGame.cellSize / 4 - 2,
      Paint()..color = Colors.white.withOpacity(0.4),
    );
  }
  
  Color _getFruitColor() {
    switch (emoji) {
      case '🍎': return Colors.red.shade400;
      case '🍊': return Colors.orange.shade400;
      case '🍇': return Colors.purple.shade400;
      case '🍓': return Colors.red.shade300;
      case '🍒': return Colors.red.shade500;
      case '🍑': return Colors.orange.shade300;
      case '🍐': return Colors.green.shade400;
      default: return Colors.pink.shade300;
    }
  }
}
