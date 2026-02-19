import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../games/snake/snake_game.dart';
import '../games/fruit_merge/fruit_merge_game.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F5),
              Color(0xFFFFE4E1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Title with bunny emoji
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🐰',
                    style: TextStyle(fontSize: 50),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Game TokTok',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF6B9D),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '🐰',
                    style: TextStyle(fontSize: 50),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Cute Games for Everyone!',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 60),
              // Game Selection Cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _GameCard(
                        title: 'Snake Game',
                        subtitle: 'Help Toki collect fruits!',
                        emoji: '🐍',
                        color: const Color(0xFF98FB98),
                        accentColor: const Color(0xFF32CD32),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SnakeGameScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _GameCard(
                        title: 'Fruit Merge',
                        subtitle: 'Merge fruits, get watermelon!',
                        emoji: '🍉',
                        color: const Color(0xFFFFB6C1),
                        accentColor: const Color(0xFFFF1493),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FruitMergeGameScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final Color accentColor;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: accentColor.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: accentColor.withOpacity(0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class SnakeGameScreen extends StatelessWidget {
  const SnakeGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: SnakeGame(),
        overlayBuilderMap: {
          'gameOver': (context, game) => GameOverOverlay(
                score: (game as SnakeGame).score,
                onRestart: () => (game).restart(),
                onHome: () => Navigator.pop(context),
              ),
          'score': (context, game) => ScoreOverlay(
                score: (game as SnakeGame).score,
              ),
        },
        initialActiveOverlays: const ['score'],
      ),
    );
  }
}

class FruitMergeGameScreen extends StatelessWidget {
  const FruitMergeGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: FruitMergeGame(),
        overlayBuilderMap: {
          'gameOver': (context, game) => GameOverOverlay(
                score: (game as FruitMergeGame).score,
                onRestart: () => (game).restart(),
                onHome: () => Navigator.pop(context),
                title: 'Game Over!',
              ),
          'score': (context, game) => ScoreOverlay(
                score: (game as FruitMergeGame).score,
              ),
        },
        initialActiveOverlays: const ['score'],
      ),
    );
  }
}

class ScoreOverlay extends StatelessWidget {
  final int score;

  const ScoreOverlay({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '⭐ Score: ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF6B9D),
                ),
              ),
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF6B9D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  final int score;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final String title;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.onRestart,
    required this.onHome,
    this.title = 'Game Over!',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B9D).withOpacity(0.3),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🐰',
                style: TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF6B9D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Score: $score',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 32),
              _ActionButton(
                text: 'Play Again',
                icon: Icons.replay,
                color: const Color(0xFF98FB98),
                textColor: const Color(0xFF228B22),
                onTap: onRestart,
              ),
              const SizedBox(height: 12),
              _ActionButton(
                text: 'Home',
                icon: Icons.home,
                color: const Color(0xFFFFB6C1),
                textColor: const Color(0xFFFF1493),
                onTap: onHome,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
