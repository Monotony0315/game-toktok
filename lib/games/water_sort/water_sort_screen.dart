import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'water_sort_game.dart';

class WaterSortGameScreen extends StatefulWidget {
  const WaterSortGameScreen({super.key});

  @override
  State<WaterSortGameScreen> createState() => _WaterSortGameScreenState();
}

class _WaterSortGameScreenState extends State<WaterSortGameScreen> {
  late final WaterSortGame game;

  @override
  void initState() {
    super.initState();
    game = WaterSortGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E1),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GameWidget(
                    game: game,
                    overlayBuilderMap: {
                      'win': (context, game) => WinOverlay(
                            game: game as WaterSortGame,
                            onNextLevel: () => (game as WaterSortGame).nextLevel(),
                          ),
                    },
                  ),
                ),
              ),
            ),
            _buildControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF7BFFCE)),
          ),
          const Expanded(
            child: Text(
              'Water Sort',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7BFFCE),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              game.restart();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Restart'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7BFFCE),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WinOverlay extends StatelessWidget {
  final WaterSortGame game;
  final VoidCallback onNextLevel;

  const WinOverlay({
    super.key,
    required this.game,
    required this.onNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5E1),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 16),
              const Text(
                'Level Complete!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7BFFCE),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Great job sorting!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onNextLevel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7BFFCE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Next Level →',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
