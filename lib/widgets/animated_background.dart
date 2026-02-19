import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Animated sky background with clouds and floating particles
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool showClouds;
  final bool showParticles;
  final bool showGradient;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.showClouds = true,
    this.showParticles = true,
    this.showGradient = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _particleController;
  late AnimationController _floatController;

  final List<Cloud> _clouds = [];
  final List<FloatingParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Initialize clouds
    for (int i = 0; i < 5; i++) {
      _clouds.add(Cloud.random(i));
    }

    // Initialize particles
    for (int i = 0; i < 20; i++) {
      _particles.add(FloatingParticle.random(i));
    }
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _particleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.showGradient
          ? BoxDecoration(gradient: TokiTheme.backgroundGradient)
          : null,
      child: Stack(
        children: [
          // Clouds layer
          if (widget.showClouds)
            AnimatedBuilder(
              animation: _cloudController,
              builder: (context, child) {
                return Stack(
                  children: _clouds.map((cloud) {
                    final progress = (_cloudController.value + cloud.offset) % 1.0;
                    return Positioned(
                      left: progress * MediaQuery.of(context).size.width - 100,
                      top: cloud.y,
                      child: Opacity(
                        opacity: cloud.opacity,
                        child: _buildCloud(cloud.size),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

          // Floating particles layer
          if (widget.showParticles)
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return Stack(
                  children: _particles.map((particle) {
                    final yOffset = sin(
                      (_particleController.value * 2 * pi) + particle.phase,
                    ) * 20;
                    
                    return Positioned(
                      left: particle.x,
                      top: particle.y + yOffset,
                      child: _buildParticle(particle),
                    );
                  }).toList(),
                );
              },
            ),

          // Main content
          widget.child,
        ],
      ),
    );
  }

  Widget _buildCloud(double size) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
    );
  }

  Widget _buildParticle(FloatingParticle particle) {
    return Container(
      width: particle.size,
      height: particle.size,
      decoration: BoxDecoration(
        color: particle.color.withOpacity(0.6),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: particle.color.withOpacity(0.3),
            blurRadius: particle.size,
            spreadRadius: particle.size * 0.5,
          ),
        ],
      ),
    );
  }
}

/// Cloud data
class Cloud {
  final double offset;
  final double y;
  final double size;
  final double opacity;

  Cloud(this.offset, this.y, this.size, this.opacity);

  factory Cloud.random(int index) {
    final random = Random(index);
    return Cloud(
      random.nextDouble(),
      20 + random.nextDouble() * 200,
      60 + random.nextDouble() * 80,
      0.3 + random.nextDouble() * 0.4,
    );
  }
}

/// Floating particle data
class FloatingParticle {
  final double x;
  final double y;
  final double size;
  final double phase;
  final Color color;

  FloatingParticle(this.x, this.y, this.size, this.phase, this.color);

  factory FloatingParticle.random(int index) {
    final random = Random(index + 100);
    final colors = [
      TokiTheme.coralPinkLight,
      TokiTheme.mintGreenLight,
      TokiTheme.vanillaCream,
      Colors.white,
    ];
    return FloatingParticle(
      random.nextDouble() * 400,
      random.nextDouble() * 800,
      4 + random.nextDouble() * 8,
      random.nextDouble() * 2 * pi,
      colors[random.nextInt(colors.length)],
    );
  }
}

/// Sparkle effect widget for celebrations
class SparkleEffect extends StatefulWidget {
  final Widget child;
  final bool active;

  const SparkleEffect({
    super.key,
    required this.child,
    this.active = true,
  });

  @override
  State<SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Sparkle> _sparkles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    if (widget.active) {
      _generateSparkles();
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SparkleEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _generateSparkles();
      _controller.repeat();
    } else if (!widget.active && oldWidget.active) {
      _controller.stop();
    }
  }

  void _generateSparkles() {
    _sparkles.clear();
    for (int i = 0; i < 12; i++) {
      _sparkles.add(Sparkle.random(i));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,
            ..._sparkles.map((sparkle) {
              final progress = (_controller.value + sparkle.delay) % 1.0;
              final scale = progress < 0.5 
                  ? progress * 2 
                  : (1 - progress) * 2;
              
              return Positioned(
                left: sparkle.x,
                top: sparkle.y,
                child: Opacity(
                  opacity: scale,
                  child: Transform.scale(
                    scale: scale,
                    child: _buildSparkle(sparkle.size),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildSparkle(double size) {
    return Icon(
      Icons.star,
      color: TokiTheme.mintGreen,
      size: size,
    );
  }
}

class Sparkle {
  final double x;
  final double y;
  final double size;
  final double delay;

  Sparkle(this.x, this.y, this.size, this.delay);

  factory Sparkle.random(int index) {
    final random = Random(index + 200);
    return Sparkle(
      -20 + random.nextDouble() * 140,
      -20 + random.nextDouble() * 140,
      8 + random.nextDouble() * 16,
      random.nextDouble() * 0.5,
    );
  }
}

/// Bounce animation wrapper
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double height;
  final bool autoPlay;

  const BounceAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.height = 10,
    this.autoPlay = true,
  });

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.height,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.autoPlay) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: widget.child,
        );
      },
    );
  }
}
