import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../models/game_progress.dart';
import '../games/sudoku/sudoku_game_screen.dart';

class SudokuLevelScreen extends StatelessWidget {
  const SudokuLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sudoku',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<GameProgress>(
        builder: (context, progress, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Difficulty sections
              _buildDifficultySection(
                context: context,
                title: 'Easy',
                subtitle: 'Perfect for beginners',
                color: AppColors.easy,
                icon: Icons.sentiment_very_satisfied,
                startLevel: 1,
                endLevel: 10,
                unlockedLevel: progress.unlockedSudokuLevel,
                difficulty: 'easy',
              ),
              
              const SizedBox(height: 20),
              
              _buildDifficultySection(
                context: context,
                title: 'Medium',
                subtitle: 'A bit challenging',
                color: AppColors.medium,
                icon: Icons.sentiment_satisfied,
                startLevel: 11,
                endLevel: 20,
                unlockedLevel: progress.unlockedSudokuLevel,
                difficulty: 'medium',
              ),
              
              const SizedBox(height: 20),
              
              _buildDifficultySection(
                context: context,
                title: 'Hard',
                subtitle: 'For experts only!',
                color: AppColors.hard,
                icon: Icons.sentiment_very_dissatisfied,
                startLevel: 21,
                endLevel: 30,
                unlockedLevel: progress.unlockedSudokuLevel,
                difficulty: 'hard',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDifficultySection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required int startLevel,
    required int endLevel,
    required int unlockedLevel,
    required String difficulty,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Difficulty header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Level grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: endLevel - startLevel + 1,
          itemBuilder: (context, index) {
            final level = startLevel + index;
            final isUnlocked = level <= unlockedLevel;
            final gameKey = 'sudoku_${difficulty}_$level';
            final stars = context.read<GameProgress>().getStars(gameKey);
            
            return _buildLevelButton(
              level: level,
              isUnlocked: isUnlocked,
              color: color,
              stars: stars,
              onTap: isUnlocked
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SudokuGameScreen(
                          difficulty: difficulty,
                          level: level,
                        ),
                      ),
                    )
                  : null,
            ).animate()
             .fadeIn(delay: (index * 50).ms, duration: 300.ms)
             .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
          },
        ),
      ],
    );
  }

  Widget _buildLevelButton({
    required int level,
    required bool isUnlocked,
    required Color color,
    required int stars,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              level.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? color : Colors.grey,
              ),
            ),
            if (isUnlocked && stars > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Icon(
                    Icons.star,
                    size: 10,
                    color: i < stars ? AppColors.warning : Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
            if (!isUnlocked)
              const Icon(Icons.lock, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
