import 'dart:math';

enum CellType {
  empty,
  endpoint,
  path,
}

class Cell {
  CellType type;
  int? colorIndex;
  bool isEndpoint;
  
  Cell({
    this.type = CellType.empty,
    this.colorIndex,
    this.isEndpoint = false,
  });
  
  Cell copy() => Cell(
    type: type,
    colorIndex: colorIndex,
    isEndpoint: isEndpoint,
  );
}

class ColorConnectLevel {
  final int size;
  final List<List<Cell>> grid;
  final int colorCount;
  
  ColorConnectLevel({
    required this.size,
    required this.grid,
    required this.colorCount,
  });
}

class ColorConnectGenerator {
  final Random _random = Random();
  
  ColorConnectLevel generate(int size) {
    // Determine number of colors based on grid size
    final colorCount = _getColorCount(size);
    
    // Generate solution first
    final solution = _generateSolution(size, colorCount);
    
    // Create level with only endpoints
    final grid = _createLevelFromSolution(solution, size);
    
    return ColorConnectLevel(
      size: size,
      grid: grid,
      colorCount: colorCount,
    );
  }
  
  int _getColorCount(int size) {
    // More colors for larger grids
    switch (size) {
      case 5: return 3;
      case 6: return 4;
      case 7: return 5;
      case 8: return 6;
      case 9: return 7;
      case 10: return 8;
      default: return 4;
    }
  }
  
  List<List<Cell>> _generateSolution(int size, int colorCount) {
    // Initialize empty solution grid
    final solution = List.generate(
      size,
      (_) => List.generate(size, (_) => Cell()),
    );
    
    // Place endpoints and create paths
    for (int color = 0; color < colorCount; color++) {
      _placeColorPair(solution, size, color);
    }
    
    return solution;
  }
  
  void _placeColorPair(List<List<Cell>> grid, int size, int colorIndex) {
    // Find two empty cells for endpoints
    List<(int, int)> emptyCells = [];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c].type == CellType.empty) {
          emptyCells.add((r, c));
        }
      }
    }
    
    if (emptyCells.length < 2) return;
    
    // Select two random cells
    emptyCells.shuffle(_random);
    final (r1, c1) = emptyCells[0];
    final (r2, c2) = emptyCells[1];
    
    // Mark as endpoints
    grid[r1][c1] = Cell(
      type: CellType.endpoint,
      colorIndex: colorIndex,
      isEndpoint: true,
    );
    grid[r2][c2] = Cell(
      type: CellType.endpoint,
      colorIndex: colorIndex,
      isEndpoint: true,
    );
    
    // Create path between endpoints using BFS/DFS
    _createPath(grid, r1, c1, r2, c2, colorIndex, size);
  }
  
  void _createPath(
    List<List<Cell>> grid,
    int startR, int startC,
    int endR, int endC,
    int colorIndex,
    int size,
  ) {
    // Simple path creation using random walk with some intelligence
    int currentR = startR;
    int currentC = startC;
    
    final visited = <(int, int)>{};
    visited.add((currentR, currentC));
    
    final directions = [(0, 1), (1, 0), (0, -1), (-1, 0)];
    
    while (currentR != endR || currentC != endC) {
      // Shuffle directions for randomness
      directions.shuffle(_random);
      
      bool moved = false;
      for (final (dr, dc) in directions) {
        final newR = currentR + dr;
        final newC = currentC + dc;
        
        // Check bounds
        if (newR < 0 || newR >= size || newC < 0 || newC >= size) continue;
        
        // Check if it's the target
        if (newR == endR && newC == endC) {
          // Mark path cells
          _markPathCells(grid, visited, colorIndex);
          return;
        }
        
        // Check if cell is empty and not visited
        if (grid[newR][newC].type == CellType.empty && 
            !visited.contains((newR, newC))) {
          currentR = newR;
          currentC = newC;
          visited.add((currentR, currentC));
          moved = true;
          break;
        }
      }
      
      // If stuck, backtrack
      if (!moved) {
        if (visited.length > 1) {
          visited.remove((currentR, currentC));
          final prev = visited.last;
          currentR = prev.$1;
          currentC = prev.$2;
        } else {
          break; // Give up
        }
      }
    }
    
    _markPathCells(grid, visited, colorIndex);
  }
  
  void _markPathCells(
    List<List<Cell>> grid,
    Set<(int, int)> pathCells,
    int colorIndex,
  ) {
    for (final (r, c) in pathCells) {
      if (grid[r][c].type != CellType.endpoint) {
        grid[r][c] = Cell(
          type: CellType.path,
          colorIndex: colorIndex,
          isEndpoint: false,
        );
      }
    }
  }
  
  List<List<Cell>> _createLevelFromSolution(
    List<List<Cell>> solution,
    int size,
  ) {
    final level = List.generate(
      size,
      (_) => List.generate(size, (_) => Cell()),
    );
    
    // Only keep endpoints
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (solution[r][c].type == CellType.endpoint) {
          level[r][c] = solution[r][c].copy();
        }
      }
    }
    
    return level;
  }
  
  bool isValidMove(
    List<List<Cell>> playerGrid,
    int fromR, int fromC,
    int toR, int toC,
    int size,
  ) {
    // Check bounds
    if (toR < 0 || toR >= size || toC < 0 || toC >= size) {
      return false;
    }
    
    // Check if adjacent
    final dr = (toR - fromR).abs();
    final dc = (toC - fromC).abs();
    if (dr + dc != 1) return false;
    
    final targetCell = playerGrid[toR][toC];
    
    // Can move to empty cell or matching endpoint
    if (targetCell.type == CellType.empty) return true;
    if (targetCell.type == CellType.endpoint &&
        targetCell.colorIndex == playerGrid[fromR][fromC].colorIndex) {
      return true;
    }
    
    return false;
  }
  
  bool checkWin(List<List<Cell>> grid, int size) {
    // Check if all endpoints are connected
    final connectedColors = <int>{};
    
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final cell = grid[r][c];
        if (cell.type == CellType.endpoint && cell.colorIndex != null) {
          // Check if there's a path to the other endpoint
          if (_hasPathToOtherEndpoint(grid, r, c, size)) {
            connectedColors.add(cell.colorIndex!);
          }
        }
      }
    }
    
    // Count total endpoints per color
    final endpointCounts = <int, int>{};
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final cell = grid[r][c];
        if (cell.type == CellType.endpoint && cell.colorIndex != null) {
          endpointCounts[cell.colorIndex!] = 
              (endpointCounts[cell.colorIndex!] ?? 0) + 1;
        }
      }
    }
    
    // All colors should have both endpoints connected
    for (final count in endpointCounts.values) {
      if (count != 2) return false;
    }
    
    // All colors should be connected
    final expectedColors = endpointCounts.keys.toSet();
    return connectedColors.containsAll(expectedColors);
  }
  
  bool _hasPathToOtherEndpoint(
    List<List<Cell>> grid,
    int startR, int startC,
    int size,
  ) {
    final colorIndex = grid[startR][startC].colorIndex;
    if (colorIndex == null) return false;
    
    final visited = <(int, int)>{};
    final queue = <(int, int)>[(startR, startC)];
    
    while (queue.isNotEmpty) {
      final (r, c) = queue.removeAt(0);
      
      if (visited.contains((r, c))) continue;
      visited.add((r, c));
      
      // Check if we found another endpoint of the same color
      final cell = grid[r][c];
      if (cell.type == CellType.endpoint &&
          cell.colorIndex == colorIndex &&
          (r != startR || c != startC)) {
        return true;
      }
      
      // Explore neighbors
      final directions = [(0, 1), (1, 0), (0, -1), (-1, 0)];
      for (final (dr, dc) in directions) {
        final nr = r + dr;
        final nc = c + dc;
        
        if (nr >= 0 && nr < size && nc >= 0 && nc < size) {
          final neighbor = grid[nr][nc];
          if (!visited.contains((nr, nc)) &&
              neighbor.colorIndex == colorIndex) {
            queue.add((nr, nc));
          }
        }
      }
    }
    
    return false;
  }
}
