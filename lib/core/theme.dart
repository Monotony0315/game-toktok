import 'package:flutter/material.dart';

/// Toki Theme - Cute pastel color palette for Game-TokTok
class TokiTheme {
  TokiTheme._();

  // Primary Colors
  static const Color coralPink = Color(0xFFFF7B7B);
  static const Color coralPinkLight = Color(0xFFFFA5A5);
  static const Color coralPinkDark = Color(0xFFE85A5A);
  
  // Secondary Colors
  static const Color vanillaCream = Color(0xFFFFF5E1);
  static const Color vanillaCreamDark = Color(0xFFF5E6C8);
  
  // Accent Colors
  static const Color mintGreen = Color(0xFF7BFFCE);
  static const Color mintGreenLight = Color(0xFFA8FFDE);
  static const Color mintGreenDark = Color(0xFF5DE0B0);
  
  // Background Colors
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color skyBlueLight = Color(0xFFB8E6F0);
  static const Color skyGradientStart = Color(0xFF87CEEB);
  static const Color skyGradientEnd = Color(0xFFE0F6FF);
  
  // Game-specific colors
  static const Color snakeGreen = Color(0xFF90EE90);
  static const Color fruitRed = Color(0xFFFF6B6B);
  static const Color balloonYellow = Color(0xFFFFE66D);
  static const Color waterBlue = Color(0xFF4ECDC4);
  static const Color sudokuPurple = Color(0xFF9B59B6);
  static const Color connectOrange = Color(0xFFFFA07A);
  
  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Color(0xFF2D3436);
  static const Color gray = Color(0xFF95A5A6);
  static const Color grayLight = Color(0xFFBDC3C7);
  static const Color grayDark = Color(0xFF7F8C8D);
  
  // Status Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  
  // Shadow Colors
  static const Color shadow = Color(0x3D000000);
  static const Color shadowLight = Color(0x1F000000);

  /// Main gradient for background
  static LinearGradient get backgroundGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyGradientStart, skyGradientEnd],
  );

  /// Cute button gradient
  static LinearGradient get buttonGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [coralPinkLight, coralPink],
  );

  /// Mint button gradient
  static LinearGradient get mintButtonGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mintGreenLight, mintGreen],
  );

  /// Card gradient
  static LinearGradient get cardGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [white, vanillaCream],
  );
}

/// Toki Text Styles
class TokiTextStyles {
  TokiTextStyles._();

  static const String fontFamily = 'Nunito';

  static TextStyle get displayLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: TokiTheme.coralPink,
    shadows: [
      Shadow(
        color: TokiTheme.shadow,
        blurRadius: 4,
        offset: Offset(2, 2),
      ),
    ],
  );

  static TextStyle get displayMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: TokiTheme.coralPink,
  );

  static TextStyle get displaySmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: TokiTheme.black,
  );

  static TextStyle get titleLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: TokiTheme.black,
  );

  static TextStyle get titleMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: TokiTheme.black,
  );

  static TextStyle get titleSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: TokiTheme.black,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: TokiTheme.black,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: TokiTheme.grayDark,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: TokiTheme.gray,
  );

  static TextStyle get button => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: TokiTheme.white,
  );

  static TextStyle get score => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: TokiTheme.mintGreenDark,
    shadows: [
      Shadow(
        color: TokiTheme.shadowLight,
        blurRadius: 2,
        offset: Offset(1, 1),
      ),
    ],
  );
}

/// Toki Decoration Styles
class TokiDecorations {
  TokiDecorations._();

  /// Cute rounded card
  static BoxDecoration get card => BoxDecoration(
    gradient: TokiTheme.cardGradient,
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(
        color: TokiTheme.shadowLight,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );

  /// Game card with border
  static BoxDecoration gameCard(Color accentColor) => BoxDecoration(
    color: TokiTheme.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: accentColor.withOpacity(0.3),
      width: 3,
    ),
    boxShadow: [
      BoxShadow(
        color: accentColor.withOpacity(0.2),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );

  /// Cute button
  static BoxDecoration get button => BoxDecoration(
    gradient: TokiTheme.buttonGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(
        color: TokiTheme.coralPinkDark,
        blurRadius: 0,
        offset: Offset(0, 4),
      ),
    ],
  );

  /// Mint button
  static BoxDecoration get mintButton => BoxDecoration(
    gradient: TokiTheme.mintButtonGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(
        color: TokiTheme.mintGreenDark,
        blurRadius: 0,
        offset: Offset(0, 4),
      ),
    ],
  );

  /// Circular button
  static BoxDecoration circularButton(Color color) => BoxDecoration(
    color: color,
    shape: BoxShape.circle,
    boxShadow: const [
      BoxShadow(
        color: TokiTheme.shadowLight,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );

  /// Dialog box
  static BoxDecoration get dialog => BoxDecoration(
    color: TokiTheme.vanillaCream,
    borderRadius: BorderRadius.circular(32),
    border: Border.all(
      color: TokiTheme.coralPinkLight,
      width: 4,
    ),
    boxShadow: const [
      BoxShadow(
        color: TokiTheme.shadow,
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  );

  /// Score board
  static BoxDecoration get scoreBoard => BoxDecoration(
    color: TokiTheme.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: TokiTheme.mintGreen,
      width: 3,
    ),
    boxShadow: const [
      BoxShadow(
        color: TokiTheme.shadowLight,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  );
}

/// Game color palette for each mini-game
class GameColors {
  GameColors._();

  static const List<Color> snake = [
    Color(0xFF90EE90),
    Color(0xFF32CD32),
  ];

  static const List<Color> fruitMerge = [
    Color(0xFFFF6B6B), // Cherry
    Color(0xFFFF8E8E), // Strawberry
    Color(0xFF9B59B6), // Grape
    Color(0xFFFFA500), // Orange
    Color(0xFFFF6B6B), // Apple
    Color(0xFFFFD700), // Pear
    Color(0xFFFFB6C1), // Peach
    Color(0xFFFFD700), // Pineapple
    Color(0xFF90EE90), // Melon
    Color(0xFF2ECC71), // Watermelon
  ];

  static const List<Color> balloonMerge = [
    Color(0xFFFF6B6B),
    Color(0xFFFFE66D),
    Color(0xFF4ECDC4),
    Color(0xFF9B59B6),
    Color(0xFFFFA07A),
    Color(0xFF87CEEB),
  ];

  static const List<Color> waterSort = [
    Color(0xFFFF6B6B),
    Color(0xFFFFE66D),
    Color(0xFF4ECDC4),
    Color(0xFF9B59B6),
    Color(0xFFFFA07A),
    Color(0xFF87CEEB),
    Color(0xFF2ECC71),
    Color(0xFFFF69B4),
  ];

  static const List<Color> sudoku = [
    Color(0xFF9B59B6),
    Color(0xFF87CEEB),
    Color(0xFF2ECC71),
  ];

  static const List<Color> colorConnect = [
    Color(0xFFFF6B6B),
    Color(0xFFFFE66D),
    Color(0xFF4ECDC4),
    Color(0xFF9B59B6),
    Color(0xFFFFA07A),
    Color(0xFF87CEEB),
    Color(0xFF2ECC71),
    Color(0xFFFF69B4),
    Color(0xFF1ABC9C),
    Color(0xFFF39C12),
  ];
}
