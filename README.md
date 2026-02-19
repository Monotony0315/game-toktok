# Game TokTok 🐰

A cute Flutter game collection featuring Toki the bunny! Built with the Flame engine for smooth, delightful gameplay.

## Games

### 🐍 Snake Game
Classic snake game with a cute twist - play as Toki the bunny and collect fruits!

**Features:**
- Swipe controls for easy mobile gameplay
- Adorable bunny head with ears and blushing cheeks
- Colorful pastel design
- Score tracking
- Game over and restart functionality

**How to Play:**
- Swipe up/down/left/right to control Toki
- Collect fruits to grow longer
- Avoid hitting walls or yourself
- Get the highest score!

### 🍉 Fruit Merge Game
Suika-style physics-based merging game - combine fruits to create bigger ones!

**Features:**
- Physics-based gameplay with realistic bouncing
- 10 fruit types to merge: Cherry → Strawberry → Grape → Orange → Apple → Pear → Peach → Pineapple → Melon → Watermelon
- Tap to drop, drag to position
- Merge effects with sparkles
- Score tracking
- Game over when fruits reach the top

**How to Play:**
- Tap to drop fruits
- Drag left/right to position before dropping
- Same fruits merge into the next bigger fruit
- Get watermelon for maximum points!
- Don't let fruits pile up to the top

## Tech Stack

- **Flutter** - UI framework
- **Flame Engine** - Game engine for physics and rendering
- **Dart** - Programming language

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK

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
flutter run
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── screens/
│   └── home_screen.dart         # Main menu and game navigation
├── games/
│   ├── snake/
│   │   └── snake_game.dart      # Snake game implementation
│   └── fruit_merge/
│       └── fruit_merge_game.dart # Fruit merge game implementation
├── components/
│   └── (shared components)
assets/
├── images/                      # Game images and sprites
├── audio/                       # Sound effects and music
└── fonts/                       # Custom fonts
```

## Design

The app features a cute pastel color palette:
- Primary Pink: `#FFB7C5`
- Light Pink: `#FFF0F5`
- Peach: `#FFE4E1`
- Mint Green: `#98FB98`
- Soft Coral: `#FF6B9D`

All games feature Toki the bunny theme with rounded corners, soft shadows, and delightful animations.

## Contributing

This project is developed by Agent A (Game Developer) as part of the Game-TokTok project.

## License

MIT License - feel free to use and modify!

---

Made with 💕 and lots of bunny hops!
