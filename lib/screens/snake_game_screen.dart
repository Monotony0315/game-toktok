import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../core/audio_manager.dart';
import '../core/theme.dart';
import 'snake_game.dart';

/// Snake Game Screen - Wrapper for Flame game
class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  final AudioManager _audio = AudioManager();
  late SnakeGame _game;

  @override
  void initState() {
    super.initState();
    _game = SnakeGame();
    _playGameMusic();
  }

  Future<void> _playGameMusic() async {
    await _audio.playBgm('game');
  }

  @override
  void dispose() {
    _audio.stopBgm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TokiTheme.vanillaCream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Game area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GameWidget(
                    game: _game,
                    overlayBuilderMap: {
                      'score': (context, game) => _buildScoreOverlay(game as SnakeGame),
                      'gameOver': (context, game) => _buildGameOverOverlay(game as SnakeGame),
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              await _audio.click();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, color: TokiTheme.coralPink),
          ),
          Expanded(
            child: Text(
              'Snake',
              style: TokiTextStyles.titleLarge.copyWith(color: TokiTheme.coralPink),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildScoreOverlay(SnakeGame game) {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: TokiTheme.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: TokiTheme.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'Score: ${game.score}',
          style: TokiTextStyles.bodyLarge.copyWith(color: TokiTheme.black),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(SnakeGame game) {
    return Container(
      color: TokiTheme.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(24),
          decoration: TokiDecorations.dialog,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🐍', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                'Game Over!',
                style: TokiTextStyles.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Score: ${game.score}',
                style: TokiTextStyles.bodyLarge,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _audio.click();
                      game.restart();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TokiTheme.coralPink,
                      foregroundColor: TokiTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Play Again'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      _audio.click();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TokiTheme.grayLight,
                      foregroundColor: TokiTheme.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Menu'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
