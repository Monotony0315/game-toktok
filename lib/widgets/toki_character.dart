import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Toki Character Widget with animations
/// Toki is a cute bunny mascot with round eyes and rosy cheeks
class TokiCharacter extends StatefulWidget {
  final TokiAnimationState state;
  final double size;
  final VoidCallback? onTap;
  final bool autoAnimate;

  const TokiCharacter({
    super.key,
    this.state = TokiAnimationState.idle,
    this.size = 120,
    this.onTap,
    this.autoAnimate = true,
  });

  @override
  State<TokiCharacter> createState() => _TokiCharacterState();
}

class _TokiCharacterState extends State<TokiCharacter>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _bounceController;
  late AnimationController _blinkController;
  late AnimationController _happyController;
  late AnimationController _sadController;

  @override
  void initState() {
    super.initState();
    
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _happyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _sadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _startAnimations();
  }

  void _startAnimations() {
    if (!widget.autoAnimate) return;
    
    switch (widget.state) {
      case TokiAnimationState.idle:
        _idleController.repeat(reverse: true);
        _scheduleBlinking();
        break;
      case TokiAnimationState.happy:
        _happyController.forward();
        break;
      case TokiAnimationState.sad:
        _sadController.forward();
        break;
      case TokiAnimationState.bounce:
        _bounceController.repeat(reverse: true);
        break;
      case TokiAnimationState.wave:
        _idleController.repeat(reverse: true);
        break;
      case TokiAnimationState.surprised:
        break;
    }
  }

  void _scheduleBlinking() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && widget.state == TokiAnimationState.idle) {
        _blinkController.forward().then((_) {
          _blinkController.reverse();
          _scheduleBlinking();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant TokiCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _resetControllers();
      _startAnimations();
    }
  }

  void _resetControllers() {
    _idleController.reset();
    _bounceController.reset();
    _happyController.reset();
    _sadController.reset();
  }

  @override
  void dispose() {
    _idleController.dispose();
    _bounceController.dispose();
    _blinkController.dispose();
    _happyController.dispose();
    _sadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          _bounceController.forward().then((_) => _bounceController.reverse());
          widget.onTap!();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _idleController,
          _bounceController,
          _happyController,
          _sadController,
        ]),
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: TokiTheme.shadow.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: TokiPainter(
                state: widget.state,
                idleProgress: _idleController.value,
                bounceProgress: _bounceController.value,
                blinkProgress: _blinkController.value,
                happyProgress: _happyController.value,
                sadProgress: _sadController.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for Toki character
class TokiPainter extends CustomPainter {
  final TokiAnimationState state;
  final double idleProgress;
  final double bounceProgress;
  final double blinkProgress;
  final double happyProgress;
  final double sadProgress;

  TokiPainter({
    required this.state,
    this.idleProgress = 0,
    this.bounceProgress = 0,
    this.blinkProgress = 0,
    this.happyProgress = 0,
    this.sadProgress = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;

    // Apply bounce animation
    final bounceOffset = bounceProgress * baseRadius * 0.05;

    // Draw shadow
    final shadowPaint = Paint()
      ..color = TokiTheme.shadow.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + baseRadius * 0.85),
        width: baseRadius * 1.2,
        height: baseRadius * 0.3,
      ),
      shadowPaint,
    );

    // Draw ears
    _drawEars(canvas, center, baseRadius, bounceOffset);

    // Draw head
    _drawHead(canvas, center, baseRadius, bounceOffset);

    // Draw face
    _drawFace(canvas, center, baseRadius, bounceOffset);

    // Draw accessories based on state
    if (state == TokiAnimationState.happy) {
      _drawHappyEffects(canvas, center, baseRadius, bounceOffset);
    } else if (state == TokiAnimationState.sad) {
      _drawSadEffects(canvas, center, baseRadius, bounceOffset);
    }
  }

  void _drawEars(Canvas canvas, Offset center, double radius, double bounce) {
    final earPaint = Paint()
      ..color = TokiTheme.white
      ..style = PaintingStyle.fill;

    final earInnerPaint = Paint()
      ..color = TokiTheme.coralPinkLight
      ..style = PaintingStyle.fill;

    // Left ear
    final leftEarPath = Path()
      ..moveTo(center.dx - radius * 0.35, center.dy - radius * 0.3 + bounce)
      ..quadraticBezierTo(
        center.dx - radius * 0.5,
        center.dy - radius * 1.3 + bounce,
        center.dx - radius * 0.15,
        center.dy - radius * 1.1 + bounce,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.05,
        center.dy - radius * 0.7 + bounce,
        center.dx - radius * 0.1,
        center.dy - radius * 0.2 + bounce,
      );

    // Right ear
    final rightEarPath = Path()
      ..moveTo(center.dx + radius * 0.35, center.dy - radius * 0.3 + bounce)
      ..quadraticBezierTo(
        center.dx + radius * 0.5,
        center.dy - radius * 1.3 + bounce,
        center.dx + radius * 0.15,
        center.dy - radius * 1.1 + bounce,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.05,
        center.dy - radius * 0.7 + bounce,
        center.dx + radius * 0.1,
        center.dy - radius * 0.2 + bounce,
      );

    // Draw ears
    canvas.drawPath(leftEarPath, earPaint);
    canvas.drawPath(rightEarPath, earPaint);

    // Inner ears
    final leftInnerPath = Path()
      ..moveTo(center.dx - radius * 0.3, center.dy - radius * 0.4 + bounce)
      ..quadraticBezierTo(
        center.dx - radius * 0.4,
        center.dy - radius * 1.0 + bounce,
        center.dx - radius * 0.2,
        center.dy - radius * 0.9 + bounce,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.15,
        center.dy - radius * 0.6 + bounce,
        center.dx - radius * 0.2,
        center.dy - radius * 0.35 + bounce,
      );

    final rightInnerPath = Path()
      ..moveTo(center.dx + radius * 0.3, center.dy - radius * 0.4 + bounce)
      ..quadraticBezierTo(
        center.dx + radius * 0.4,
        center.dy - radius * 1.0 + bounce,
        center.dx + radius * 0.2,
        center.dy - radius * 0.9 + bounce,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.15,
        center.dy - radius * 0.6 + bounce,
        center.dx + radius * 0.2,
        center.dy - radius * 0.35 + bounce,
      );

    canvas.drawPath(leftInnerPath, earInnerPaint);
    canvas.drawPath(rightInnerPath, earInnerPaint);
  }

  void _drawHead(Canvas canvas, Offset center, double radius, double bounce) {
    final headPaint = Paint()
      ..color = TokiTheme.white
      ..style = PaintingStyle.fill;

    // Main head circle
    canvas.drawCircle(
      Offset(center.dx, center.dy + bounce),
      radius * 0.85,
      headPaint,
    );

    // Cheeks (rosy)
    final cheekPaint = Paint()
      ..color = TokiTheme.coralPinkLight.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.15 + bounce),
      radius * 0.2,
      cheekPaint,
    );

    canvas.drawCircle(
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.15 + bounce),
      radius * 0.2,
      cheekPaint,
    );
  }

  void _drawFace(Canvas canvas, Offset center, double radius, double bounce) {
    // Eyes
    final eyePaint = Paint()
      ..color = TokiTheme.black
      ..style = PaintingStyle.fill;

    final eyeRadius = radius * 0.12 * (1 - blinkProgress * 0.9);

    // Left eye
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.25, center.dy - radius * 0.1 + bounce),
        width: radius * 0.15,
        height: eyeRadius * 2,
      ),
      eyePaint,
    );

    // Right eye
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.25, center.dy - radius * 0.1 + bounce),
        width: radius * 0.15,
        height: eyeRadius * 2,
      ),
      eyePaint,
    );

    // Eye shine
    final shinePaint = Paint()
      ..color = TokiTheme.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx - radius * 0.22, center.dy - radius * 0.15 + bounce),
      radius * 0.04,
      shinePaint,
    );

    canvas.drawCircle(
      Offset(center.dx + radius * 0.28, center.dy - radius * 0.15 + bounce),
      radius * 0.04,
      shinePaint,
    );

    // Nose
    final nosePaint = Paint()
      ..color = TokiTheme.coralPink
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.05 + bounce),
        width: radius * 0.1,
        height: radius * 0.06,
      ),
      nosePaint,
    );

    // Mouth
    final mouthPaint = Paint()
      ..color = TokiTheme.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.02
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    if (state == TokiAnimationState.happy) {
      // Big smile
      final smileWidth = radius * 0.5 * happyProgress;
      mouthPath.moveTo(center.dx - smileWidth / 2, center.dy + radius * 0.15 + bounce);
      mouthPath.quadraticBezierTo(
        center.dx,
        center.dy + radius * 0.35 * happyProgress + bounce,
        center.dx + smileWidth / 2,
        center.dy + radius * 0.15 + bounce,
      );
    } else if (state == TokiAnimationState.sad) {
      // Frown
      final frownWidth = radius * 0.3;
      mouthPath.moveTo(center.dx - frownWidth / 2, center.dy + radius * 0.25 + bounce);
      mouthPath.quadraticBezierTo(
        center.dx,
        center.dy + radius * 0.15 + bounce,
        center.dx + frownWidth / 2,
        center.dy + radius * 0.25 + bounce,
      );
    } else {
      // Small smile
      mouthPath.moveTo(center.dx - radius * 0.12, center.dy + radius * 0.15 + bounce);
      mouthPath.quadraticBezierTo(
        center.dx,
        center.dy + radius * 0.22 + bounce,
        center.dx + radius * 0.12,
        center.dy + radius * 0.15 + bounce,
      );
    }

    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawHappyEffects(Canvas canvas, Offset center, double radius, double bounce) {
    // Draw sparkles around head
    final sparklePaint = Paint()
      ..color = TokiTheme.mintGreen
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 3.14159 * 2 + happyProgress * 0.5;
      final sparkleRadius = radius * (1.1 + happyProgress * 0.1);
      final sparkleX = center.dx + cos(angle) * sparkleRadius;
      final sparkleY = center.dy + sin(angle) * sparkleRadius * 0.8 + bounce;

      canvas.drawCircle(
        Offset(sparkleX, sparkleY),
        radius * 0.06 * (0.5 + happyProgress * 0.5),
        sparklePaint,
      );
    }
  }

  void _drawSadEffects(Canvas canvas, Offset center, double radius, double bounce) {
    // Draw sweat drop
    final sweatPaint = Paint()
      ..color = TokiTheme.skyBlue
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.6, center.dy - radius * 0.3 + bounce + sadProgress * 10),
        width: radius * 0.08,
        height: radius * 0.12,
      ),
      sweatPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Animation states for Toki
enum TokiAnimationState {
  idle,
  happy,
  sad,
  bounce,
  wave,
  surprised,
}

/// Toki speech bubble
class TokiSpeechBubble extends StatelessWidget {
  final String text;
  final bool isVisible;
  final VoidCallback? onDismiss;

  const TokiSpeechBubble({
    super.key,
    required this.text,
    this.isVisible = true,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: TokiTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: TokiTheme.coralPinkLight,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: TokiTheme.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: TokiTextStyles.bodyLarge.copyWith(
            color: TokiTheme.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
