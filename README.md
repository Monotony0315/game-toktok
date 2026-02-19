# 🐰 Game-TokTok

A cute collection of 6 puzzle games featuring Toki the bunny! Built with Flutter and Flame.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Flame](https://img.shields.io/badge/Flame-1.18+-orange.svg)

## 📱 Screenshots

### Main Menu
The main menu features Toki the bunny mascot and a beautiful pastel-themed game selection grid with high scores displayed for each game.

### Game Screens
Each game has a unique, cute pastel color scheme with smooth animations and sound effects:

- **Snake** - Classic snake game with smooth controls
- **Fruit Merge** - Merge fruits to create bigger ones (Suika-style)
- **Balloon Merge** - Pop and merge colorful balloons
- **Water Sort** - Sort colored water in test tubes
- **Sudoku** - Classic number puzzle with multiple levels
- **Color Connect** - Connect matching colors with pipes

## 🎮 Games Included

### 1. Snake 🐍
The classic snake game with a cute pastel twist!
- Control the snake with swipe gestures
- Eat fruits to grow longer
- Avoid hitting walls or yourself
- Compete for the highest score!

### 2. Fruit Merge 🍉
A relaxing merge game inspired by Suika Game.
- Drop fruits into the container
- Merge identical fruits to create bigger ones
- Chain reactions for bonus points
- Can you create the legendary watermelon?

### 3. Balloon Merge 🎈
Pop and merge colorful balloons in this addictive physics game!
- Drop balloons into the play area
- Merge matching colors to level up
- Strategic placement is key
- Cute balloon physics!

### 4. Water Sort 🧪
A relaxing puzzle game to sort colored water.
- Pour water between test tubes
- Sort all colors to win
- Multiple difficulty levels
- Perfect for short play sessions

### 5. Sudoku 🔢
The classic number puzzle game.
- Multiple difficulty levels (Easy, Medium, Hard)
- Beautiful pastel number tiles
- Hint system available
- Track your best times

### 6. Color Connect 🌈
Connect matching colors with pipes!
- Connect dots of the same color
- Fill the entire board
- Pipes can't cross each other
- Over 100+ levels

## 🎯 Features

- 🐰 **Cute Toki Theme** - Adorable bunny mascot with animations
- 🎨 **Pastel Color Palette** - Easy on the eyes, beautiful gradients
- 🎵 **Audio System** - Background music and sound effects
- 💾 **Progress Saving** - High scores persist between sessions
- 🎮 **6 Mini-Games** - Something for everyone
- 📱 **Mobile Optimized** - Works great on iOS and Android

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Xcode (for iOS builds)
- Android Studio (for Android builds)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Monotony0315/game-toktok.git
cd game-toktok
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For iOS Simulator
flutter run

# For specific device
flutter devices
flutter run -d <device_id>
```

## 📦 Building for Production

### iOS Release Build

```bash
# Build iOS release
flutter build ios --release

# Or build IPA for distribution
flutter build ipa --release
```

The built app will be located at:
- `build/ios/iphoneos/Game-TokTok.app` (for device testing)
- `build/ios/ipa/` (IPA file for App Store)

### Android Release Build

```bash
# Build APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── audio_manager.dart    # Audio and music management
│   ├── game_engine.dart      # Shared game engine
│   ├── navigation.dart       # App routing and transitions
│   ├── storage.dart          # Local data persistence
│   └── theme.dart            # App colors and styles
├── games/
│   ├── balloon_merge/        # Balloon Merge game
│   ├── color_connect/        # Color Connect game
│   ├── fruit_merge/          # Fruit Merge game
│   ├── snake/                # Snake game
│   ├── sudoku/               # Sudoku game
│   └── water_sort/           # Water Sort game
├── models/
│   ├── game_data.dart        # Game data models
│   └── game_progress.dart    # Progress tracking
├── screens/
│   ├── balloon_merge_game_screen.dart
│   ├── color_connect_level_screen.dart
│   ├── fruit_merge_game_screen.dart
│   ├── game_menu_screen.dart
│   ├── snake_game_screen.dart
│   ├── sudoku_level_screen.dart
│   └── ...
├── ui/                       # UI components
├── utils/                    # Utility functions
└── widgets/                  # Reusable widgets
    ├── animated_background.dart
    ├── cute_button.dart
    ├── cute_dialog.dart
    ├── score_board.dart
    └── toki_character.dart
```

## 🎨 Color Palette

| Color | Hex Code | Usage |
|-------|----------|-------|
| Coral Pink | `#FF7B7B` | Primary accent |
| Mint Green | `#7BFFCE` | Secondary accent |
| Vanilla Cream | `#FFFFF5E1` | Background |
| Sky Blue | `#87CEEB` | Highlights |
| Snake Green | `#90EE90` | Snake game |
| Fruit Red | `#FF6B6B` | Fruit Merge |
| Balloon Yellow | `#FFE66D` | Balloon Merge |
| Water Blue | `#4ECDC4` | Water Sort |
| Sudoku Purple | `#9B59B6` | Sudoku |
| Connect Orange | `#FFA07A` | Color Connect |

## 🔧 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.18.0          # Game engine
  flame_audio: ^2.10.0    # Audio support
  shared_preferences: ^2.2.3  # Local storage
  google_mobile_ads: ^5.1.0   # Ads support
  flutter_animate: ^4.5.0     # Animations
  cupertino_icons: ^1.0.6
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Game engine powered by [Flame](https://flame-engine.org/)
- Inspired by cute pastel aesthetics
- Toki the bunny mascot 🐰

## 📞 Contact

- GitHub: [@Monotony0315](https://github.com/Monotony0315)
- Project Link: [https://github.com/Monotony0315/game-toktok](https://github.com/Monotony0315/game-toktok)

---

Made with 💖 and 🐰
