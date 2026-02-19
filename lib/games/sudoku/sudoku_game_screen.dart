import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../models/game_progress.dart';
import 'sudoku_generator.dart';

class SudokuGameScreen extends StatefulWidget {
  final String difficulty;
  final int level;

  const SudokuGameScreen({
    super.key,
    required this.difficulty,
    required this.level,
  });

  @override
  State<SudokuGameScreen> createState() => _SudokuGameScreenState();
}

class _SudokuGameScreenState extends State<SudokuGameScreen>
    with TickerProviderStateMixin {
  late SudokuGenerator _generator;
  late List<List<int>> _grid;
  late List<List<bool>> _isFixed;
  late List<List<bool>> _isError;
  
  int _selectedRow = -1;
  int _selectedCol = -1;
  int _elapsedSeconds = 0;
  int _hintsUsed = 0;
  int _mistakes = 0;
  bool _isCompleted = false;
  
  Timer? _timer;
  late AnimationController _tokiController;
  late AnimationController _hintController;

  static const int maxHints = 3;
  static const int maxMistakes = 3;

  @override
  void initState() {
    super.initState();
    _generator = SudokuGenerator();
    _generator.generate(widget.difficulty);
    _initializeGrid();
    _startTimer();
    
    _tokiController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _hintController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _initializeGrid() {
    _grid = List.generate(
      9,
      (i) => List.generate(9, (j) => _generator.puzzle[i][j]),
    );
    _isFixed = List.generate(
      9,
      (i) => List.generate(9, (j) => _generator.puzzle[i][j] != 0),
    );
    _isError = List.generate(
      9,
      (i) => List.generate(9, (j) => false),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isCompleted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _selectCell(int row, int col) {
    if (_isFixed[row][col] || _isCompleted) return;
    
    HapticFeedback.lightImpact();
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _enterNumber(int number) {
    if (_selectedRow == -1 || _selectedCol == -1 || _isCompleted) return;
    if (_isFixed[_selectedRow][_selectedCol]) return;

    HapticFeedback.mediumImpact();
    
    setState(() {
      if (_generator.solution[_selectedRow][_selectedCol] == number) {
        _grid[_selectedRow][_selectedCol] = number;
        _isError[_selectedRow][_selectedCol] = false;
        _checkCompletion();
      } else {
        _isError[_selectedRow][_selectedCol] = true;
        _mistakes++;
        if (_mistakes >= maxMistakes) {
          _showGameOver();
        }
      }
    });
  }

  void _useHint() {
    if (_hintsUsed >= maxHints || _isCompleted) return;
    
    // Find an empty cell
    int? targetRow, targetCol;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (_grid[i][j] == 0) {
          targetRow = i;
          targetCol = j;
          break;
        }
      }
      if (targetRow != null) break;
    }
    
    if (targetRow == null) return;

    HapticFeedback.heavyImpact();
    _hintController.forward(from: 0).then((_) => _hintController.reverse());
    
    setState(() {
      _hintsUsed++;
      _selectedRow = targetRow!;
      _selectedCol = targetCol!;
      _grid[targetRow][targetCol] = _generator.solution[targetRow][targetCol];
      _checkCompletion();
    });
  }

  void _checkCompletion() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (_grid[i][j] != _generator.solution[i][j]) return;
      }
    }
    
    setState(() => _isCompleted = true);
    _timer?.cancel();
    _tokiController.repeat(reverse: true);
    
    // Save progress
    final progress = context.read<GameProgress>();
    final gameKey = 'sudoku_${widget.difficulty}_${widget.level}';
    progress.setBestTime(gameKey, _elapsedSeconds);
    
    // Calculate stars
    int stars = 3;
    if (_mistakes > 0) stars--;
    if (_hintsUsed > 1) stars--;
    progress.setStars(gameKey, stars);
    
    // Unlock next level
    progress.unlockSudokuLevel(widget.level + 1);
    
    _showVictoryDialog();
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎉 Level Complete!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: AppColors.warning, size: 50),
            const SizedBox(height: 16),
            Text(
              'Time: ${_formatTime(_elapsedSeconds)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Mistakes: $_mistakes',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Hints Used: $_hintsUsed',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showGameOver() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '💔 Game Over',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: const Text(
          'Too many mistakes! Try again?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _initializeGrid();
                _mistakes = 0;
                _hintsUsed = 0;
                _elapsedSeconds = 0;
                _isCompleted = false;
                _startTimer();
              });
            },
            child: const Text('Restart', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tokiController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Sudoku - ${widget.difficulty.toUpperCase()}',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Level ${widget.level}',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Stats bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(Icons.timer, _formatTime(_elapsedSeconds)),
                _buildStatCard(Icons.lightbulb, '${maxHints - _hintsUsed}'),
                _buildStatCard(Icons.error_outline, '$_mistakes/$maxMistakes'),
              ],
            ),
          ),
          
          // Toki mascot
          AnimatedBuilder(
            animation: _tokiController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _isCompleted ? -5 * _tokiController.value : 0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryPink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🐱 Toki is watching!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.accentPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Sudoku grid
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 9,
                      ),
                      itemCount: 81,
                      itemBuilder: (context, index) {
                        final row = index ~/ 9;
                        final col = index % 9;
                        return _buildCell(row, col);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Number pad
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: List.generate(9, (index) {
                return _buildNumberButton(index + 1);
              }),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Hint button
          Padding(
            padding: const EdgeInsets.all(20),
            child: AnimatedBuilder(
              animation: _hintController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + 0.1 * _hintController.value,
                  child: ElevatedButton.icon(
                    onPressed: _hintsUsed < maxHints ? _useHint : null,
                    icon: const Icon(Icons.lightbulb_outline),
                    label: Text('Hint (${maxHints - _hintsUsed})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: AppColors.textDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.accentPink),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    final isSelected = _selectedRow == row && _selectedCol == col;
    final isSameRow = _selectedRow == row;
    final isSameCol = _selectedCol == col;
    final isSameBox = _selectedRow != -1 && 
                      _selectedCol != -1 &&
                      (row ~/ 3 == _selectedRow ~/ 3) && 
                      (col ~/ 3 == _selectedCol ~/ 3);
    final value = _grid[row][col];
    final isFixed = _isFixed[row][col];
    final isError = _isError[row][col];

    Color bgColor = Colors.white;
    if (isSelected) {
      bgColor = AppColors.primaryPink.withOpacity(0.5);
    } else if (isSameRow || isSameCol || isSameBox) {
      bgColor = AppColors.secondaryPink.withOpacity(0.3);
    }

    // 3x3 box borders
    final borderSide = BorderSide(
      color: AppColors.textLight.withOpacity(0.3),
      width: 0.5,
    );
    final thickBorderSide = BorderSide(
      color: AppColors.textDark,
      width: 2,
    );

    return GestureDetector(
      onTap: () => _selectCell(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: row % 3 == 0 ? thickBorderSide : borderSide,
            left: col % 3 == 0 ? thickBorderSide : borderSide,
            right: col == 8 ? thickBorderSide : BorderSide.none,
            bottom: row == 8 ? thickBorderSide : BorderSide.none,
          ),
        ),
        child: Center(
          child: value != 0
              ? Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: isFixed ? FontWeight.bold : FontWeight.normal,
                    color: isError
                        ? AppColors.error
                        : isFixed
                            ? AppColors.textDark
                            : AppColors.accentPink,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    return GestureDetector(
      onTap: () => _enterNumber(number),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: _getNumberColor(number),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ).animate()
     .scale(duration: 100.ms)
     .then()
     .scale(duration: 100.ms, begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Color _getNumberColor(int number) {
    final colors = [
      AppColors.tile1,
      AppColors.tile2,
      AppColors.tile3,
      AppColors.tile4,
      AppColors.tile5,
      AppColors.tile6,
      AppColors.tile7,
      AppColors.tile8,
      AppColors.tile9,
    ];
    return colors[number - 1];
  }
}
