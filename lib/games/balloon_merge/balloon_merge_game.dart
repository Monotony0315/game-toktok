import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class BalloonMergeGame extends FlameGame
    with HasCollisionDetection, TapCallbacks, DragCallbacks {
  late final World world;
  late final CameraComponent camera;
  
  static const int gridColumns = 5;
  static const double balloonBaseSize = 50;
  static const double mergeThreshold = 55;
  
  final Random random = Random();
  final List<Balloon> balloons = [];
  int score = 0;
  bool isGameOver = false;

  // Pastel colors matching Toki theme
  final List<Color> balloonColors = [
    const Color(0xFFFF9AA2), // Coral Pink
    const Color(0xFFFFB7B2), // Salmon
    const Color(0xFFFFDAC1), // Peach
    const Color(0xFFE2F0CB), // Mint
    const Color(0xFFB5EAD7), // Aqua
    const Color(0xFFC7CEEA), // Lavender
    const Color(0xFFF8B195), // Melon
    const Color(0xFFF67280), // Rose
    const Color(0xFF6C5B7B), // Plum
    const Color(0xFF355C7D), // Navy
  ];

  @override
  Future<void> onLoad() async {
    world = World();
    camera = CameraComponent(world: world);
    await addAll([world, camera]);

    // Set up the game area
    camera.viewfinder.anchor = Anchor.topLeft;

    // Add boundaries
    await world.add(GameBoundaries(size));
    
    // Add score display
    await add(ScoreDisplay(score: score));
    
    // Spawn initial balloons
    spawnInitialBalloons();
  }

  void spawnInitialBalloons() {
    for (int i = 0; i < 8; i++) {
      spawnBalloonAtTop();
    }
  }

  void spawnBalloonAtTop() {
    if (isGameOver) return;

    final colorIndex = random.nextInt(4); // Start with easier colors
    final x = random.nextDouble() * (size.x - 60) + 30;
    
    final balloon = Balloon(
      colorIndex: colorIndex,
      color: balloonColors[colorIndex],
      radius: balloonBaseSize + colorIndex * 5,
      position: Vector2(x, -50),
      velocity: Vector2(0, 30 + random.nextDouble() * 20),
    );
    
    balloons.add(balloon);
    world.add(balloon);
  }

  void restart() {
    removeAll(children);
    balloons.clear();
    score = 0;
    isGameOver = false;
    overlays.remove('gameOver');
    
    // Re-initialize world and camera
    world = World();
    camera = CameraComponent(world: world);
    addAll([world, camera]);
    camera.viewfinder.anchor = Anchor.topLeft;
    
    // Add boundaries and spawn balloons
    world.add(GameBoundaries(size));
    spawnInitialBalloons();
  }

  void checkMerges() {
    for (int i = 0; i < balloons.length; i++) {
      for (int j = i + 1; j < balloons.length; j++) {
        final balloon1 = balloons[i];
        final balloon2 = balloons[j];

        if (balloon1.colorIndex == balloon2.colorIndex &&
            !balloon1.isMerged &&
            !balloon2.isMerged &&
            balloon1.position.distanceTo(balloon2.position) < mergeThreshold) {
          mergeBalloons(balloon1, balloon2);
        }
      }
    }
  }

  void mergeBalloons(Balloon balloon1, Balloon balloon2) {
    if (balloon1.colorIndex >= balloonColors.length - 1) return;

    final newColorIndex = balloon1.colorIndex + 1;
    final mergePosition = (balloon1.position + balloon2.position) / 2;

    // Mark as merged
    balloon1.isMerged = true;
    balloon2.isMerged = true;

    // Create explosion effect
    createMergeEffect(mergePosition, balloon1.color);

    // Remove old balloons
    balloon1.removeFromParent();
    balloon2.removeFromParent();
    balloons.remove(balloon1);
    balloons.remove(balloon2);

    // Create new merged balloon
    final newBalloon = Balloon(
      colorIndex: newColorIndex,
      color: balloonColors[newColorIndex],
      radius: balloonBaseSize + newColorIndex * 5,
      position: mergePosition,
      velocity: Vector2(
        (random.nextDouble() - 0.5) * 50,
        -50 - random.nextDouble() * 30,
      ),
    );
    
    balloons.add(newBalloon);
    world.add(newBalloon);

    // Update score
    score += (newColorIndex + 1) * 10;
    
    // Check for chain reactions after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      checkMerges();
    });
  }

  void createMergeEffect(Vector2 position, Color color) {
    final particle = Particle.generate(
      count: 20,
      lifespan: 0.5,
      generator: (i) => AcceleratedParticle(
        position: position,
        speed: Vector2(
          (random.nextDouble() - 0.5) * 200,
          (random.nextDouble() - 0.5) * 200,
        ),
        acceleration: Vector2(0, 100),
        child: CircleParticle(
          radius: random.nextDouble() * 5 + 2,
          paint: Paint()..color = color.withOpacity(0.8),
        ),
      ),
    );
    
    world.add(ParticleSystemComponent(particle: particle));
  }

  @override
  void update(double dt) {
    super.update(dt);
    checkMerges();

    // Spawn new balloons periodically
    if (random.nextDouble() < 0.01 && balloons.length < 20) {
      spawnBalloonAtTop();
    }

    // Update score display
    children.whereType<ScoreDisplay>().forEach((display) => display.score = score);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Tap to push balloons
    final tapPosition = event.localPosition;
    for (final balloon in balloons) {
      final distance = balloon.position.distanceTo(tapPosition);
      if (distance < 100) {
        final pushDirection = (balloon.position - tapPosition).normalized();
        balloon.applyPush(pushDirection * 100);
      }
    }
  }
}

class Balloon extends PositionComponent {
  final int colorIndex;
  final Color color;
  final double radius;
  Vector2 velocity;
  bool isMerged = false;
  
  // Float physics
  double floatOffset = 0;
  double floatSpeed = 1.0;
  double floatAmplitude = 5.0;

  Balloon({
    required this.colorIndex,
    required this.color,
    required this.radius,
    required super.position,
    required this.velocity,
  }) : super(size: Vector2.all(radius * 2));

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw balloon body with gradient
    final center = Offset(radius, radius);
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.8,
      colors: [
        color.withOpacity(0.9),
        color.withOpacity(0.7),
        color.withOpacity(0.5),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    // Draw shine
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(radius * 0.6, radius * 0.4),
      radius * 0.25,
      shinePaint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, radius, borderPaint);

    // Draw string
    final stringPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final path = Path()
      ..moveTo(center.dx, center.dy + radius)
      ..quadraticBezierTo(
        center.dx + 5,
        center.dy + radius + 15,
        center.dx,
        center.dy + radius + 25,
      );
    
    canvas.drawPath(path, stringPaint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply float physics
    floatOffset += floatSpeed * dt;
    final floatX = sin(floatOffset * 2) * floatAmplitude * dt;
    
    // Update position
    position += velocity * dt;
    position.x += floatX;

    // Float upward with slight deceleration
    velocity.y -= 10 * dt;
    if (velocity.y < -80) velocity.y = -80;

    // Apply drag
    velocity *= 0.99;

    // Boundary checks
    if (position.x < radius) {
      position.x = radius;
      velocity.x = velocity.x.abs() * 0.5;
    }
    final worldSize = (parent as World).children.query<GameBoundaries>().first.size;
    if (position.x > worldSize.x - radius) {
      position.x = worldSize.x - radius;
      velocity.x = -velocity.x.abs() * 0.5;
    }
    if (position.y < -radius * 2) {
      // Balloon floated off screen - respawn at bottom occasionally
      if (Random().nextDouble() < 0.1) {
        position.y = worldSize.y + radius;
        velocity.y = -30 - Random().nextDouble() * 20;
      }
    }
    if (position.y > worldSize.y + radius * 2) {
      position.y = -radius;
      velocity.y = 30 + Random().nextDouble() * 20;
    }
  }

  void applyPush(Vector2 force) {
    velocity += force;
  }
}

class GameBoundaries extends PositionComponent {
  GameBoundaries(Vector2 gameSize) : super(size: gameSize);

  @override
  void render(Canvas canvas) {
    // Draw decorative background
    final paint = Paint()
      ..color = const Color(0xFFFFF5E1)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );

    // Draw cloud decorations
    final cloudPaint = Paint()
      ..color = const Color(0xFFFFE4E1).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.x * 0.2, size.y * 0.2), 40, cloudPaint);
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.15), 30, cloudPaint);
    canvas.drawCircle(Offset(size.x * 0.8, size.y * 0.7), 50, cloudPaint);
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.75), 35, cloudPaint);
  }
}

class ScoreDisplay extends TextComponent {
  int score;

  ScoreDisplay({required this.score})
      : super(
          text: 'Score: $score',
          position: Vector2(20, 20),
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF7B7B),
            ),
          ),
        );

  void updateScore(int newScore) {
    score = newScore;
    text = 'Score: $score';
  }
}
