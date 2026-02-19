import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameProgress extends ChangeNotifier {
  int _unlockedSudokuLevel = 1;
  int _unlockedColorConnectLevel = 1;
  Map<String, int> _bestTimes = {};
  Map<String, int> _stars = {};

  int get unlockedSudokuLevel => _unlockedSudokuLevel;
  int get unlockedColorConnectLevel => _unlockedColorConnectLevel;

  GameProgress() {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _unlockedSudokuLevel = prefs.getInt('unlocked_sudoku') ?? 1;
    _unlockedColorConnectLevel = prefs.getInt('unlocked_color') ?? 1;
    
    // Load best times
    final timeKeys = prefs.getStringList('time_keys') ?? [];
    for (final key in timeKeys) {
      final time = prefs.getInt('time_$key');
      if (time != null) _bestTimes[key] = time;
    }
    
    // Load stars
    final starKeys = prefs.getStringList('star_keys') ?? [];
    for (final key in starKeys) {
      final star = prefs.getInt('star_$key');
      if (star != null) _stars[key] = star;
    }
    
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unlocked_sudoku', _unlockedSudokuLevel);
    await prefs.setInt('unlocked_color', _unlockedColorConnectLevel);
    
    // Save best times
    await prefs.setStringList('time_keys', _bestTimes.keys.toList());
    for (final entry in _bestTimes.entries) {
      await prefs.setInt('time_${entry.key}', entry.value);
    }
    
    // Save stars
    await prefs.setStringList('star_keys', _stars.keys.toList());
    for (final entry in _stars.entries) {
      await prefs.setInt('star_${entry.key}', entry.value);
    }
  }

  void unlockSudokuLevel(int level) {
    if (level > _unlockedSudokuLevel) {
      _unlockedSudokuLevel = level;
      _saveProgress();
      notifyListeners();
    }
  }

  void unlockColorConnectLevel(int level) {
    if (level > _unlockedColorConnectLevel) {
      _unlockedColorConnectLevel = level;
      _saveProgress();
      notifyListeners();
    }
  }

  int? getBestTime(String gameKey) => _bestTimes[gameKey];
  
  void setBestTime(String gameKey, int seconds) {
    final current = _bestTimes[gameKey];
    if (current == null || seconds < current) {
      _bestTimes[gameKey] = seconds;
      _saveProgress();
      notifyListeners();
    }
  }

  int getStars(String gameKey) => _stars[gameKey] ?? 0;
  
  void setStars(String gameKey, int stars) {
    final current = _stars[gameKey] ?? 0;
    if (stars > current) {
      _stars[gameKey] = stars;
      _saveProgress();
      notifyListeners();
    }
  }

  bool isLevelUnlocked(String gameType, int level) {
    if (gameType == 'sudoku') {
      return level <= _unlockedSudokuLevel;
    } else {
      return level <= _unlockedColorConnectLevel;
    }
  }
}
