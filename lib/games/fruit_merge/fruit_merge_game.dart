import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class FruitMergeGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  static const double spawnY = 100.0;
  static const double wallThickness = 10.0;
  static const double gameSpeed = 1.0;
  
  late Fruit? currentFruit;
  late Timer _gameTimer;
  bool canDrop = true;
  bool isGameOver = false;
  int score = 0;
  
  final Random random = Random();
  
  // Fruit types in order: cherry→strawberry→grape→orange→apple→pear→peach→pineapple→melon→watermelon
  final List<FruitType> fruitTypes = [
    FruitType.cherry,
    FruitType.strawberry,
    FruitType.grape,
    FruitType.orange,
    FruitType.apple,
    FruitType.pear,
    FruitType.peach,
    FruitType.pineapple,
    FruitType.melon,
    FruitType.watermelon,
  ];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    camera.viewfinder.anchor = Anchor.topLeft;
    
    restart();
  }

  void restart() {
    removeAll(children);
    score = 0;
    isGameOver = false;
    canDrop = true;
    overlays.remove('gameOver');
    overlays.add('score');
    
    // Add game boundaries
    _addBoundaries();
    
    // Create initial fruit
    _spawnNextFruit();
    
    // Start game timer
    _gameTimer = Timer(0.1, repeat: true, onTick: _checkGameState);
    _gameTimer.start();
  }

  void _addBoundaries() {
    // Left wall
    add(Wall(
      position: Vector2(wallThickness / 2, size.y / 2),
      size: Vector2(wallThickness, size.y),
    ));
    
    // Right wall
    add(Wall(
      position: Vector2(size.x - wallThickness / 2, size.y / 2),
      size: Vector2(wallThickness, size.y),
    ));
    
    // Floor
    add(Wall(
      position: Vector2(size.x / 2, size.y - wallThickness / 2),
      size: Vector2(size.x, wallThickness),
    ));
  }

  void _spawnNextFruit() {
    if (isGameOver) return;
    
    // Only spawn small fruits (first 3 types) for dropping
    final availableTypes = fruitTypes.sublist(0, 3);
    final fruitType = availableTypes[random.nextInt(availableTypes.length)];
    
    currentFruit = Fruit(
      fruitType: fruitType,
      position: Vector2(size.x / 2, spawnY),
      isPreview: true,
    );
    
    add(currentFruit!);
    canDrop = true;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver || !canDrop || currentFruit == null) return;
    
    final tapX = event.localPosition.x;
    
    // Clamp to game area
    final clampedX = tapX.clamp(
      wallThickness + currentFruit!.radius,
      size.x - wallThickness - currentFruit!.radius,
    );
    
    // Drop the fruit
    currentFruit!.position.x = clampedX;
    currentFruit!.drop();
    canDrop = false;
    
    // Spawn next fruit after a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!isGameOver) {
        _spawnNextFruit();
      }
    });
  }

  void _checkGameState() {
    // Check if any fruit is too high (game over condition)
    for (final component in children) {
      if (component is Fruit && !component.isPreview && !component.isDropping) {
        if (component.position.y < spawnY + 50 && component.isSettled) {
          // Give some grace period before game over
          Future.delayed(const Duration(seconds: 3), () {
            if (!isGameOver && component.position.y < spawnY + 50) {
              gameOver();
            }
          });
          break;
        }
      }
    }
  }

  void mergeFruits(Fruit fruit1, Fruit fruit2) {
    if (fruit1.fruitType.index >= fruitTypes.length - 1) return;
    
    final nextType = fruitTypes[fruit1.fruitType.index + 1];
    final newPosition = (fruit1.position + fruit2.position) / 2;
    
    // Calculate score based on merged fruit level
    score += (fruit1.fruitType.index + 1) * 10;
    overlays.remove('score');
    overlays.add('score');
    
    // Remove old fruits
    fruit1.removeFromParent();
    fruit2.removeFromParent();
    
    // Create merged fruit
    final mergedFruit = Fruit(
      fruitType: nextType,
      position: newPosition,
    );
    add(mergedFruit);
    
    // Add merge effect
    add(MergeEffect(position: newPosition));
  }

  void gameOver() {
    isGameOver = true;
    _gameTimer.stop();
    overlays.remove('score');
    overlays.add('gameOver');
  }

  @override
  void update(double dt) {
    super.update(dt);
    _gameTimer.update(dt);
  }
}

enum FruitType {
  cherry('🍒', 15.0, Color(0xFFFF6B6B)),
  strawberry('🍓', 20.0, Color(0xFFFF8E8E)),
  grape('🍇', 25.0, Color(0xFF9B59B6)),
  orange('🍊', 30.0, Color(0xFFFFA500)),
  apple('🍎', 35.0, Color(0xFFFF6B6B)),
  pear('🍐', 40.0, Color(0xFFD4E157)),
  peach('🍑', 45.0, Color(0xFFFFB7C5)),
  pineapple('🍍', 50.0, Color(0xFFFFD700)),
  melon('🍈', 60.0, Color(0xFF98FB98)),
  watermelon('🍉', 75.0, Color(0xFFFF6B6B));

  final String emoji;
  final double radius;
  final Color color;

  const FruitType(this.emoji, this.radius, this.color);
}

class Fruit extends CircleComponent with CollisionCallbacks, HasGameReference<FruitMergeGame> {
  final FruitType fruitType;
  bool isPreview;
  bool isDropping = false;
  bool isSettled = false;
  Vector2 velocity = Vector2.zero();
  static const double gravity = 800.0;
  static const double bounceDamping = 0.6;
  static const double friction = 0.98;
  
  Fruit({
    required this.fruitType,
    required Vector2 position,
    this.isPreview = false,
  }) : super(
          position: position,
          radius: fruitType.radius,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    add(CircleHitbox());
  }

  void drop() {
    isPreview = false;
    isDropping = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isPreview) return;
    
    // Apply gravity
    if (isDropping || !isSettled) {
      velocity.y += gravity * dt;
      position += velocity * dt;
      
      // Apply friction
      velocity.x *= friction;
      
      // Check if velocity is very small (settled)
      if (velocity.length < 10 && position.y > game.size.y - 200) {
        isSettled = true;
      }
    }
    
    // Boundary checks
    final leftBound = FruitMergeGame.wallThickness + radius;
    final rightBound = game.size.x - FruitMergeGame.wallThickness - radius;
    final bottomBound = game.size.y - FruitMergeGame.wallThickness - radius;
    
    if (position.x < leftBound) {
      position.x = leftBound;
      velocity.x = velocity.x.abs() * bounceDamping;
    }
    if (position.x > rightBound) {
      position.x = rightBound;
      velocity.x = -velocity.x.abs() * bounceDamping;
    }
    if (position.y > bottomBound) {
      position.y = bottomBound;
      velocity.y = -velocity.y.abs() * bounceDamping;
      velocity.x *= 0.9; // More friction on floor
      
      if (velocity.y.abs() < 50) {
        velocity.y = 0;
        isDropping = false;
        isSettled = true;
      }
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (isPreview) return;
    
    if (other is Fruit && !other.isPreview) {
      if (fruitType == other.fruitType && 
          fruitType.index < FruitType.values.length - 1) {
        // Merge fruits
        game.mergeFruits(this, other);
      } else {
        // Bounce off each other
        final normal = (position - other.position).normalized();
        if (normal.length > 0) {
          final relativeVelocity = velocity - other.velocity;
          final speed = relativeVelocity.dot(normal);
          
          if (speed < 0) {
            final impulse = normal * speed * -0.5;
            velocity += impulse;
            other.velocity -= impulse;
          }
        }
        
        // Push apart to prevent sticking
        final overlap = radius + other.radius - position.distanceTo(other.position);
        if (overlap > 0) {
          final push = normal * overlap * 0.5;
          position += push;
          other.position -= push;
        }
      }
    }
    
    if (other is Wall) {
      // Wall collision handled in update
    }
  }

  @override
  void render(Canvas canvas) {
    // Shadow for dropped fruits
    if (!isPreview) {
      canvas.drawCircle(
        const Offset(3, 3),
        radius,
        Paint()..color = Colors.black.withOpacity(0.2),
      );
    }
    
    // Fruit body with gradient-like effect
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.8,
      colors: [
        _lightenColor(fruitType.color, 0.3),
        fruitType.color,
        _darkenColor(fruitType.color, 0.2),
      ],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: radius),
      )
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, radius, paint);
    
    // Fruit highlight/shine
    canvas.drawCircle(
      Offset(-radius * 0.3, -radius * 0.3),
      radius * 0.25,
      Paint()..color = Colors.white.withOpacity(0.4),
    );
    
    // Outline
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..color = _darkenColor(fruitType.color, 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    
    // If preview, show ghost effect
    if (isPreview) {
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
    }
  }
  
  Color _lightenColor(Color color, double amount) {
    return Color.fromARGB(
      color.alpha,
      min(255, color.red + (255 - color.red) * amount).toInt(),
      min(255, color.green + (255 - color.green) * amount).toInt(),
      min(255, color.blue + (255 - color.blue) * amount).toInt(),
    );
  }
  
  Color _darkenColor(Color color, double amount) {
    return Color.fromARGB(
      color.alpha,
      (color.red * (1 - amount)).toInt(),
      (color.green * (1 - amount)).toInt(),
      (color.blue * (1 - amount)).toInt(),
    );
  }
}

class Wall extends RectangleComponent with CollisionCallbacks {
  Wall({required Vector2 position, required Vector2 size})
      : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFFFB7C5)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(size.toRect(), paint);
    
    // Add decorative pattern
    final patternPaint = Paint()
      ..color = const Color(0xFFFF69B4).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final patternSize = 10.0;
    for (double x = 0; x < size.x; x += patternSize * 2) {
      for (double y = 0; y < size.y; y += patternSize * 2) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, patternSize, patternSize),
          patternPaint,
        );
      }
    }
  }
}

class MergeEffect extends Component with HasGameReference<FruitMergeGame> {
  final Vector2 position;
  double lifetime = 0.0;
  static const double maxLifetime = 0.5;
  
  MergeEffect({required this.position});

  @override
  void update(double dt) {
    lifetime += dt;
    if (lifetime >= maxLifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = lifetime / maxLifetime;
    final radius = 50.0 * (1 - progress);
    final alpha = (1 - progress) * 255;
    
    // Draw expanding ring
    canvas.drawCircle(
      Offset(position.x, position.y),
      radius,
      Paint()
        ..color = Color.fromARGB(alpha.toInt(), 255, 255, 100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5 * (1 - progress),
    );
    
    // Draw sparkles
    final random = Random();
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi + progress * pi;
      final sparkleRadius = 30.0 * progress;
      final sparkleX = position.x + cos(angle) * sparkleRadius;
      final sparkleY = position.y + sin(angle) * sparkleRadius;
      
      canvas.drawCircle(
        Offset(sparkleX, sparkleY),
        5 * (1 - progress),
        Paint()
          ..color = Color.fromARGB(alpha.toInt(), 255, 255, 150)
          ..style = PaintingStyle.fill,
      );
    }
  }
}
