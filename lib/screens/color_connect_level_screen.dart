import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../models/game_progress.dart';
import '../games/color_connect/color_connect_game_screen.dart';

class ColorConnectLevelScreen extends StatelessWidget {
  const ColorConnectLevelScreen({super.key});

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
          'Color Connect',
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
              // Grid size sections
              _buildGridSizeSection(
                context: context,
                size: 5,
                color: AppColors.flowColors[0],
                levels: 10,
                unlockedLevel: progress.unlockedColorConnectLevel,
              ),
              
              const SizedBox(height: 20),
              
              _buildGridSizeSection(
                context: context,
                size: 6,
                color: AppColors.flowColors[1],
                levels: 10,
                startLevel: 11,
                unlockedLevel: progress.unlockedColorConnectLevel,
              ),
              
              const SizedBox(height: 20),
              
              _buildGridSizeSection(
                context: context,
                size: 7,
                color: AppColors.flowColors[2],
                levels: 10,
                startLevel: 21,
                unlockedLevel: progress.unlockedColorConnectLevel,
              ),
              
              const SizedBox(height: 20),
              
              _buildGridSizeSection(
                context: context,
                size: 8,
                color: AppColors.flowColors[3],
                levels: 10,
                startLevel: 31,
                unlockedLevel: progress.unlockedColorConnectLevel,
              ),
              
              const SizedBox(height: 20),
              
              _buildGridSizeSection(
                context: context,
                size: 9,
                color: AppColors.flowColors[4],
                levels: 10,
                startLevel: 41,
                unlockedLevel: progress.unlockedColorConnectLevel,
              ),
              
              const SizedBox(height: 20),
              
              _buildGridSizeSection(
                context: context,
                size: 10,
                color: AppColors.flowColors[5],
                levels: 10,
                startLevel: 51,
                unlockedLevel: progress.unlockedColorConnectLevel,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGridSizeSection({
    required BuildContext context,
    required int size,
    required Color color,
    required int levels,
    int startLevel = 1,
    required int unlockedLevel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid size header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${size}x$size',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$size x $size Grid',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '${startLevel}-${startLevel + levels - 1}',
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
          itemCount: levels,
          itemBuilder: (context, index) {
            final level = startLevel + index;
            final isUnlocked = level <= unlockedLevel;
            final gameKey = 'color_${size}_$level';
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
                        builder: (_) => ColorConnectGameScreen(
                          gridSize: size,
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
