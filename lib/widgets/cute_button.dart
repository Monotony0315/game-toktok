import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/audio_manager.dart';

/// Cute button with bounce animation and sound effects
class CuteButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final double width;
  final double height;
  final Widget? icon;
  final bool isLoading;
  final bool isDisabled;

  const CuteButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.textColor,
    this.width = double.infinity,
    this.height = 56,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  State<CuteButton> createState() => _CuteButtonState();
}

class _CuteButtonState extends State<CuteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final AudioManager _audio = AudioManager();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.reverse();
      _audio.playSfx('click');
      widget.onPressed?.call();
    }
  }

  void _onTapCancel() {
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.color == null;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: isPrimary
                  ? TokiDecorations.button
                  : BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.color ?? TokiTheme.coralPink)
                              .withOpacity(0.4),
                          blurRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: TokiTheme.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            widget.icon!,
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TokiTextStyles.button.copyWith(
                              color: widget.isDisabled
                                  ? TokiTheme.gray
                                  : (widget.textColor ?? TokiTheme.white),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Small circular icon button
class CuteIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? iconColor;
  final double size;

  const CuteIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.iconColor,
    this.size = 48,
  });

  @override
  State<CuteIconButton> createState() => _CuteIconButtonState();
}

class _CuteIconButtonState extends State<CuteIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final AudioManager _audio = AudioManager();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        _audio.playSfx('click');
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: TokiDecorations.circularButton(
                widget.color ?? TokiTheme.white,
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor ?? TokiTheme.coralPink,
                size: widget.size * 0.4,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Game card button for the game menu
class GameCardButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onPressed;
  final bool isNew;
  final bool isLocked;

  const GameCardButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.onPressed,
    this.isNew = false,
    this.isLocked = false,
  });

  @override
  State<GameCardButton> createState() => _GameCardButtonState();
}

class _GameCardButtonState extends State<GameCardButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final AudioManager _audio = AudioManager();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLocked) _controller.forward();
      },
      onTapUp: (_) {
        if (!widget.isLocked) {
          _controller.reverse();
          _audio.playSfx('pop');
          widget.onPressed?.call();
        }
      },
      onTapCancel: () {
        if (!widget.isLocked) _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: TokiDecorations.gameCard(widget.accentColor),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.accentColor.withOpacity(0.1),
                              widget.accentColor.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: widget.accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  widget.isLocked 
                                      ? Icons.lock 
                                      : widget.icon,
                                  color: widget.isLocked
                                      ? TokiTheme.gray
                                      : widget.accentColor,
                                  size: 28,
                                ),
                              ),
                              if (widget.isNew)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: TokiTheme.mintGreen,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: TokiTextStyles.bodySmall.copyWith(
                                      color: TokiTheme.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            widget.title,
                            style: TokiTextStyles.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TokiTextStyles.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Lock overlay
                    if (widget.isLocked)
                      Container(
                        decoration: BoxDecoration(
                          color: TokiTheme.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Back button with cute styling
class CuteBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CuteBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CuteIconButton(
      icon: Icons.arrow_back_ios_new_rounded,
      color: TokiTheme.white.withOpacity(0.9),
      iconColor: TokiTheme.coralPink,
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}

/// Sound toggle button
class SoundToggleButton extends StatefulWidget {
  final bool isMuted;
  final ValueChanged<bool>? onChanged;

  const SoundToggleButton({
    super.key,
    this.isMuted = false,
    this.onChanged,
  });

  @override
  State<SoundToggleButton> createState() => _SoundToggleButtonState();
}

class _SoundToggleButtonState extends State<SoundToggleButton> {
  late bool _isMuted;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.isMuted;
  }

  @override
  void didUpdateWidget(covariant SoundToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isMuted != widget.isMuted) {
      _isMuted = widget.isMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CuteIconButton(
      icon: _isMuted ? Icons.volume_off : Icons.volume_up,
      color: _isMuted ? TokiTheme.grayLight : TokiTheme.mintGreenLight,
      iconColor: _isMuted ? TokiTheme.gray : TokiTheme.mintGreenDark,
      onPressed: () {
        setState(() {
          _isMuted = !_isMuted;
        });
        widget.onChanged?.call(_isMuted);
      },
    );
  }
}
