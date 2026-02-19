import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'games/balloon_merge/balloon_merge_game.dart';
import 'games/water_sort/water_sort_game.dart';
import 'games/water_sort/water_sort_screen.dart';
import 'ui/game_menu.dart';

void main() {
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
          seedColor: const Color(0xFFFF7B7B),
          primary: const Color(0xFFFF7B7B),
          secondary: const Color(0xFF7BFFCE),
          background: const Color(0xFFFFF5E1),
        ),
        useMaterial3: true,
      ),
      home: const GameMenuScreen(),
    );
  }
}

class BalloonMergeScreen extends StatelessWidget {
  const BalloonMergeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E1),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, 'Balloon Merge'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GameWidget(
                    game: BalloonMergeGame(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFF7B7B)),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF7B7B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class WaterSortScreen extends StatelessWidget {
  const WaterSortScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WaterSortGameScreen();
  }
}
