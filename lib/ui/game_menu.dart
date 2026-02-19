import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main.dart';

class GameMenuScreen extends StatefulWidget {
  const GameMenuScreen({super.key});

  @override
  State<GameMenuScreen> createState() => _GameMenuScreenState();
}

class _GameMenuScreenState extends State<GameMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E1),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildTitle(),
            const SizedBox(height: 20),
            _buildCharacter(),
            const SizedBox(height: 30),
            _buildSubtitle(),
            const SizedBox(height: 40),
            Expanded(
              child: _buildGameGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Game-TokTok',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFFF7B7B),
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .scale(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildCharacter() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFFF7B7B),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '🐰',
          style: TextStyle(fontSize: 60),
        ),
      ),
    ).animate()
      .bounce(duration: 800.ms, delay: 400.ms);
  }

  Widget _buildSubtitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF7BFFCE).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Agent B Games',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A4A4A),
        ),
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 600.ms);
  }

  Widget _buildGameGrid() {
    final games = [
      GameItem(
        title: 'Balloon Merge',
        icon: '🎈',
        color: const Color(0xFFFF9AA2),
        description: 'Merge floating balloons!',
        screen: const BalloonMergeScreen(),
      ),
      GameItem(
        title: 'Water Sort',
        icon: '🧪',
        color: const Color(0xFF7BFFCE),
        description: 'Sort colorful waters!',
        screen: const WaterSortScreen(),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return _buildGameCard(game, index);
        },
      ),
    );
  }

  Widget _buildGameCard(GameItem game, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => game.screen),
          );
        },
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: game.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: game.color.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: game.color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    game.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: game.color.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF9E9E9E),
                size: 20,
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: (800 + index * 200).ms)
      .slideX(begin: -0.2, end: 0, delay: (800 + index * 200).ms);
  }
}

class GameItem {
  final String title;
  final String icon;
  final Color color;
  final String description;
  final Widget screen;

  GameItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.screen,
  });
}
