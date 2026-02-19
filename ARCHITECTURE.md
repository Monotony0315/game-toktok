# Game-TokTok Architecture Documentation

## Project Overview
A cute Toki bunny themed game collection featuring 6 mini-games built with Flutter and Flame.

## Core Architecture

### 1. Core Module (`lib/core/`)

#### `game_engine.dart` - Base Game Engine
- **TokiBaseGame**: Abstract base class for all Flame games
  - Provides pause/resume functionality
  - Score tracking with automatic high score saving
  - Game timing and time limits
  - Integration with AudioManager and Storage
  - Lifecycle management (onGameStart, onUpdate, onGameOver)
  
- **Mixins for game types**:
  - `GridGameMixin`: Grid-based positioning (Snake, Sudoku)
  - `LevelGameMixin`: Level progression system
  - `ComboGameMixin`: Combo/multiplier scoring system

#### `audio_manager.dart` - Sound Management
- Uses **FlameAudio** for BGM and sound effects
- Separate volume controls for BGM, SFX, and Toki voice
- Automatic integration with Storage settings
- Preloaded essential sounds for performance
- Methods: `playBgm()`, `playSfx()`, `playVoice()`, `toggleMute()`

#### `storage.dart` - Data Persistence
- Uses **SharedPreferences** for local storage
- High scores per game with caching
- Game settings (sound, music, volume levels, difficulty)
- Player stats and game history
- Achievement tracking
- Game state for resume functionality
- Ad tracking (games since last ad)

#### `navigation.dart` - Screen Routing
- Centralized route definitions in `Routes` class
- Custom page transitions:
  - `bouncy`: Elastic slide with fade
  - `scale`: Bounce scale animation
  - `fadeScale`: Fade with scale
  - `slideUp`: Slide from bottom
- `TokiNavigator`: Helper class with sound effects
- `TokiNavigationObserver`: Auto BGM switching on route change

#### `theme.dart` - UI Styling
- **TokiTheme**: Color constants (pastel palette)
  - Primary: Coral pink (#FF7B7B)
  - Secondary: Mint green (#7BFFCE)
  - Background: Vanilla cream (#FFF5E1)
- **TokiTextStyles**: Font styles (Nunito family)
- **TokiDecorations**: Common widget decorations
- **GameColors**: Per-game color palettes

### 2. Games Module (`lib/games/`)

Each game has its own folder with standardized structure:

```
games/[game_name]/
├── [game_name]_game.dart    # Main Flame game class
├── [game_name]_screen.dart  # Flutter screen wrapper
├── components/              # Flame components
│   └── (game-specific components)
└── models/                  # Data models
    └── (game-specific models)
```

**Games List:**
1. `snake/` - Classic snake game
2. `fruit_merge/` - Suika-style fruit merging
3. `balloon_merge/` - Balloon merging game
4. `water_sort/` - Color sorting puzzle
5. `sudoku/` - Number puzzle
6. `color_connect/` - Flow-style connection game

### 3. Screen Module (`lib/screens/`)

- `game_menu_screen.dart`: Main menu with all games grid
- `home_screen.dart`: App home/landing
- Additional screens for level selection

### 4. Widgets Module (`lib/widgets/`)

Reusable UI components:
- `score_board.dart`: Score display
- `cute_button.dart`: Styled buttons
- `toki_character.dart`: Toki mascot animations
- `cute_dialog.dart`: Styled dialogs
- `animated_background.dart`: Background effects

### 5. Models Module (`lib/models/`)

Shared data models:
- `game_data.dart`: Game metadata
- `game_progress.dart`: Player progress

### 6. Utils Module (`lib/utils/`)

Utility functions:
- `colors.dart`: Color utilities

## Usage Examples

### Creating a New Game

```dart
import 'package:flame/game.dart';
import '../core/game_engine.dart';
import '../core/audio_manager.dart';

class MyGame extends TokiBaseGame with GridGameMixin {
  MyGame() : super(gameId: 'my_game');

  @override
  Future<void> onGameStart() async {
    // Initialize game
    initializeGrid(10, 20);
    await audio.playBgm('my_game_theme');
  }

  @override
  void onUpdate(double dt) {
    // Game logic
    if (playerWon) {
      addScore(100);
      endGame();
    }
  }
}
```

### Using Storage

```dart
final storage = GameStorage();
await storage.initialize();

// Save high score
await storage.saveHighScore('snake', 1500);

// Get settings
bool soundOn = storage.soundEnabled;
double volume = storage.bgmVolume;

// Save game state
await storage.saveGameState('my_game', {
  'level': currentLevel,
  'score': score,
});
```

### Navigation with Sound

```dart
final navigator = TokiNavigator(context);
await navigator.goToGame(
  Routes.snake,
  bgmTrack: 'snake_theme',
);
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.18.0              # Game engine
  flame_audio: ^2.10.0        # Audio system
  shared_preferences: ^2.2.3  # Local storage
  google_mobile_ads: ^5.1.0   # Ads (newly added)
```

## Asset Structure

```
assets/
├── images/
│   ├── toki/
│   ├── games/
│   └── ui/
├── audio/
│   ├── sounds/
│   │   ├── bgm/          # Background music
│   │   ├── pop.mp3       # UI sounds
│   │   ├── click.mp3
│   │   └── toki_*.mp3    # Voice lines
│   └── music/
└── fonts/
    └── Nunito-*.ttf
```

## Development Guidelines

### For Game Developers:
1. Extend `TokiBaseGame` for all Flame games
2. Use the appropriate mixins for your game type
3. Call `addScore()` for points - high scores auto-save
4. Use `audio.playSfx()` for sound effects
5. Override `onGameStart()` and `onUpdate()`

### For UI Developers:
1. Use `TokiTheme` for colors
2. Use `TokiTextStyles` for typography
3. Use `TokiDecorations` for common widgets
4. Use `TokiNavigator` for navigation with sound

### For Feature Developers:
1. Add new achievements to `Achievements` class in storage.dart
2. Use `GameStorage` for all persistence needs
3. Follow the existing folder structure

## Git Workflow

- `main` branch: Stable, production-ready code
- Feature branches: `feature/game-name-feature`
- All changes merge via PR to main

## Team Structure

This architecture supports parallel development:
- Game developers work in `lib/games/[game]/`
- UI developers work in `lib/widgets/` and `lib/screens/`
- Core improvements in `lib/core/`

All use the same shared core systems for consistency.
