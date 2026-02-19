import 'package:flutter/material.dart';
import 'core/navigation.dart';
import 'core/theme.dart';
import 'core/audio_manager.dart';
import 'screens/game_menu_screen.dart';
import 'screens/snake_game_screen.dart';
import 'screens/fruit_merge_game_screen.dart';
import 'screens/balloon_merge_game_screen.dart';
import 'screens/sudoku_level_screen.dart';
import 'screens/color_connect_level_screen.dart';
import 'games/water_sort/water_sort_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize audio manager
  final audio = AudioManager();
  await audio.initialize();
  
  runApp(const GameTokTokApp());
}

class GameTokTokApp extends StatelessWidget {
  const GameTokTokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game-TokTok',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: TokiTheme.coralPink,
          primary: TokiTheme.coralPink,
          secondary: TokiTheme.mintGreen,
          background: TokiTheme.vanillaCream,
        ),
        useMaterial3: true,
        fontFamily: 'Nunito',
      ),
      navigatorObservers: [TokiNavigationObserver()],
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) => const GameMenuScreen(),
        Routes.gameMenu: (context) => const GameMenuScreen(),
        Routes.snake: (context) => const SnakeGameScreen(),
        Routes.fruitMerge: (context) => const FruitMergeGameScreen(),
        Routes.balloonMerge: (context) => const BalloonMergeGameScreen(),
        Routes.waterSort: (context) => const WaterSortGameScreen(),
        Routes.sudoku: (context) => const SudokuLevelScreen(),
        Routes.colorConnect: (context) => const ColorConnectLevelScreen(),
        Routes.settings: (context) => const SettingsScreen(),
        Routes.about: (context) => const AboutScreen(),
      },
    );
  }
}

/// Placeholder settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TokiTheme.vanillaCream,
      appBar: AppBar(
        backgroundColor: TokiTheme.coralPink,
        title: Text('Settings', style: TokiTextStyles.titleLarge.copyWith(color: TokiTheme.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TokiTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings,
              size: 80,
              color: TokiTheme.coralPink.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Settings',
              style: TokiTextStyles.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon!',
              style: TokiTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder about screen
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TokiTheme.vanillaCream,
      appBar: AppBar(
        backgroundColor: TokiTheme.coralPink,
        title: Text('About', style: TokiTextStyles.titleLarge.copyWith(color: TokiTheme.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TokiTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: TokiTheme.coralPink.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐰', style: TextStyle(fontSize: 60)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Game-TokTok',
              style: TokiTextStyles.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TokiTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'A cute collection of puzzle games featuring Toki the bunny!',
                style: TokiTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Made with 💖',
              style: TokiTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
