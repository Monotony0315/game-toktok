import 'dart:math';

class SudokuGenerator {
  final Random _random = Random();
  late List<List<int>> _solution;
  late List<List<int>> _puzzle;
  
  List<List<int>> get solution => _solution;
  List<List<int>> get puzzle => _puzzle;

  // Difficulty levels: number of cells to remove
  static const Map<String, int> difficultyCells = {
    'easy': 35,
    'medium': 45,
    'hard': 55,
  };

  void generate(String difficulty) {
    // Start with empty grid
    _solution = List.generate(9, (_) => List.filled(9, 0));
    
    // Fill diagonal 3x3 boxes first (they're independent)
    _fillDiagonalBoxes();
    
    // Solve the rest
    _solveSudoku(_solution);
    
    // Create puzzle by removing cells
    _puzzle = _createPuzzle(difficulty);
  }

  void _fillDiagonalBoxes() {
    for (int box = 0; box < 9; box += 3) {
      _fillBox(box, box);
    }
  }

  void _fillBox(int row, int col) {
    List<int> nums = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    nums.shuffle(_random);
    
    int index = 0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        _solution[row + i][col + j] = nums[index++];
      }
    }
  }

  bool _solveSudoku(List<List<int>> grid) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          List<int> nums = [1, 2, 3, 4, 5, 6, 7, 8, 9];
          nums.shuffle(_random);
          
          for (int num in nums) {
            if (_isValid(grid, row, col, num)) {
              grid[row][col] = num;
              
              if (_solveSudoku(grid)) {
                return true;
              }
              
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValid(List<List<int>> grid, int row, int col, int num) {
    // Check row
    for (int x = 0; x < 9; x++) {
      if (grid[row][x] == num) return false;
    }
    
    // Check column
    for (int x = 0; x < 9; x++) {
      if (grid[x][col] == num) return false;
    }
    
    // Check 3x3 box
    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[i + startRow][j + startCol] == num) return false;
      }
    }
    
    return true;
  }

  List<List<int>> _createPuzzle(String difficulty) {
    // Deep copy solution
    List<List<int>> puzzle = List.generate(
      9, 
      (i) => List.generate(9, (j) => _solution[i][j])
    );
    
    int cellsToRemove = difficultyCells[difficulty] ?? 45;
    
    // Remove cells while ensuring unique solution
    List<int> positions = List.generate(81, (i) => i);
    positions.shuffle(_random);
    
    int removed = 0;
    for (int pos in positions) {
      if (removed >= cellsToRemove) break;
      
      int row = pos ~/ 9;
      int col = pos % 9;
      
      if (puzzle[row][col] != 0) {
        int temp = puzzle[row][col];
        puzzle[row][col] = 0;
        
        // Check if still has unique solution (simplified check)
        if (_hasUniqueSolution(puzzle)) {
          removed++;
        } else {
          puzzle[row][col] = temp;
        }
      }
    }
    
    return puzzle;
  }

  bool _hasUniqueSolution(List<List<int>> puzzle) {
    // Simplified: count solutions (should be 1)
    List<List<int>> copy = List.generate(
      9, 
      (i) => List.generate(9, (j) => puzzle[i][j])
    );
    
    return _countSolutions(copy, 0) == 1;
  }

  int _countSolutions(List<List<int>> grid, int count) {
    if (count > 1) return count;
    
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (_isValid(grid, row, col, num)) {
              grid[row][col] = num;
              count = _countSolutions(grid, count);
              grid[row][col] = 0;
              if (count > 1) return count;
            }
          }
          return count;
        }
      }
    }
    return count + 1;
  }

  bool isValidMove(List<List<int>> grid, int row, int col, int num) {
    return _isValid(grid, row, col, num);
  }

  List<int> getPossibleValues(List<List<int>> grid, int row, int col) {
    List<int> possible = [];
    for (int num = 1; num <= 9; num++) {
      if (_isValid(grid, row, col, num)) {
        possible.add(num);
      }
    }
    return possible;
  }
}
