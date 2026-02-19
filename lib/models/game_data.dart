/// Game data models for Game-TokTok

/// Represents a mini-game
class GameInfo {
  final String id;
  final String name;
  final String nameKr;
  final String description;
  final String iconPath;
  final String route;
  final String bgmTrack;
  final List<String> colors;
  final bool isNew;
  final bool isLocked;
  final int unlockLevel;

  const GameInfo({
    required this.id,
    required this.name,
    required this.nameKr,
    required this.description,
    required this.iconPath,
    required this.route,
    required this.bgmTrack,
    required this.colors,
    this.isNew = false,
    this.isLocked = false,
    this.unlockLevel = 0,
  });
}

/// Player score/achievement data
class GameScore {
  final String gameId;
  int highScore;
  int gamesPlayed;
  int totalScore;
  DateTime? lastPlayed;
  List<int> recentScores;
  Map<String, dynamic> achievements;

  GameScore({
    required this.gameId,
    this.highScore = 0,
    this.gamesPlayed = 0,
    this.totalScore = 0,
    this.lastPlayed,
    List<int>? recentScores,
    Map<String, dynamic>? achievements,
  }) : recentScores = recentScores ?? [],
       achievements = achievements ?? {};

  double get averageScore => gamesPlayed > 0 ? totalScore / gamesPlayed : 0;

  void addScore(int score) {
    recentScores.insert(0, score);
    if (recentScores.length > 10) {
      recentScores.removeLast();
    }
    
    totalScore += score;
    gamesPlayed++;
    lastPlayed = DateTime.now();
    
    if (score > highScore) {
      highScore = score;
    }
  }

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'highScore': highScore,
    'gamesPlayed': gamesPlayed,
    'totalScore': totalScore,
    'lastPlayed': lastPlayed?.toIso8601String(),
    'recentScores': recentScores,
    'achievements': achievements,
  };

  factory GameScore.fromJson(Map<String, dynamic> json) => GameScore(
    gameId: json['gameId'],
    highScore: json['highScore'] ?? 0,
    gamesPlayed: json['gamesPlayed'] ?? 0,
    totalScore: json['totalScore'] ?? 0,
    lastPlayed: json['lastPlayed'] != null 
        ? DateTime.parse(json['lastPlayed']) 
        : null,
    recentScores: List<int>.from(json['recentScores'] ?? []),
    achievements: Map<String, dynamic>.from(json['achievements'] ?? {}),
  );
}

/// Player profile data
class PlayerProfile {
  String name;
  int totalGamesPlayed;
  int totalScore;
  int level;
  int experience;
  DateTime createdAt;
  List<String> unlockedGames;
  Map<String, GameScore> gameScores;
  Map<String, dynamic> settings;

  PlayerProfile({
    this.name = 'Player',
    this.totalGamesPlayed = 0,
    this.totalScore = 0,
    this.level = 1,
    this.experience = 0,
    DateTime? createdAt,
    List<String>? unlockedGames,
    Map<String, GameScore>? gameScores,
    Map<String, dynamic>? settings,
  }) : createdAt = createdAt ?? DateTime.now(),
       unlockedGames = unlockedGames ?? ['snake'],
       gameScores = gameScores ?? {},
       settings = settings ?? {
         'soundEnabled': true,
         'musicEnabled': true,
         'vibrationEnabled': true,
       };

  int get experienceToNextLevel => level * 100;
  double get levelProgress => experience / experienceToNextLevel;

  void addExperience(int exp) {
    experience += exp;
    while (experience >= experienceToNextLevel) {
      experience -= experienceToNextLevel;
      level++;
    }
  }

  void updateGameScore(String gameId, int score) {
    gameScores.putIfAbsent(gameId, () => GameScore(gameId: gameId));
    gameScores[gameId]!.addScore(score);
    
    totalGamesPlayed++;
    totalScore += score;
    addExperience(score ~/ 10);
  }

  GameScore? getGameScore(String gameId) => gameScores[gameId];

  Map<String, dynamic> toJson() => {
    'name': name,
    'totalGamesPlayed': totalGamesPlayed,
    'totalScore': totalScore,
    'level': level,
    'experience': experience,
    'createdAt': createdAt.toIso8601String(),
    'unlockedGames': unlockedGames,
    'gameScores': gameScores.map((k, v) => MapEntry(k, v.toJson())),
    'settings': settings,
  };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
    name: json['name'] ?? 'Player',
    totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
    totalScore: json['totalScore'] ?? 0,
    level: json['level'] ?? 1,
    experience: json['experience'] ?? 0,
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now(),
    unlockedGames: List<String>.from(json['unlockedGames'] ?? ['snake']),
    gameScores: (json['gameScores'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, GameScore.fromJson(v)),
        ) ?? {},
    settings: Map<String, dynamic>.from(json['settings'] ?? {}),
  );
}

/// Game configuration constants
class GameConfig {
  GameConfig._();

  static const List<GameInfo> allGames = [
    GameInfo(
      id: 'snake',
      name: 'Snake',
      nameKr: '스네이크',
      description: 'Classic snake game with Toki!',
      iconPath: 'assets/images/games/snake_icon.png',
      route: '/games/snake',
      bgmTrack: 'snake',
      colors: ['#90EE90', '#32CD32'],
      isNew: false,
      isLocked: false,
    ),
    GameInfo(
      id: 'fruit_merge',
      name: 'Fruit Merge',
      nameKr: '과일머지',
      description: 'Merge fruits to create watermelons!',
      iconPath: 'assets/images/games/fruit_merge_icon.png',
      route: '/games/fruit-merge',
      bgmTrack: 'fruit_merge',
      colors: ['#FF6B6B', '#FF8E8E', '#9B59B6'],
      isNew: true,
      isLocked: false,
    ),
    GameInfo(
      id: 'balloon_merge',
      name: 'Balloon Merge',
      nameKr: '풍선머지',
      description: 'Float and merge colorful balloons!',
      iconPath: 'assets/images/games/balloon_merge_icon.png',
      route: '/games/balloon-merge',
      bgmTrack: 'balloon_merge',
      colors: ['#FF6B6B', '#FFE66D', '#4ECDC4'],
      isNew: false,
      isLocked: false,
    ),
    GameInfo(
      id: 'water_sort',
      name: 'Water Sort',
      nameKr: '워터소트',
      description: 'Sort colorful water into tubes!',
      iconPath: 'assets/images/games/water_sort_icon.png',
      route: '/games/water-sort',
      bgmTrack: 'water_sort',
      colors: ['#4ECDC4', '#87CEEB'],
      isNew: false,
      isLocked: false,
    ),
    GameInfo(
      id: 'sudoku',
      name: 'Sudoku',
      nameKr: '스도쿠',
      description: 'Classic number puzzle with cute tiles!',
      iconPath: 'assets/images/games/sudoku_icon.png',
      route: '/games/sudoku',
      bgmTrack: 'sudoku',
      colors: ['#9B59B6', '#87CEEB'],
      isNew: false,
      isLocked: false,
    ),
    GameInfo(
      id: 'color_connect',
      name: 'Color Connect',
      nameKr: '색상연결',
      description: 'Connect matching colors!',
      iconPath: 'assets/images/games/color_connect_icon.png',
      route: '/games/color-connect',
      bgmTrack: 'color_connect',
      colors: ['#FF6B6B', '#FFE66D', '#4ECDC4', '#9B59B6'],
      isNew: true,
      isLocked: false,
    ),
  ];

  static GameInfo? getGameById(String id) {
    try {
      return allGames.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }
}
