# Game-TokTok Team Setup

## Team Leader (Manager Agent)
**Role:** Project coordination, code review, integration
**Responsibilities:**
- GitHub repo management
- Code review & merge
- Architecture decisions
- Final integration

## Sub Team Members

### Agent A: Game Developer (Snake + Fruit Merge)
**Tasks:**
- Snake game implementation
- Fruit Merge (Suika-style) game
- Game logic & physics

### Agent B: Game Developer (Balloon Merge + Water Sort)
**Tasks:**
- Balloon Merge game with float physics
- Water Sort color puzzle game
- UI interactions

### Agent C: Game Developer (Sudoku + Color Connect)
**Tasks:**
- Sudoku with generator & solver
- Color Connect (Flow Free style)
- Puzzle logic

### Agent D: UI/UX & Audio Specialist
**Tasks:**
- Home screen & navigation
- Cute UI components
- Sound effects & music
- Character animations

## Git Workflow
```
main (protected)
├── feature/snake (Agent A)
├── feature/fruit-merge (Agent A)
├── feature/balloon-merge (Agent B)
├── feature/water-sort (Agent B)
├── feature/sudoku (Agent C)
├── feature/color-connect (Agent C)
└── feature/ui-audio (Agent D)
```

## Development Schedule
- Week 1: Foundation + Core games
- Week 2: Remaining games + integration
- Week 3: Polish + iOS release
- Week 4: Android port
