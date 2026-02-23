import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/theme.dart';
import '../core/storage.dart';
import '../core/navigation.dart';

/// Main game menu screen with all 6 mini-games
class GameMenuScreen extends StatefulWidget {
  const GameMenuScreen({super.key});

  @override
  State<GameMenuScreen> createState() => _GameMenuScreenState();
}

class _GameMenuScreenState extends State<GameMenuScreen> {
  final AudioManager _audio = AudioManager();
  final GameStorage _storage = GameStorage();
  Map<String, int> _highScores = {};
  int _totalScore = 0;

  @override
  void initState() {
    super.initState();
    _loadScores();
    _playMenuMusic();
  }

  Future<void> _loadScores() async {
    await _storage.initialize();
    setState(() {
      _highScores = _storage.getAllHighScores();
      _totalScore = _storage.getTotalScore();
    });
  }

  Future<void> _playMenuMusic() async {
    await _audio.initialize();
    await _audio.playBgm('menu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TokiTheme.vanillaCream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with Toki mascot area
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            
            // Game grid
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildListDelegate([
                  _buildGameCard(
                    title: 'Snake',
                    icon: Icons.route,
                    color: TokiTheme.snakeGreen,
                    route: Routes.snake,
                    highScore: _highScores['snake'] ?? 0,
                  ),
                  _buildGameCard(
                    title: 'Fruit Merge',
                    icon: Icons.grain,
                    color: TokiTheme.fruitRed,
                    route: Routes.fruitMerge,
                    highScore: _highScores['fruit_merge'] ?? 0,
                  ),
                  _buildGameCard(
                    title: 'Balloon Merge',
                    icon: Icons.bubble_chart,
                    color: TokiTheme.balloonYellow,
                    route: Routes.balloonMerge,
                    highScore: _highScores['balloon_merge'] ?? 0,
                  ),
                  _buildGameCard(
                    title: 'Water Sort',
                    icon: Icons.water_drop,
                    color: TokiTheme.waterBlue,
                    route: Routes.waterSort,
                    highScore: _highScores['water_sort'] ?? 0,
                  ),
                  _buildGameCard(
                    title: 'Sudoku',
                    icon: Icons.grid_on,
                    color: TokiTheme.sudokuPurple,
                    route: Routes.sudoku,
                    highScore: _highScores['sudoku'] ?? 0,
                  ),
                  _buildGameCard(
                    title: 'Color Connect',
                    icon: Icons.circle,
                    color: TokiTheme.connectOrange,
                    route: Routes.colorConnect,
                    highScore: _highScores['color_connect'] ?? 0,
                  ),
                ]),
              ),
            ),
            
            // Footer with settings button
            SliverToBoxAdapter(
              child: _buildFooter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Title
          Text(
            'Game-TokTok',
            style: TokiTextStyles.displayLarge.copyWith(
              fontSize: 42,
            ),
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            'Play with Toki! 🐰',
            style: TokiTextStyles.titleMedium.copyWith(
              color: TokiTheme.gray,
            ),
          ),
          const SizedBox(height: 16),
          
          // Total score display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: TokiDecorations.scoreBoard,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: TokiTheme.mintGreenDark,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total Score: $_totalScore',
                  style: TokiTextStyles.score.copyWith(fontSize: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required IconData icon,
    required Color color,
    required String route,
    required int highScore,
  }) {
    return GestureDetector(
      onTap: () => _onGameSelected(route),
      child: Container(
        decoration: TokiDecorations.gameCard(color),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            
            // Game title
            Text(
              title,
              style: TokiTextStyles.titleSmall.copyWith(
                color: TokiTheme.black,
              ),
            ),
            const SizedBox(height: 8),
            
            // High score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: TokiTheme.mintGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Best: $highScore',
                style: TokiTextStyles.bodySmall.copyWith(
                  color: TokiTheme.mintGreenDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Settings button
          _buildActionButton(
            icon: Icons.settings,
            onTap: () => _onSettingsPressed(),
          ),
          const SizedBox(width: 16),
          
          // Sound toggle button
          _buildActionButton(
            icon: _audio.isMuted ? Icons.volume_off : Icons.volume_up,
            onTap: () => _onToggleSound(),
          ),
          const SizedBox(width: 16),
          
          // About button
          _buildActionButton(
            icon: Icons.info_outline,
            onTap: () => _onAboutPressed(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: TokiDecorations.circularButton(TokiTheme.white),
        child: Icon(
          icon,
          color: TokiTheme.coralPink,
          size: 24,
        ),
      ),
    );
  }

  void _onGameSelected(String route) async {
    await _audio.click();
    if (mounted) {
      Navigator.pushNamed(context, route);
    }
  }

  void _onSettingsPressed() async {
    await _audio.click();
    if (mounted) {
      Navigator.pushNamed(context, Routes.settings);
    }
  }

  void _onToggleSound() async {
    await _audio.toggleMute();
    setState(() {});
  }

  void _onAboutPressed() async {
    await _audio.click();
    if (mounted) {
      Navigator.pushNamed(context, Routes.about);
    }
  }
}
