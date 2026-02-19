import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GameTokTokApp());
}

class GameTokTokApp extends StatelessWidget {
  const GameTokTokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game TokTok 🐰',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB7C5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: const Color(0xFFFFF0F5),
      ),
      home: const HomeScreen(),
    );
  }
}
