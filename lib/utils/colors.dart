import 'package:flutter/material.dart';

class AppColors {
  // Pastel color palette
  static const Color background = Color(0xFFFFF5F7);
  static const Color primaryPink = Color(0xFFFFB7C5);
  static const Color secondaryPink = Color(0xFFFFE4E1);
  static const Color accentPink = Color(0xFFFF69B4);
  
  // Game tile colors - Pastel palette
  static const Color tile1 = Color(0xFFFFB3BA); // Soft Pink
  static const Color tile2 = Color(0xFFFFDFBA); // Peach
  static const Color tile3 = Color(0xFFFFFFBA); // Pastel Yellow
  static const Color tile4 = Color(0xFFBAFFC9); // Mint Green
  static const Color tile5 = Color(0xFFBAE1FF); // Baby Blue
  static const Color tile6 = Color(0xFFE6B3FF); // Lavender
  static const Color tile7 = Color(0xFFFFB3E6); // Light Magenta
  static const Color tile8 = Color(0xFFB3FFFF); // Cyan
  static const Color tile9 = Color(0xFFFFD9B3); // Light Orange
  
  // Color Connect colors
  static const List<Color> flowColors = [
    Color(0xFFFF6B6B), // Coral Red
    Color(0xFF4ECDC4), // Turquoise
    Color(0xFFFFE66D), // Sunny Yellow
    Color(0xFF95E1D3), // Mint
    Color(0xFFF38181), // Salmon Pink
    Color(0xFFAA96DA), // Purple
    Color(0xFFFCBAD3), // Baby Pink
    Color(0xFFFFD93D), // Golden Yellow
    Color(0xFF6BCB77), // Green
    Color(0xFF4D96FF), // Blue
  ];
  
  // UI Colors
  static const Color textDark = Color(0xFF2D3436);
  static const Color textLight = Color(0xFF636E72);
  static const Color success = Color(0xFF55EFC4);
  static const Color warning = Color(0xFFFFEAA7);
  static const Color error = Color(0xFFFF7675);
  
  // Difficulty colors
  static const Color easy = Color(0xFF55EFC4);
  static const Color medium = Color(0xFFFFEAA7);
  static const Color hard = Color(0xFFFF7675);
}

extension ColorExtension on Color {
  Color withLightness(double lightness) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness * lightness).clamp(0.0, 1.0)).toColor();
  }
}
