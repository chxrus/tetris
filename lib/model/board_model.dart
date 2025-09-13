class BoardModel {
  final int rows;
  final int cols;

  late final List<List<int>> cells;

  int activeX;
  int activeY;

  bool isGameOver = false;

  BoardModel({required this.rows, required this.cols})
      : activeX = cols ~/ 2,
        activeY = 0 {
    cells = List.generate(rows, (_) => List.filled(cols, 0));
  }

  bool canMove(int dx, int dy) => _canPlace(activeX + dx, activeY + dy);
  bool canMoveDown() => canMove(0, 1);

  bool fallOneCell() {
    if (canMoveDown()) {
      activeY += 1;
      return true;
    }
    return false;
  }

  bool tryShiftHorizontal(int dx) {
    if (canMove(dx, 0)) {
      activeX += dx;
      return true;
    }
    return false;
  }

  bool tryFallOnce() {
    if (canMove(0, 1)) {
      activeY += 1;
      return true;
    }
    _lockAndSpawn();
    return false;
  }

  void hardDropAndLock() {
    while (canMoveDown()) {
      activeY += 1;
    }
    _lockAndSpawn();
  }

  void rotateClockwise() {
    // позже заменим реальным поворотом тетромино
  }

  void rotateCounterclockwise() {
    // позже заменим реальным поворотом тетромино
  }

  bool _canPlace(int x, int y) {
    if (!_isInside(x, y)) return false;
    return cells[y][x] == 0;
  }

  bool _isInside(int x, int y) => x >= 0 && x < cols && y >= 0 && y < rows;

  void _lockAndSpawn() {
    if (_isInside(activeX, activeY)) {
      cells[activeY][activeX] = 1;
    }
    _clearFullLines();

    activeX = cols ~/ 2;
    activeY = 0;

    // если место занято - игра окончена
    if (!_canPlace(activeX, activeY)) {
      isGameOver = true;
    }
  }

  void _clearFullLines() {
    final newRows = <List<int>>[];
    int cleared = 0;
    for (var y = 0; y < rows; y++) {
      final full = cells[y].every((v) => v != 0);
      if (full) {
        cleared++;
      } else {
        newRows.add(cells[y]);
      }
    }
    for (var i = 0; i < cleared; i++) {
      newRows.insert(0, List.filled(cols, 0));
    }
    for (var y = 0; y < rows; y++) {
      cells[y] = newRows[y];
    }
  }
}
