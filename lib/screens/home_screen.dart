import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/colors.dart';
import 'sudoku_level_screen.dart';
import 'color_connect_level_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // App title with Toki mascot
            Column(
              children: [
                // Toki mascot icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPink.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🐱',
                      style: TextStyle(fontSize: 60),
                    ),
                  ),
                ).animate()
                 .scale(duration: 600.ms, curve: Curves.elasticOut)
                 .then()
                 .shake(duration: 400.ms),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Game-TokTok',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ).animate()
                 .fadeIn(duration: 500.ms)
                 .slideY(begin: -0.2, end: 0),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Cute puzzle games with Toki!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textLight,
                  ),
                ).animate()
                 .fadeIn(delay: 200.ms, duration: 500.ms),
              ],
            ),
            
            const SizedBox(height: 60),
            
            // Game cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildGameCard(
                      context: context,
                      title: 'Sudoku',
                      subtitle: 'Classic number puzzle',
                      icon: '🔢',
                      color: AppColors.tile5,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SudokuLevelScreen(),
                        ),
                      ),
                    ).animate()
                     .fadeIn(delay: 400.ms, duration: 500.ms)
                     .slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 20),
                    
                    _buildGameCard(
                      context: context,
                      title: 'Color Connect',
                      subtitle: 'Connect the colors!',
                      icon: '🌈',
                      color: AppColors.tile4,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ColorConnectLevelScreen(),
                        ),
                      ),
                    ).animate()
                     .fadeIn(delay: 600.ms, duration: 500.ms)
                     .slideX(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Footer
            const Text(
              'Made with 💖 by Toki',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ).animate()
             .fadeIn(delay: 800.ms, duration: 500.ms),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 36),
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
