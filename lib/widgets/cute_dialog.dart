import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import 'cute_button.dart';
import 'toki_character.dart';

/// Cute dialog with Toki theme
class CuteDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final bool showToki;
  final TokiAnimationState tokiState;
  final String? tokiMessage;

  const CuteDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.showToki = true,
    this.tokiState = TokiAnimationState.idle,
    this.tokiMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: TokiDecorations.dialog,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toki character
              if (showToki) ...[
                TokiCharacter(
                  state: tokiState,
                  size: 80,
                ),
                const SizedBox(height: 12),
              ],

              // Toki speech bubble
              if (tokiMessage != null) ...[
                TokiSpeechBubble(text: tokiMessage!),
                const SizedBox(height: 16),
              ],

              // Title
              Text(
                title,
                style: TokiTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Message or content
              if (message != null)
                Text(
                  message!,
                  style: TokiTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                )
              else if (content != null)
                content!,

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  if (secondaryButtonText != null) ...[
                    Expanded(
                      child: CuteButton(
                        text: secondaryButtonText!,
                        color: TokiTheme.grayLight,
                        textColor: TokiTheme.grayDark,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onSecondaryPressed?.call();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (primaryButtonText != null)
                    Expanded(
                      child: CuteButton(
                        text: primaryButtonText!,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onPrimaryPressed?.call();
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: 300.ms,
        curve: Curves.easeOutBack,
      )
      .fadeIn(duration: 200.ms);
  }

  /// Show the dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String? primaryButtonText = 'OK',
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool showToki = true,
    TokiAnimationState tokiState = TokiAnimationState.idle,
    String? tokiMessage,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CuteDialog(
        title: title,
        message: message,
        content: content,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        showToki: showToki,
        tokiState: tokiState,
        tokiMessage: tokiMessage,
      ),
    );
  }
}

/// Pause game dialog
class PauseDialog extends StatelessWidget {
  final VoidCallback? onResume;
  final VoidCallback? onRestart;
  final VoidCallback? onQuit;

  const PauseDialog({
    super.key,
    this.onResume,
    this.onRestart,
    this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return CuteDialog(
      title: 'Game Paused',
      showToki: true,
      tokiState: TokiAnimationState.idle,
      tokiMessage: 'Take a break! 🐰',
      content: Column(
        children: [
          const SizedBox(height: 8),
          _buildMenuButton(
            icon: Icons.play_arrow_rounded,
            label: 'Resume',
            color: TokiTheme.mintGreen,
            onTap: () {
              Navigator.of(context).pop();
              onResume?.call();
            },
          ),
          const SizedBox(height: 12),
          _buildMenuButton(
            icon: Icons.refresh_rounded,
            label: 'Restart',
            color: TokiTheme.coralPinkLight,
            onTap: () {
              Navigator.of(context).pop();
              onRestart?.call();
            },
          ),
          const SizedBox(height: 12),
          _buildMenuButton(
            icon: Icons.exit_to_app_rounded,
            label: 'Quit Game',
            color: TokiTheme.grayLight,
            onTap: () {
              Navigator.of(context).pop();
              onQuit?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color.withOpacity(0.8)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TokiTextStyles.bodyLarge.copyWith(
                color: TokiTheme.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    VoidCallback? onResume,
    VoidCallback? onRestart,
    VoidCallback? onQuit,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PauseDialog(
        onResume: onResume,
        onRestart: onRestart,
        onQuit: onQuit,
      ),
    );
  }
}

/// Game over dialog
class GameOverDialog extends StatelessWidget {
  final int score;
  final int? highScore;
  final bool isNewHighScore;
  final VoidCallback? onPlayAgain;
  final VoidCallback? onQuit;

  const GameOverDialog({
    super.key,
    required this.score,
    this.highScore,
    this.isNewHighScore = false,
    this.onPlayAgain,
    this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return CuteDialog(
      title: isNewHighScore ? '🎉 New Record!' : 'Game Over',
      showToki: true,
      tokiState: isNewHighScore ? TokiAnimationState.happy : TokiAnimationState.idle,
      tokiMessage: isNewHighScore 
          ? 'Amazing job! You\'re the best!' 
          : 'Good try! Play again?',
      content: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: TokiDecorations.scoreBoard,
            child: Column(
              children: [
                Text(
                  'Score',
                  style: TokiTextStyles.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  score.toString(),
                  style: TokiTextStyles.score,
                ),
              ],
            ),
          ),
          if (highScore != null) ...[
            const SizedBox(height: 12),
            Text(
              'Best: $highScore',
              style: TokiTextStyles.bodySmall,
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
      primaryButtonText: 'Play Again',
      secondaryButtonText: 'Quit',
      onPrimaryPressed: onPlayAgain,
      onSecondaryPressed: onQuit,
    );
  }

  static Future<void> show({
    required BuildContext context,
    required int score,
    int? highScore,
    bool isNewHighScore = false,
    VoidCallback? onPlayAgain,
    VoidCallback? onQuit,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        score: score,
        highScore: highScore,
        isNewHighScore: isNewHighScore,
        onPlayAgain: onPlayAgain,
        onQuit: onQuit,
      ),
    );
  }
}

/// Level complete dialog
class LevelCompleteDialog extends StatelessWidget {
  final int level;
  final int score;
  final int stars;
  final VoidCallback? onNextLevel;
  final VoidCallback? onReplay;

  const LevelCompleteDialog({
    super.key,
    required this.level,
    required this.score,
    required this.stars,
    this.onNextLevel,
    this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return CuteDialog(
      title: 'Level Complete!',
      showToki: true,
      tokiState: TokiAnimationState.happy,
      tokiMessage: 'Level $level finished! 🌟',
      content: Column(
        children: [
          const SizedBox(height: 16),
          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: index < stars ? TokiTheme.balloonYellow : TokiTheme.grayLight,
                  size: 40,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Score
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: TokiDecorations.scoreBoard,
            child: Text(
              score.toString(),
              style: TokiTextStyles.score.copyWith(fontSize: 28),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      primaryButtonText: 'Next Level',
      secondaryButtonText: 'Replay',
      onPrimaryPressed: onNextLevel,
      onSecondaryPressed: onReplay,
    );
  }

  static Future<void> show({
    required BuildContext context,
    required int level,
    required int score,
    required int stars,
    VoidCallback? onNextLevel,
    VoidCallback? onReplay,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelCompleteDialog(
        level: level,
        score: score,
        stars: stars,
        onNextLevel: onNextLevel,
        onReplay: onReplay,
      ),
    );
  }
}

/// Confirmation dialog
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Yes',
    this.cancelText = 'No',
    this.confirmColor,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return CuteDialog(
      title: title,
      message: message,
      showToki: true,
      tokiState: TokiAnimationState.surprised,
      tokiMessage: 'Are you sure?',
      primaryButtonText: confirmText,
      secondaryButtonText: cancelText,
      onPrimaryPressed: onConfirm,
      onSecondaryPressed: onCancel,
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
    Color? confirmColor,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}
