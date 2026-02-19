# UI/UX & Audio Components - Agent D

This directory contains all UI/UX and Audio components created by Agent D for the Game-TokTok project.

## 📁 File Structure

```
lib/
├── core/
│   ├── audio_manager.dart    # Audio system (BGM, SFX, Voice)
│   ├── navigation.dart       # Navigation with transitions
│   └── theme.dart            # Toki color palette & styles
├── models/
│   └── game_data.dart        # Game info & player data models
├── screens/
│   ├── home_screen.dart      # Main menu with Toki
│   └── game_menu.dart        # Game selection grid
├── widgets/
│   ├── animated_background.dart  # Sky background with clouds/particles
│   ├── cute_button.dart          # Custom buttons with bounce
│   ├── cute_dialog.dart          # Dialogs (pause, game over, etc.)
│   ├── score_board.dart          # Score displays & badges
│   └── toki_character.dart       # Animated Toki bunny
```

## 🎨 Toki Theme

### Color Palette
- **Primary:** Coral Pink `#FF7B7B`
- **Secondary:** Vanilla Cream `#FFF5E1`
- **Accent:** Mint Green `#7BFFCE`
- **Background:** Sky Blue Gradient

### Game Colors
- Snake: Green `#90EE90`
- Fruit Merge: Red `#FF6B6B`
- Balloon Merge: Yellow `#FFE66D`
- Water Sort: Teal `#4ECDC4`
- Sudoku: Purple `#9B59B6`
- Color Connect: Orange `#FFA07A`

## 🔊 Audio Manager

### Features
- Background music with fade in/out
- Sound effects (pop, click, success, fail, etc.)
- Toki voice lines
- Mute/volume controls

### Usage
```dart
final audio = AudioManager();

// Play BGM
await audio.playBgm('main_menu');

// Play sound effect
await audio.playSfx('click');

// Play Toki voice
await audio.playVoice('toki_happy');

// Toggle mute
await audio.toggleMute();
```

## 🎭 Toki Character

### Animation States
- `idle` - Breathing animation with blinking
- `happy` - Sparkles and big smile
- `sad` - Sweat drop and frown
- `bounce` - Bouncing up and down
- `wave` - Gentle wave animation
- `surprised` - Wide eyes

### Usage
```dart
TokiCharacter(
  state: TokiAnimationState.happy,
  size: 120,
  onTap: () => audio.playRandomGreeting(),
)
```

## 🧭 Navigation

### Transition Types
- `bouncy` - Elastic slide from right
- `scale` - Scale bounce in
- `fadeScale` - Fade with scale
- `slideUp` - Slide from bottom

### Usage
```dart
Navigator.of(context).push(
  TokiPageTransitions.bouncy(
    builder: (_) => const GameScreen(),
  ),
);
```

## 🎯 Widgets

### CuteButton
Bouncy button with sound effects:
```dart
CuteButton(
  text: 'Play',
  onPressed: () { },
  icon: Icon(Icons.play_arrow),
)
```

### GameCardButton
Game selection card:
```dart
GameCardButton(
  title: 'Snake',
  subtitle: 'Classic snake game',
  icon: Icons.gradient,
  accentColor: TokiTheme.snakeGreen,
  isNew: true,
  onPressed: () { },
)
```

### CuteDialog
Themed dialog with Toki:
```dart
CuteDialog.show(
  context: context,
  title: 'Game Over',
  tokiState: TokiAnimationState.happy,
  primaryButtonText: 'Play Again',
);
```

### ScoreBoard
Score display with animation:
```dart
ScoreBoard(
  score: 1500,
  highScore: 2000,
  level: 5,
)
```

### AnimatedBackground
Sky background with effects:
```dart
AnimatedBackground(
  showClouds: true,
  showParticles: true,
  child: MyScreen(),
)
```

## 📝 Notes for Other Agents

1. **Audio Files**: Add sound files to `assets/sounds/`:
   - `bgm/main_menu.mp3`
   - `bgm/menu.mp3`
   - `sounds/click.mp3`, `pop.mp3`, `success.mp3`, `fail.mp3`
   - `sounds/toki_greeting.mp3`, `toki_happy.mp3`, etc.

2. **Game Integration**: Replace placeholder screens in `main.dart` with actual game screens

3. **Theme Consistency**: Use `TokiTheme` colors and `TokiTextStyles` for consistency

4. **Responsive Design**: All widgets use relative sizing and work on different screen sizes

## ✅ Completed Features

- [x] Home Screen with animated Toki
- [x] Game selection grid
- [x] Audio Manager (BGM, SFX, Voice)
- [x] Navigation system with cute transitions
- [x] Toki character with animations
- [x] Cute buttons with bounce effects
- [x] Dialog system (pause, game over, level complete)
- [x] Score boards and badges
- [x] Animated background with clouds
- [x] Theme system with Toki colors
- [x] Responsive design

## 🔧 Branch

Working on: `feature/ui-audio`
