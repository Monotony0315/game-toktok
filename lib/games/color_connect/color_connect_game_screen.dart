import 'dart:async';
import 'dart:math' show Point;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../models/game_progress.dart';
import 'color_connect_generator.dart';

class ColorConnectGameScreen extends StatefulWidget {
  final int gridSize;
  final int level;

  const ColorConnectGameScreen({
    super.key,
    required this.gridSize,
    required this.level,
  });

  @override
  State<ColorConnectGameScreen> createState() => _ColorConnectGameScreenState();
}

class _ColorConnectGameScreenState extends State<ColorConnectGameScreen>
    with TickerProviderStateMixin {
  late ColorConnectGenerator _generator;
  late ColorConnectLevel _level;
  late List<List<Cell>> _playerGrid;
  
  List<Point<int>> _currentPath = [];
  int? _currentColorIndex;
  bool _isDrawing = false;
  
  int _elapsedSeconds = 0;
  bool _isCompleted = false;
  int _moves = 0;
  
  Timer? _timer;
  
  // Animation controllers for flow effects
  Map<int, AnimationController> _flowControllers = {};
  
  @override
  void initState() {
    super.initState();
    _generator = ColorConnectGenerator();
    _level = _generator.generate(widget.gridSize);
    _initializePlayerGrid();
    _startTimer();
  }
  
  void _initializePlayerGrid() {
    // Deep copy the level grid
    _playerGrid = List.generate(
      widget.gridSize,
      (r) => List.generate(
        widget.gridSize,
        (c) => _level.grid[r][c].copy(),
      ),
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
  
  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {
    if (_isCompleted) return;
    
    final cell = _getCellFromPosition(details.localPosition, constraints);
    if (cell == null) return;
    
    final (row, col) = cell;
    final startCell = _playerGrid[row][col];
    
    // Can only start from an endpoint
    if (startCell.type != CellType.endpoint) return;
    
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isDrawing = true;
      _currentColorIndex = startCell.colorIndex;
      _currentPath = [Point(col, row)];
      
      // Clear existing paths of this color
      _clearColorPath(startCell.colorIndex!);
    });
  }
  
  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (!_isDrawing || _isCompleted) return;
    
    final cell = _getCellFromPosition(details.localPosition, constraints);
    if (cell == null) return;
    
    final (row, col) = cell;
    final point = Point(col, row);
    
    // Check if we're going back
    if (_currentPath.length > 1 && point == _currentPath[_currentPath.length - 2]) {
      // Remove last point
      setState(() {
        _currentPath.removeLast();
      });
      return;
    }
    
    // Check if already in path
    if (_currentPath.contains(point)) return;
    
    // Check if valid move
    final lastPoint = _currentPath.last;
    if (!_isAdjacent(lastPoint, point)) return;
    
    final targetCell = _playerGrid[row][col];
    
    // Check if we can enter this cell
    if (targetCell.type == CellType.empty ||
        (targetCell.type == CellType.endpoint &&
         targetCell.colorIndex == _currentColorIndex)) {
      
      HapticFeedback.lightImpact();
      
      setState(() {
        _currentPath.add(point);
      });
      
      // Check if we reached the other endpoint
      if (targetCell.type == CellType.endpoint &&
          targetCell.colorIndex == _currentColorIndex &&
          _currentPath.length > 1) {
        _completePath();
      }
    }
  }
  
  void _onPanEnd(DragEndDetails details) {
    if (!_isDrawing) return;
    
    setState(() {
      _isDrawing = false;
      
      // Check if path is complete (reached other endpoint)
      if (_currentPath.isNotEmpty) {
        final lastPoint = _currentPath.last;
        final lastCell = _playerGrid[lastPoint.y][lastPoint.x];
        
        if (lastCell.type != CellType.endpoint ||
            lastCell.colorIndex != _currentColorIndex) {
          // Incomplete path - clear it
          _currentPath = [];
        }
      }
      
      _currentColorIndex = null;
    });
    
    // Check win condition
    _checkWin();
  }
  
  bool _isAdjacent(Point<int> a, Point<int> b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs() == 1;
  }
  
  (int, int)? _getCellFromPosition(Offset position, BoxConstraints constraints) {
    final cellSize = constraints.maxWidth / widget.gridSize;
    final col = (position.dx / cellSize).floor();
    final row = (position.dy / cellSize).floor();
    
    if (row < 0 || row >= widget.gridSize || col < 0 || col >= widget.gridSize) {
      return null;
    }
    
    return (row, col);
  }
  
  void _clearColorPath(int colorIndex) {
    for (int r = 0; r < widget.gridSize; r++) {
      for (int c = 0; c < widget.gridSize; c++) {
        final cell = _playerGrid[r][c];
        if (cell.type == CellType.path && cell.colorIndex == colorIndex) {
          _playerGrid[r][c] = Cell(type: CellType.empty);
        }
      }
    }
  }
  
  void _completePath() {
    // Commit the path to the grid
    for (int i = 0; i < _currentPath.length - 1; i++) {
      final point = _currentPath[i];
      if (_playerGrid[point.y][point.x].type == CellType.empty) {
        _playerGrid[point.y][point.x] = Cell(
          type: CellType.path,
          colorIndex: _currentColorIndex,
        );
      }
    }
    
    _moves++;
    _currentPath = [];
  }
  
  void _checkWin() {
    if (_generator.checkWin(_playerGrid, widget.gridSize)) {
      setState(() => _isCompleted = true);
      _timer?.cancel();
      
      // Save progress
      final progress = context.read<GameProgress>();
      final gameKey = 'color_${widget.gridSize}_${widget.level}';
      progress.setBestTime(gameKey, _elapsedSeconds);
      
      // Calculate stars
      int stars = 3;
      final expectedMoves = _level.colorCount;
      if (_moves > expectedMoves * 1.5) stars--;
      if (_elapsedSeconds > widget.gridSize * 20) stars--;
      progress.setStars(gameKey, stars);
      
      // Unlock next level
      progress.unlockColorConnectLevel(widget.level + 1);
      
      _showVictoryDialog();
    }
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
              'Moves: $_moves',
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
  
  void _resetLevel() {
    HapticFeedback.heavyImpact();
    setState(() {
      _initializePlayerGrid();
      _currentPath = [];
      _currentColorIndex = null;
      _isDrawing = false;
      _moves = 0;
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _flowControllers.values) {
      controller.dispose();
    }
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
              'Color Connect',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.gridSize}x${widget.gridSize} - Level ${widget.level}',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textDark),
            onPressed: _resetLevel,
          ),
        ],
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
                _buildStatCard(Icons.touch_app, '$_moves'),
                _buildStatCard(Icons.circle, '${_level.colorCount}'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Instructions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondaryPink,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🔗 Connect matching colors!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.accentPink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Game grid
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onPanStart: (details) => _onPanStart(details, constraints),
                          onPanUpdate: (details) => _onPanUpdate(details, constraints),
                          onPanEnd: _onPanEnd,
                          child: CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: ColorConnectPainter(
                              grid: _playerGrid,
                              gridSize: widget.gridSize,
                              currentPath: _currentPath,
                              currentColorIndex: _currentColorIndex,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
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
}

class ColorConnectPainter extends CustomPainter {
  final List<List<Cell>> grid;
  final int gridSize;
  final List<Point<int>> currentPath;
  final int? currentColorIndex;

  ColorConnectPainter({
    required this.grid,
    required this.gridSize,
    required this.currentPath,
    this.currentColorIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridSize;
    final dotRadius = cellSize * 0.35;
    final pathWidth = cellSize * 0.25;
    
    // Draw grid background
    final bgPaint = Paint()..color = const Color(0xFFFAFAFA);
    canvas.drawRect(Offset.zero & size, bgPaint);
    
    // Draw grid lines
    final linePaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;
    
    for (int i = 0; i <= gridSize; i++) {
      final pos = i * cellSize;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), linePaint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), linePaint);
    }
    
    // Draw completed paths
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final cell = grid[r][c];
        if (cell.type == CellType.path && cell.colorIndex != null) {
          _drawPathSegment(canvas, r, c, cell.colorIndex!, cellSize, pathWidth);
        }
      }
    }
    
    // Draw current path being drawn
    if (currentPath.length > 1 && currentColorIndex != null) {
      final pathPaint = Paint()
        ..color = AppColors.flowColors[currentColorIndex!]
        ..strokeWidth = pathWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      
      final path = Path();
      final firstPoint = currentPath[0];
      path.moveTo(
        firstPoint.x * cellSize + cellSize / 2,
        firstPoint.y * cellSize + cellSize / 2,
      );
      
      for (int i = 1; i < currentPath.length; i++) {
        final point = currentPath[i];
        path.lineTo(
          point.x * cellSize + cellSize / 2,
          point.y * cellSize + cellSize / 2,
        );
      }
      
      canvas.drawPath(path, pathPaint);
    }
    
    // Draw endpoints and path cells
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final cell = grid[r][c];
        final center = Offset(
          c * cellSize + cellSize / 2,
          r * cellSize + cellSize / 2,
        );
        
        if (cell.type == CellType.endpoint && cell.colorIndex != null) {
          // Draw endpoint
          final color = AppColors.flowColors[cell.colorIndex!];
          
          // Outer glow
          final glowPaint = Paint()
            ..color = color.withOpacity(0.3)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(center, dotRadius * 1.3, glowPaint);
          
          // Main dot
          final dotPaint = Paint()
            ..color = color
            ..style = PaintingStyle.fill;
          canvas.drawCircle(center, dotRadius, dotPaint);
          
          // Inner highlight
          final highlightPaint = Paint()
            ..color = Colors.white.withOpacity(0.4)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            center - Offset(dotRadius * 0.3, dotRadius * 0.3),
            dotRadius * 0.3,
            highlightPaint,
          );
        }
      }
    }
    
    // Draw current path endpoint glow
    if (currentPath.isNotEmpty && currentColorIndex != null) {
      final lastPoint = currentPath.last;
      final center = Offset(
        lastPoint.x * cellSize + cellSize / 2,
        lastPoint.y * cellSize + cellSize / 2,
      );
      final color = AppColors.flowColors[currentColorIndex!];
      
      final glowPaint = Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, dotRadius * 1.5, glowPaint);
    }
  }
  
  void _drawPathSegment(
    Canvas canvas,
    int r,
    int c,
    int colorIndex,
    double cellSize,
    double pathWidth,
  ) {
    final color = AppColors.flowColors[colorIndex];
    final center = Offset(
      c * cellSize + cellSize / 2,
      r * cellSize + cellSize / 2,
    );
    
    final pathPaint = Paint()
      ..color = color
      ..strokeWidth = pathWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    // Check neighbors and draw connections
    final directions = [(0, 1), (1, 0), (0, -1), (-1, 0)];
    for (final (dr, dc) in directions) {
      final nr = r + dr;
      final nc = c + dc;
      
      if (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
        final neighbor = grid[nr][nc];
        if (neighbor.colorIndex == colorIndex) {
          final neighborCenter = Offset(
            nc * cellSize + cellSize / 2,
            nr * cellSize + cellSize / 2,
          );
          canvas.drawLine(center, neighborCenter, pathPaint);
        }
      }
    }
    
    // Draw rounded cap at the path cell
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, pathWidth / 2, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
