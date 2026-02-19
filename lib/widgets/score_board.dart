import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';

/// Score board display widget
class ScoreBoard extends StatelessWidget {
  final int score;
  final int? highScore;
  final int? level;
  final int? moves;
  final int? timeSeconds;
  final bool showBest;
  final bool animate;

  const ScoreBoard({
    super.key,
    required this.score,
    this.highScore,
    this.level,
    this.moves,
    this.timeSeconds,
    this.showBest = true,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: const EdgeInsets.all(16),
      decoration: TokiDecorations.scoreBoard,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main score
          _buildScoreItem(
            label: 'SCORE',
            value: score.toString(),
            isMain: true,
          ),

          if (showBest && highScore != null) ...[
            Container(
              height: 40,
              width: 1,
              color: TokiTheme.grayLight,
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            _buildScoreItem(
              label: 'BEST',
              value: highScore.toString(),
              isMain: false,
            ),
          ],

          if (level != null) ...[
            Container(
              height: 40,
              width: 1,
              color: TokiTheme.grayLight,
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            _buildScoreItem(
              label: 'LEVEL',
              value: level.toString(),
              isMain: false,
            ),
          ],

          if (moves != null) ...[
            Container(
              height: 40,
              width: 1,
              color: TokiTheme.grayLight,
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            _buildScoreItem(
              label: 'MOVES',
              value: moves.toString(),
              isMain: false,
            ),
          ],

          if (timeSeconds != null) ...[
            Container(
              height: 40,
              width: 1,
              color: TokiTheme.grayLight,
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            _buildScoreItem(
              label: 'TIME',
              value: _formatTime(timeSeconds!),
              isMain: false,
            ),
          ],
        ],
      ),
    );

    if (animate) {
      content = content
          .animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: -0.2, end: 0, duration: 300.ms);
    }

    return content;
  }

  Widget _buildScoreItem({
    required String label,
    required String value,
    required bool isMain,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: isMain 
              ? TokiTextStyles.bodySmall
              : TokiTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  color: TokiTheme.gray,
                ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: isMain
              ? TokiTextStyles.score
              : TokiTextStyles.titleSmall.copyWith(
                  color: TokiTheme.grayDark,
                ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

/// Compact score display for in-game HUD
class CompactScore extends StatelessWidget {
  final int score;
  final VoidCallback? onPause;

  const CompactScore({
    super.key,
    required this.score,
    this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: TokiTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: TokiTheme.shadowLight,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score.toString(),
            style: TokiTextStyles.score.copyWith(fontSize: 24),
          ),
          if (onPause != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onPause,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: TokiTheme.coralPinkLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  color: TokiTheme.coralPink,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Level progress indicator
class LevelProgress extends StatelessWidget {
  final int current;
  final int total;
  final int stars;

  const LevelProgress({
    super.key,
    required this.current,
    required this.total,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: TokiTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: TokiTheme.shadowLight,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Level number
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TokiTheme.mintGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                current.toString(),
                style: TokiTextStyles.button.copyWith(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level $current of $total',
                  style: TokiTextStyles.bodySmall,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: current / total,
                    backgroundColor: TokiTheme.grayLight,
                    valueColor: const AlwaysStoppedAnimation(TokiTheme.mintGreen),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Stars
          Row(
            children: List.generate(3, (index) {
              return Icon(
                index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: index < stars ? TokiTheme.balloonYellow : TokiTheme.grayLight,
                size: 20,
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Achievement badge widget
class AchievementBadge extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementBadge({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = true,
    this.unlockedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked ? color.withOpacity(0.1) : TokiTheme.grayLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? color.withOpacity(0.3) : TokiTheme.grayLight,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUnlocked ? color.withOpacity(0.2) : TokiTheme.grayLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isUnlocked ? icon : Icons.lock_outline,
                color: isUnlocked ? color : TokiTheme.gray,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TokiTextStyles.bodyLarge.copyWith(
                      color: isUnlocked ? TokiTheme.black : TokiTheme.gray,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TokiTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (unlockedAt != null && isUnlocked) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Unlocked ${_formatDate(unlockedAt!)}',
                      style: TokiTextStyles.bodySmall.copyWith(
                        fontSize: 10,
                        color: color,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Stats card for profile/stats screen
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TokiTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: TokiTheme.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TokiTextStyles.displaySmall.copyWith(
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TokiTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Animated score counter
class AnimatedScore extends StatefulWidget {
  final int score;
  final Duration duration;
  final TextStyle? style;

  const AnimatedScore({
    super.key,
    required this.score,
    this.duration = const Duration(milliseconds: 500),
    this.style,
  });

  @override
  State<AnimatedScore> createState() => _AnimatedScoreState();
}

class _AnimatedScoreState extends State<AnimatedScore>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _previousScore = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _setupAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedScore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _previousScore = oldWidget.score;
      _setupAnimation();
      _controller.forward(from: 0);
    }
  }

  void _setupAnimation() {
    _animation = IntTween(
      begin: _previousScore,
      end: widget.score,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _animation.value.toString(),
          style: widget.style ?? TokiTextStyles.score,
        );
      },
    );
  }
}
