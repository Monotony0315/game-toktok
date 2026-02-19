# Game-TokTok Product Requirements Document

## 1. App Overview

**App Name:** Game-TokTok  
**Concept:** 귀여운 토끼 캐릭터가 안내하는 미니게임 천국  
**Tagline:** "톡톡! 즐거움이 터지는 미니게임"  
**Target:** iOS 먼저 → Android 확장  

## 2. Design Philosophy

### Visual Identity
- **Main Character:** Toki (토끼 캐릭터) - 둥근 눈, 통통한 볼, 발그레한 볼터치
- **Color Palette:** 
  - Primary: 산호분홍 (#FF7B7B)
  - Secondary: 바닐라크림 (#FFF5E1)
  - Accent: 민트그린 (#7BFFCE)
  - Background: 푸른하늘 그라데이션
- **Style:** 둥근 모서리, 통통한 버튼, 반짝이는 파티클 효과

### Sound Design
- 귀여운 "톡톡" 효과음
- 경쾌한 배경음악 (8-bit + modern mix)
- 성공/실패 시 뚜렷한 피드백 사운드

## 3. Games Specification

### Game 1: Snake (스네이크)
- Classic snake with cute fruit items
- Toki head, fruit body segments
- Swipe controls

### Game 2: Fruit Merge (과일머지)
- Suika-style merging game
- Fruits: Cherry → Strawberry → Grape → Orange → Apple → Pear → Peach → Pineapple → Melon → Watermelon
- Physics-based dropping

### Game 3: Balloon Merge (풍선머지)
- Colorful balloon merging
- Float-up physics
- Chain reactions

### Game 4: Water Sort (워터소트)
- Color sorting puzzle
- Glass tube aesthetics
- Minimum moves challenge

### Game 5: Sudoku (스도쿠)
- Classic sudoku with cute number tiles
- Difficulty levels: Easy/Medium/Hard
- Hint system with Toki animation

### Game 6: Color Connect (색상연결)
- Flow Free style
- Grid sizes: 5x5 to 10x10
- Pastel color palette

## 4. Technical Architecture

```
game-toktok/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── audio_manager.dart
│   │   ├── game_state.dart
│   │   ├── storage.dart
│   │   └── navigation.dart
│   ├── games/
│   │   ├── snake/
│   │   ├── fruit_merge/
│   │   ├── balloon_merge/
│   │   ├── water_sort/
│   │   ├── sudoku/
│   │   └── color_connect/
│   ├── ui/
│   │   ├── home_screen.dart
│   │   ├── game_menu.dart
│   │   └── widgets/
│   └── models/
│       └── game_data.dart
├── assets/
│   ├── images/
│   ├── sounds/
│   └── fonts/
└── pubspec.yaml
```

## 5. Team Structure

**Manager Agent (팀장):**
- Overall coordination
- Code review
- Integration
- GitHub management

**Planner Agent:**
- Game mechanics design
- Level design
- Balance tuning

**Dev Codex Agent (Algorithm Specialist):**
- Complex game logic (Merge physics, Sudoku generator)
- Performance optimization

**Dev Sonnet Agent (UI/UX Specialist):**
- Screen layouts
- Animations
- Visual polish

## 6. Development Phases

### Phase 1: Foundation (Week 1)
- [ ] GitHub repo setup
- [ ] Flutter project initialization
- [ ] Core module implementation
- [ ] Home screen UI

### Phase 2: Game Development (Week 2-3)
- [ ] Snake game
- [ ] Fruit Merge game
- [ ] Balloon Merge game
- [ ] Water Sort game
- [ ] Sudoku game
- [ ] Color Connect game

### Phase 3: Integration (Week 4)
- [ ] All games connected to main menu
- [ ] Audio integration
- [ ] Save/load system
- [ ] Ad integration (AdMob)

### Phase 4: Polish & iOS Release (Week 5)
- [ ] UI/UX polish
- [ ] iOS testing
- [ ] TestFlight deployment

### Phase 5: Android Port (Week 6)
- [ ] Android build
- [ ] Google Play deployment

## 7. Monetization

- Free to play
- AdMob banner (bottom of game screen)
- Interstitial ads (every 3 games)
- Optional: Remove ads IAP ($2.99)

## 8. Success Metrics

- 6 games fully playable
- Cute, cohesive visual design
- Smooth 60fps gameplay
- <100MB app size
- 4.5+ star rating goal
