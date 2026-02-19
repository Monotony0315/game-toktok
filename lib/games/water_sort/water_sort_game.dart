import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class WaterSortGame extends FlameGame with TapCallbacks {
  static const int tubeCapacity = 4;
  static const double tubeWidth = 60;
  static const double tubeHeight = 200;
  static const double waterHeight = 45;

  final Random random = Random();
  late LevelManager levelManager;
  List<Tube> tubes = [];
  Tube? selectedTube;
  int currentLevel = 1;
  int moves = 0;
  bool isAnimating = false;

  // Pastel colors matching Toki theme
  final List<Color> waterColors = [
    const Color(0xFFFF9AA2), // Coral Pink
    const Color(0xFFFFB7B2), // Salmon
    const Color(0xFFFFDAC1), // Peach
    const Color(0xFFE2F0CB), // Mint
    const Color(0xFFB5EAD7), // Aqua
    const Color(0xFFC7CEEA), // Lavender
    const Color(0xFFF8B195), // Melon
    const Color(0xFFF67280), // Rose
  ];

  @override
  Future<void> onLoad() async {
    levelManager = LevelManager();
    await setupLevel(currentLevel);
  }

  Future<void> setupLevel(int level) async {
    // Clear existing tubes
    for (final tube in tubes) {
      tube.removeFromParent();
    }
    tubes.clear();
    selectedTube = null;
    moves = 0;
    isAnimating = false;

    // Generate level configuration
    final levelConfig = levelManager.getLevelConfig(level);
    final numColors = levelConfig['colors'] as int;
    final numEmptyTubes = levelConfig['emptyTubes'] as int;

    // Create color pools
    final List<Color> colorPool = [];
    for (int i = 0; i < numColors; i++) {
      for (int j = 0; j < tubeCapacity; j++) {
        colorPool.add(waterColors[i]);
      }
    }
    colorPool.shuffle(random);

    // Create tubes
    final totalTubes = numColors + numEmptyTubes;
    final spacing = size.x / (totalTubes + 1);
    final startY = size.y * 0.4;

    int colorIndex = 0;
    for (int i = 0; i < totalTubes; i++) {
      final List<Color> tubeColors = [];
      
      // Fill tubes with colors (except empty ones)
      if (i < numColors) {
        for (int j = 0; j < tubeCapacity && colorIndex < colorPool.length; j++) {
          tubeColors.add(colorPool[colorIndex]);
          colorIndex++;
        }
      }

      final tube = Tube(
        colors: tubeColors,
        position: Vector2(
          spacing * (i + 1) - tubeWidth / 2,
          startY,
        ),
        index: i,
      );
      
      tubes.add(tube);
      await add(tube);
    }

    // Add UI elements
    await add(LevelDisplay(level: currentLevel, moves: moves));
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isAnimating) return;

    final tapPosition = event.localPosition;
    
    // Check if a tube was tapped
    for (final tube in tubes) {
      if (tube.containsPoint(tapPosition)) {
        onTubeTapped(tube);
        break;
      }
    }
  }

  void onTubeTapped(Tube tube) {
    if (selectedTube == null) {
      // Select first tube
      if (tube.colors.isNotEmpty) {
        selectedTube = tube;
        tube.setSelected(true);
      }
    } else if (selectedTube == tube) {
      // Deselect
      selectedTube!.setSelected(false);
      selectedTube = null;
    } else {
      // Try to pour
      if (canPour(selectedTube!, tube)) {
        pourWater(selectedTube!, tube);
      } else {
        // Invalid move - shake animation
        tube.shake();
      }
      selectedTube!.setSelected(false);
      selectedTube = null;
    }
  }

  bool canPour(Tube from, Tube to) {
    if (from.colors.isEmpty) return false;
    if (to.colors.length >= tubeCapacity) return false;
    if (to.colors.isEmpty) return true;
    
    // Can only pour if top colors match
    final fromTopColor = from.colors.last;
    final toTopColor = to.colors.last;
    return fromTopColor == toTopColor;
  }

  void pourWater(Tube from, Tube to) {
    isAnimating = true;
    
    // Calculate how much water to pour
    final pourColor = from.colors.last;
    int pourAmount = 0;
    
    // Count consecutive same colors from top
    for (int i = from.colors.length - 1; i >= 0; i--) {
      if (from.colors[i] == pourColor) {
        pourAmount++;
      } else {
        break;
      }
    }

    // Limit by available space in target
    final availableSpace = tubeCapacity - to.colors.length;
    pourAmount = pourAmount.clamp(1, availableSpace);

    // Perform pour animation
    from.pourOut(pourAmount, () {
      to.pourIn(List.generate(pourAmount, (_) => pourColor), () {
        isAnimating = false;
        moves++;
        updateUI();
        checkWinCondition();
      });
    });
  }

  void checkWinCondition() {
    // Check if all tubes are either empty or have only one color
    bool won = true;
    for (final tube in tubes) {
      if (tube.colors.isNotEmpty) {
        final firstColor = tube.colors.first;
        for (final color in tube.colors) {
          if (color != firstColor) {
            won = false;
            break;
          }
        }
        if (!won) break;
      }
    }

    if (won) {
      showWinDialog();
    }
  }

  void showWinDialog() {
    overlays.add('win');
  }

  void nextLevel() {
    overlays.remove('win');
    currentLevel++;
    setupLevel(currentLevel);
  }

  void restartLevel() {
    setupLevel(currentLevel);
  }

  void updateUI() {
    children.whereType<LevelDisplay>().forEach((display) {
      display.updateLevel(currentLevel, moves);
    });
  }

  void restart() {
    setupLevel(currentLevel);
  }
}

class Tube extends PositionComponent {
  List<Color> colors;
  final int index;
  bool isSelected = false;
  bool isShaking = false;
  double shakeOffset = 0;

  Tube({
    required this.colors,
    required super.position,
    required this.index,
  }) : super(size: Vector2(WaterSortGame.tubeWidth, WaterSortGame.tubeHeight));

  bool containsPoint(Vector2 point) {
    return point.x >= position.x &&
        point.x <= position.x + size.x &&
        point.y >= position.y &&
        point.y <= position.y + size.y;
  }

  void setSelected(bool selected) {
    isSelected = selected;
  }

  void shake() {
    isShaking = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      isShaking = false;
      shakeOffset = 0;
    });
  }

  void pourOut(int amount, VoidCallback onComplete) {
    // Remove colors from tube
    for (int i = 0; i < amount && colors.isNotEmpty; i++) {
      colors.removeLast();
    }
    onComplete();
  }

  void pourIn(List<Color> newColors, VoidCallback onComplete) {
    colors.addAll(newColors);
    onComplete();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isShaking) {
      shakeOffset = sin(DateTime.now().millisecondsSinceEpoch / 50) * 3;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final xOffset = isShaking ? shakeOffset : (isSelected ? -5.0 : 0.0);
    final yOffset = isSelected ? -10.0 : 0.0;

    canvas.save();
    canvas.translate(xOffset, yOffset);

    // Draw tube shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 8, size.x, size.y),
        const Radius.circular(12),
      ),
      shadowPaint,
    );

    // Draw tube glass
    final glassPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final glassPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.x, 0)
      ..lineTo(size.x, size.y - 15)
      ..quadraticBezierTo(size.x, size.y, size.x - 15, size.y)
      ..lineTo(15, size.y)
      ..quadraticBezierTo(0, size.y, 0, size.y - 15)
      ..close();

    canvas.drawPath(glassPath, glassPaint);

    // Draw water layers
    final layerHeight = WaterSortGame.waterHeight;
    final bottomPadding = 10;
    
    for (int i = 0; i < colors.length; i++) {
      final waterY = size.y - bottomPadding - (i + 1) * layerHeight;
      
      // Water gradient
      final waterRect = Rect.fromLTWH(
        3,
        waterY,
        size.x - 6,
        layerHeight,
      );

      final waterGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors[i].withOpacity(0.8),
          colors[i].withOpacity(0.6),
        ],
      );

      final waterPaint = Paint()
        ..shader = waterGradient.createShader(waterRect);

      // Rounded corners for top layer only
      if (i == colors.length - 1) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            waterRect,
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
          ),
          waterPaint,
        );
      } else {
        canvas.drawRect(waterRect, waterPaint);
      }

      // Water highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(8, waterY + 5, size.x - 16, 3),
        highlightPaint,
      );
    }

    // Draw tube outline
    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(glassPath, outlinePaint);

    // Draw selection indicator
    if (isSelected) {
      final selectPaint = Paint()
        ..color = const Color(0xFF7BFFCE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawPath(glassPath, selectPaint);
    }

    canvas.restore();
  }
}

class LevelManager {
  Map<String, dynamic> getLevelConfig(int level) {
    // Progressive difficulty
    if (level == 1) {
      return {'colors': 2, 'emptyTubes': 2};
    } else if (level == 2) {
      return {'colors': 3, 'emptyTubes': 2};
    } else if (level <= 5) {
      return {'colors': 4, 'emptyTubes': 2};
    } else if (level <= 10) {
      return {'colors': 5, 'emptyTubes': 2};
    } else if (level <= 15) {
      return {'colors': 6, 'emptyTubes': 2};
    } else if (level <= 20) {
      return {'colors': 7, 'emptyTubes': 2};
    } else {
      return {'colors': 8, 'emptyTubes': 2};
    }
  }
}

class LevelDisplay extends PositionComponent {
  int level;
  int moves;

  LevelDisplay({required this.level, required this.moves})
      : super(position: Vector2(20, 20));

  void updateLevel(int newLevel, int newMoves) {
    level = newLevel;
    moves = newMoves;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw level indicator
    final levelText = TextPainter(
      text: TextSpan(
        text: 'Level $level',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7BFFCE),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    levelText.layout();
    levelText.paint(canvas, const Offset(0, 0));

    // Draw moves indicator
    final movesText = TextPainter(
      text: TextSpan(
        text: 'Moves: $moves',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF9E9E9E),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    movesText.layout();
    movesText.paint(canvas, const Offset(0, 28));
  }
}
