import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../core/audio_manager.dart';
import '../core/navigation.dart';
import '../models/game_data.dart';
import '../widgets/animated_background.dart';
import '../widgets/toki_character.dart';
import '../widgets/cute_button.dart';

/// Game Menu Screen - Game selection grid
class GameMenuScreen extends StatefulWidget {
  const GameMenuScreen({super.key});

  @override
  State<GameMenuScreen> createState() => _GameMenuScreenState();
}

class _GameMenuScreenState extends State<GameMenuScreen> {
  final AudioManager _audio = AudioManager();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _audio.playBgm('menu');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onGameSelected(GameInfo game) {
    if (game.isLocked) {
      _audio.playSfx('fail');
      // Show unlock dialog
      return;
    }

    _audio.playBgm(game.bgmTrack);
    
    // Navigate to game with transition
    Navigator.of(context).push(
      TokiPageTransitions.scale(
        builder: (_) => _buildGamePlaceholder(game),
      ),
    );
  }

  Widget _buildGamePlaceholder(GameInfo game) {
    // This will be replaced by actual game screens from other agents
    return Scaffold(
      backgroundColor: TokiTheme.vanillaCream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CuteBackButton(
                    onPressed: () {
                      _audio.playBgm('menu');
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      game.name,
                      style: TokiTextStyles.titleLarge,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Placeholder content
            TokiCharacter(
              state: TokiAnimationState.happy,
              size: 120,
            ),

            const SizedBox(height: 32),

            Text(
              '${game.name} Game',
              style: TokiTextStyles.displaySmall,
            ),

            const SizedBox(height: 16),

            Text(
              'Coming soon from Agent!',
              style: TokiTextStyles.bodyMedium,
            ),

            const SizedBox(height: 8),

            Text(
              game.nameKr,
              style: TokiTextStyles.bodyLarge.copyWith(
                color: TokiTheme.coralPink,
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(24),
              child: CuteButton(
                text: 'Back to Menu',
                onPressed: () {
                  _audio.playBgm('menu');
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Toki guide
              _buildTokiGuide(),

              // Game grid
              Expanded(
                child: _buildGameGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CuteBackButton(),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Choose a Game',
              style: TokiTextStyles.titleLarge.copyWith(
                color: TokiTheme.white,
                shadows: [
                  const Shadow(
                    color: TokiTheme.shadow,
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
          SoundToggleButton(
            isMuted: _audio.isMuted,
            onChanged: (isMuted) {
              _audio.setMuted(isMuted);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTokiGuide() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          const TokiCharacter(
            state: TokiAnimationState.wave,
            size: 60,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: TokiTheme.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: TokiTheme.shadowLight,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                'Pick a game to play! Which one looks fun? 🎮',
                style: TokiTextStyles.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildGameGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: GameConfig.allGames.length,
        itemBuilder: (context, index) {
          final game = GameConfig.allGames[index];
          final color = _getGameColor(game);

          return GameCardButton(
            title: game.name,
            subtitle: game.description,
            icon: _getGameIcon(game.id),
            accentColor: color,
            isNew: game.isNew,
            isLocked: game.isLocked,
            onPressed: () => _onGameSelected(game),
          )
              .animate(delay: (index * 100).ms)
              .fadeIn(duration: 400.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              );
        },
      ),
    );
  }

  Color _getGameColor(GameInfo game) {
    switch (game.id) {
      case 'snake':
        return TokiTheme.snakeGreen;
      case 'fruit_merge':
        return TokiTheme.fruitRed;
      case 'balloon_merge':
        return TokiTheme.balloonYellow;
      case 'water_sort':
        return TokiTheme.waterBlue;
      case 'sudoku':
        return TokiTheme.sudokuPurple;
      case 'color_connect':
        return TokiTheme.connectOrange;
      default:
        return TokiTheme.coralPink;
    }
  }

  IconData _getGameIcon(String gameId) {
    switch (gameId) {
      case 'snake':
        return Icons.gradient_rounded;
      case 'fruit_merge':
        return Icons.circle;
      case 'balloon_merge':
        return Icons.circle_outlined;
      case 'water_sort':
        return Icons.water_drop_outlined;
      case 'sudoku':
        return Icons.grid_on;
      case 'color_connect':
        return Icons.linear_scale;
      default:
        return Icons.gamepad;
    }
  }
}
